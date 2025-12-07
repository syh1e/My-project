import pygame
import sys
import math
from constants import WIDTH, HEIGHT, FPS, GRAVITY, GROUND_Y, BG_COLOR, GROUND_COLOR
from entities import Ball
from game_logic import reset_game
from draw_utils import draw_star, draw_success_screen
from physics import circle_circle_collision

pygame.init()
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("SWCON211 Term Project")
clock = pygame.time.Clock()


def draw_trajectory(surface, start_pos, init_vel, gravity, max_steps=60, step_dt=0.08, color=(180, 220, 255)):
    """
       단순 샘플링으로 포물선 예측 궤적을 점선으로 그림.
       start_pos: Vector2 시작 위치
       init_vel: Vector2 초기 속도
       gravity: scalar (positive, 아래방향)
    """
    pts = []
    p = pygame.Vector2(start_pos)
    v = pygame.Vector2(init_vel)
    g = pygame.Vector2(0, gravity)
    for i in range(max_steps):
        t = (i + 1) * step_dt
        # p(t) = p0 + v0 * t + 0.5 * g * t^2
        pos = start_pos + v * t + 0.5 * g * (t * t) #등가속도 운동 방정식
        # 스크린 밖이거나 땅에 닿으면 중단
        if pos.y - 0 > GROUND_Y + 20 or pos.x < -50 or pos.x > WIDTH + 50:
            break
        pts.append(pos)
        if pos.y >= GROUND_Y:
            break

    # 점선 (작은 원으로 표시, 간격을 두어 dash 느낌)
    for idx, pt in enumerate(pts):
        if idx % 2 == 0:
            pygame.draw.circle(surface, color, (int(pt.x), int(pt.y)), 3)
        else:
            # 약간 작게 해서 dash 느낌 차등
            pygame.draw.circle(surface, color, (int(pt.x), int(pt.y)), 2)


