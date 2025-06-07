from datetime import datetime, timedelta
import random
from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error
from flask_jwt_extended import jwt_required

app = Flask(__name__)

# Database connection
try:
    conn = mysql.connector.connect(
        host='localhost',
        user='root',
        password='1234',
        database='study_db'
    )
    cursor = conn.cursor()
except Error as e:
    print(f"Error connecting to MySQL: {e}")

# 출석 인증 시작
@app.route('/api/studies/<int:study_id>/start-attendance', methods=['POST'])
@jwt_required()
def start_attendance(study_id):
    try:
        # 스터디 존재 여부 확인
        cursor.execute('SELECT 1 FROM studies WHERE id = %s', (study_id,))
        if not cursor.fetchone():
            return jsonify({'error': '존재하지 않는 스터디입니다.'}), 404

        # 기존 인증 정보 및 출석 기록 모두 삭제
        cursor.execute('DELETE FROM attendance_verification WHERE study_id = %s', (study_id,))
        cursor.execute('DELETE FROM attendance WHERE study_id = %s', (study_id,))
        conn.commit()

        # 4자리 랜덤 숫자 생성
        attendance_code = str(random.randint(1000, 9999))
        # 10분 후 만료 시간 설정
        expires_at = datetime.now() + timedelta(minutes=10)

        # 새로운 인증 정보 저장 및 id 가져오기
        cursor.execute(
            'INSERT INTO attendance_verification (study_id, code, expires_at) VALUES (%s, %s, %s)',
            (study_id, attendance_code, expires_at)
        )
        conn.commit()
        # 마지막 삽입된 ID 가져오기 (MySQL Connector)
        attendance_verification_id = cursor.lastrowid

        # 해당 스터디의 모든 참여자를 결석으로 초기화 (스터디장 제외)
        # 스터디장의 user_id 가져오기
        cursor.execute('SELECT leader_id FROM studies WHERE id = %s', (study_id,))
        leader_id_tuple = cursor.fetchone()
        leader_id = leader_id_tuple[0] if leader_id_tuple else None

        if leader_id:
             # 스터디 참여자 조회 (스터디장 제외)
            cursor.execute('''
                SELECT user_id FROM study_participants
                WHERE study_id = %s AND user_id != %s
            ''', (study_id, leader_id))
            participant_ids = [row[0] for row in cursor.fetchall()]

            # 각 참여자에 대해 'absent' 기록 삽입
            if participant_ids:
                insert_query = '''
                    INSERT INTO attendance (study_id, user_id, status, date, attendance_verification_id)
                    VALUES (%s, %s, %s, %s, %s)
                '''
                today = datetime.now().date()
                attendance_records_to_insert = [
                    (study_id, user_id, 'absent', today, attendance_verification_id) for user_id in participant_ids
                ]
                cursor.executemany(insert_query, attendance_records_to_insert)
                conn.commit()

        print(f"Attendance started for study {study_id} with code {attendance_code}, verification_id {attendance_verification_id}")
        return jsonify({
            'code': attendance_code,
            'expires_at': expires_at.isoformat(),
            'verification_id': attendance_verification_id
        })
    except Exception as e:
        print(f"Error in start_attendance: {str(e)}")
        return jsonify({'error': str(e)}), 500