def main():
    ball, blocks, boost_blocks, deadly_blocks, star_pos, star2_pos, star_radius, star_collected, star2_collected, success, last_left_time, last_right_time = reset_game()
    trajectory_preview = None
    double_tap_threshold = 0.23

    # 조각(pieces) 목록 (깨질 때 생성되는 파편들)
    pieces = []

    running = True
    while running:
        dt = clock.tick(FPS) / 1000.0
        now = pygame.time.get_ticks() / 1000.0

        # dynamic deadly block 업데이트: 떨어지게 하고 respawn 처리, 깨지면 조각 생성
        for db in list(deadly_blocks):
            if hasattr(db, "update"):
                try:
                    db.update(dt)
                except Exception:
                    pass
            # 깨진 블록에서 아직 파편을 생성하지 않았다면 spawn_pieces()
            if getattr(db, "broken", False) and not getattr(db, "pieces_spawned", False):
                try:
                    new_pieces = db.spawn_pieces()
                    if new_pieces:
                        pieces.extend(new_pieces)
                except Exception:
                    pass

        # 발사/무적 타이머 업데이트
        if hasattr(ball, "tick"):
            ball.tick(dt)
        # 해석발사 상태면 해석적 위치 업데이트
        if getattr(ball, "is_launched", False):
            ball.update_launched(dt)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_q:
                    running = False

                if event.key == pygame.K_r:
                    ball, blocks, boost_blocks, deadly_blocks, star_pos, star2_pos, star_radius, star_collected, star2_collected, success, last_left_time, last_right_time = reset_game()
                    trajectory_preview = None
                    # 리셋 시 파편도 비움
                    pieces.clear()
                    continue

                # 스페이스: 포획 상태이면 해석적 발사 시작
                if event.key == pygame.K_SPACE:
                    if ball.is_captured and isinstance(ball.captive_block, type(blocks[0])):
                        sb = ball.captive_block
                        dir = pygame.Vector2(math.cos(sb.aim_angle), math.sin(sb.aim_angle))
                        # 시작 위치와 초기속도 계산
                        start = pygame.Vector2(sb.rect.centerx, sb.rect.centery) + dir * (max(sb.rect.width, sb.rect.height) * sb.launch_offset + ball.radius + 6)
                        init_v = dir * sb.launch_speed
                        # 해석적 발사 사용
                        ball.start_analytic_launch(start, init_v)
                        ball.is_captured = False
                        sb.has_ball = False
                        ball.captive_block = None
                        ball.is_launched = True
                        # 발사하면 궤적 숨김
                        trajectory_preview = None

                if event.key == pygame.K_LEFT:
                    if now - last_left_time < double_tap_threshold:
                        if ball.control_enabled:
                            ball.start_dash(-1)
                    last_left_time = now

                if event.key == pygame.K_RIGHT:
                    if now - last_right_time < double_tap_threshold:
                        if ball.control_enabled:
                            ball.start_dash(+1)
                    last_right_time = now

        if success:
            draw_success_screen(screen)
            pygame.display.flip()
            continue

        # ShooterBlock 업데이트 (회전 등)
        for b in blocks:
            if hasattr(b, "update"):
                # ShooterBlock.update will only spin when it has_ball
                try:
                    b.update(dt)
                except TypeError:
                    # some update signatures may differ; ignore
                    pass

        # boost 블록 물리 업데이트 추가
        for boost in list(boost_blocks):
            boost.update(dt, blocks)

        if ball.is_captured:
            # 공이 블록에 들어가 있으면 물리 업데이트하지 않음.
            # 궤적은 화면 그리기 시에 실제로 렌더링(화면 클리어 후)하도록 파라미터만 계산.
            trajectory_preview = None
            if getattr(ball, "captive_block", None) is not None:
                sb = ball.captive_block
                try:
                    dir_vec = pygame.Vector2(math.cos(sb.aim_angle), math.sin(sb.aim_angle))
                    start = pygame.Vector2(sb.rect.centerx, sb.rect.centery) + dir_vec * (max(sb.rect.width, sb.rect.height) * 0.5 + ball.radius + 2)
                    init_v = dir_vec * sb.launch_speed
                    trajectory_preview = (start, init_v)
                except Exception:
                    trajectory_preview = None
        else:
            if ball.update_dash(dt):
                ball.collide_with_walls_impulse()
                ball.collide_with_blocks(blocks, boost_blocks, deadly_blocks)
            else:
                # 입력/마찰 적용은 control_enabled 일 때만 (발사 중이면 마찰로 속도 깎지 않음)
                keys = pygame.key.get_pressed()
                horizontal_accel = 1000.0
                friction = 0.85
                max_speed = 150.0

                if ball.control_enabled:
                    if keys[pygame.K_LEFT]:
                        ball.vel.x -= horizontal_accel * dt
                    if keys[pygame.K_RIGHT]:
                        ball.vel.x += horizontal_accel * dt

                    if not (keys[pygame.K_LEFT] or keys[pygame.K_RIGHT]):
                        ball.vel.x *= friction
                else:
                    # control_disabled 이고 발사 상태가 아니면(예: 포획상태) 속도 유지 / 별도 처리 없음
                    pass

                ball.vel.x = max(-max_speed, min(max_speed, ball.vel.x))

                ball.apply_gravity(dt)
                ball.integrate(dt)
                # 충돌 처리 (충돌 시 is_launched False로 복귀하도록 entities.py에서 설정)
                ball.collide_with_walls_impulse()
                ball.collide_with_blocks(blocks, boost_blocks, deadly_blocks)
                # collide 함수에 의해 control_enabled가 True로 설정될 수 있음

        # DeadlyBlock과의 충돌(원-사각) 검사 -> 충돌시 즉시 재시작
        for db in deadly_blocks:
            is_dead, _ = db.check_collision(ball.pos, ball.radius)
            if is_dead:
                ball, blocks, boost_blocks, deadly_blocks, star_pos, star2_pos, star_radius, star_collected, star2_collected, success, last_left_time, last_right_time = reset_game()
                trajectory_preview = None
                pieces.clear()
                break

        # 두 별 수집 검사
        if not star_collected:
            if circle_circle_collision(ball.pos, ball.radius, star_pos, star_radius):
                star_collected = True
        if not star2_collected:
            if circle_circle_collision(ball.pos, ball.radius, star2_pos, star_radius):
                star2_collected = True
        if star_collected and star2_collected:
            success = True

        screen.fill(BG_COLOR)
        pygame.draw.rect(screen, GROUND_COLOR, (0, GROUND_Y, WIDTH, HEIGHT - GROUND_Y))

        # 궤적은 화면을 지운 다음에 그려야 보입니다.
        if trajectory_preview is not None:
            start, init_v = trajectory_preview
            draw_trajectory(screen, start, init_v, GRAVITY)

        for block in blocks:
            block.draw(screen)
        for boost in boost_blocks:
            boost.draw(screen)
         # deadly block은 별도 스타일로 그림
        for db in deadly_blocks:
            db.draw(screen)

        # 파편 업데이트 및 렌더 (위에 그려짐)
        for pc in list(pieces):
            try:
                pc.update(dt)
                pc.draw(screen)
            except Exception:
                try:
                    pieces.remove(pc)
                except Exception:
                    pass
            # 수명 다한 파편 제거
            if getattr(pc, "life", 0.0) <= 0.0:
                try:
                    pieces.remove(pc)
                except Exception:
                    pass

        # 별 그리기
        if not star_collected:
            draw_star(screen, (star_pos.x, star_pos.y), star_radius, (255, 215, 0))
        if not star2_collected:
            draw_star(screen, (star2_pos.x, star2_pos.y), star_radius, (255, 215, 0))

        # 공 그리기: 포획 중이면 숨김
        if not getattr(ball, "is_captured", False):
            ball.draw(screen)

        pygame.display.flip()

    pygame.quit()
    sys.exit()


if __name__ == "__main__":
    main()