# 출석 인증 확인
@app.route('/api/studies/<int:study_id>/verify-attendance', methods=['POST'])
def verify_attendance(study_id):
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': '요청 데이터가 없습니다.'}), 400

        user_id = data.get('user_id')
        code = data.get('code')

        if not user_id or not code:
            return jsonify({'error': '사용자 ID와 인증 코드가 필요합니다.'}), 400

        # 스터디 참여 여부 확인
        cursor.execute('''
            SELECT 1 FROM study_participants 
            WHERE study_id = %s AND user_id = %s
        ''', (study_id, user_id))
        if not cursor.fetchone():
            return jsonify({'error': '해당 스터디의 참여자가 아닙니다.'}), 400

        # 인증 코드 및 세션 ID 확인
        cursor.execute('''
            SELECT id, code, expires_at
            FROM attendance_verification
            WHERE study_id = %s AND expires_at > NOW()
            ORDER BY expires_at DESC LIMIT 1
        ''', (study_id,))
        result = cursor.fetchone()

        if not result:
            return jsonify({'error': '인증이 시작되지 않았습니다.'}), 400

        verification_id, stored_code, expires_at = result

        # 만료 시간 확인
        if expires_at is None or datetime.now() > expires_at:
            return jsonify({'error': '인증 시간이 만료되었거나 유효하지 않습니다.'}), 400

        if code != stored_code:
            return jsonify({'error': '잘못된 인증 코드입니다.'}), 400

        # 이미 해당 인증 세션에 출석했는지 확인
        cursor.execute('''
            SELECT 1 FROM attendance
            WHERE study_id = %s AND user_id = %s AND attendance_verification_id = %s
        ''', (study_id, user_id, verification_id))
        if cursor.fetchone():
            return jsonify({'error': '이미 출석했습니다.'}), 400

        # 출석 기록
        today = datetime.now().date()
        cursor.execute('''
            INSERT INTO attendance (study_id, user_id, status, date, attendance_verification_id) 
            VALUES (%s, %s, %s, %s, %s)
        ''', (study_id, user_id, 'present', today, verification_id))
        conn.commit()

        return jsonify({'message': '출석이 확인되었습니다.'})
    except Exception as e:
        print(f"Error in verify_attendance: {str(e)}")
        return jsonify({'error': str(e)}), 500

# 출석 현황 조회
@app.route('/api/studies/<int:study_id>/attendance', methods=['GET'])
def get_attendance(study_id):
    try:
        # 현재 활성화된 출석 인증 세션 확인
        cursor.execute('''
            SELECT id, code, expires_at
            FROM attendance_verification
            WHERE study_id = %s AND expires_at > NOW()
            ORDER BY expires_at DESC LIMIT 1
        ''', (study_id,))
        verification = cursor.fetchone()

        if not verification:
            return jsonify({'error': '현재 진행 중인 출석 인증이 없습니다.'}), 400

        verification_id, code, expires_at = verification

        # 스터디의 모든 참여자 조회 (스터디장 제외)
        cursor.execute('''
            SELECT DISTINCT u.id, u.name
            FROM study_participants sp
            JOIN users u ON sp.user_id = u.id
            WHERE sp.study_id = %s
        ''', (study_id,))
        all_participants = cursor.fetchall()
        
        # 현재 인증 세션에 출석한 사람 조회
        cursor.execute('''
            SELECT u.id, u.name, a.status, a.date
            FROM attendance a
            JOIN users u ON a.user_id = u.id
            WHERE a.study_id = %s AND a.attendance_verification_id = %s
        ''', (study_id, verification_id))
        attendance_records = cursor.fetchall()
        
        # 출석 기록을 딕셔너리로 변환
        attendance_dict = {
            record[0]: {
                'name': record[1],
                'status': record[2],
                'date': record[3].isoformat()
            }
            for record in attendance_records
        }
        
        # 모든 참여자의 출석 상태 생성
        result = []
        for participant_id, participant_name in all_participants:
            if participant_id in attendance_dict:
                # 출석 기록이 있는 경우
                result.append(attendance_dict[participant_id])
            else:
                # 출석 기록이 없는 경우 (결석)
                result.append({
                    'name': participant_name,
                    'status': 'absent',
                    'date': datetime.now().date().isoformat()
                })
        
        # 현재 인증 세션 정보 추가
        result.append({
            'code': code,
            'expires_at': expires_at.isoformat(),
            'verification_id': verification_id
        })
        
        return jsonify(result)
    except Exception as e:
        print(f"Error in get_attendance: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/studies/<int:study_id>/end-attendance', methods=['POST'])
@jwt_required()
def end_attendance(study_id):
    try:
        # 스터디 존재 여부 확인
        cursor.execute('SELECT 1 FROM studies WHERE id = %s', (study_id,))
        if not cursor.fetchone():
            return jsonify({'error': '존재하지 않는 스터디입니다.'}), 404

        # 현재 활성화된 출석 인증 정보 삭제
        cursor.execute('DELETE FROM attendance_verification WHERE study_id = %s', (study_id,))
        conn.commit()

        return jsonify({'message': '출석 인증이 종료되었습니다.'})
    except Exception as e:
        print(f"Error in end_attendance: {str(e)}")
        return jsonify({'error': str(e)}), 500 