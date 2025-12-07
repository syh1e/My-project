import pygame
import math
from constants import GRAVITY, RESTIUTION, GROUND_Y, WIDTH, BG_COLOR
from physics import AABB, collision_aabb_aabb


class Block:
    """벽과 같은 기능을 하는 일반 블록 (AABB)"""
    def __init__(self, x, y, width, height, color=(100, 100, 100)):
        self.rect = pygame.Rect(x, y, width, height)
        self.color = color

    def get_closest_point(self, circle_pos):
        closest_x = max(self.rect.left, min(circle_pos.x, self.rect.right))
        closest_y = max(self.rect.top, min(circle_pos.y, self.rect.bottom))
        return pygame.Vector2(closest_x, closest_y)

    def check_collision(self, circle_pos, radius):
        closest = self.get_closest_point(circle_pos)
        dist_vec = circle_pos - closest
        dist_sq = dist_vec.length_squared()

        if dist_sq < radius * radius:
            if dist_sq == 0:
                dx_left = abs(circle_pos.x - self.rect.left)
                dx_right = abs(circle_pos.x - self.rect.right)
                dy_top = abs(circle_pos.y - self.rect.top)
                dy_bottom = abs(circle_pos.y - self.rect.bottom)

                min_dist = min(dx_left, dx_right, dy_top, dy_bottom)

                if min_dist == dx_left:
                    normal = pygame.Vector2(-1, 0)
                elif min_dist == dx_right:
                    normal = pygame.Vector2(1, 0)
                elif min_dist == dy_top:
                    normal = pygame.Vector2(0, -1)
                else:
                    normal = pygame.Vector2(0, 1)
            else:
                dist = dist_vec.length()
                normal = dist_vec / dist
            return True, normal
        return False, None

    def draw(self, surface):
        pygame.draw.rect(surface, self.color, self.rect)
        pygame.draw.rect(surface, (0, 0, 0), self.rect, 2)


class BoostBlock(Block):
    """대시 능력을 주는 기능 블록 (중력에 의해 낙하하는 블록)"""
    def __init__(self, x, y):
        super().__init__(x, y, 40, 40, (230, 200, 20))
        # 물리 상태 추가
        self.pos = pygame.Vector2(self.rect.x, self.rect.y)  # top-left 위치
        self.vel = pygame.Vector2(0, 0)  # 초기 속도

    def update(self, dt, blocks):
        """중력 적용 및 블록/바닥과의 단순 충돌(착지) 처리"""
        prev_bottom = self.pos.y + self.rect.height

        # 중력 가속도 적용
        self.vel.y += GRAVITY * dt
        # 위치 적분
        self.pos.y += self.vel.y * dt

        # 바닥 충돌 처리
        if self.pos.y + self.rect.height > GROUND_Y:
            self.pos.y = GROUND_Y - self.rect.height
            self.vel.y = 0

        # 블록 위에 착지 처리 (간단한 위에서 떨어져 착지하는 경우만)
        for block in blocks:
            # 가로 겹침 체크
            if (self.pos.x + self.rect.width > block.rect.left) and (self.pos.x < block.rect.right):
                new_bottom = self.pos.y + self.rect.height
                # 이전에 블록 위에 있지 않았고, 이번 프레임에 블록의 윗면을 넘겼으면 착지로 간주
                if prev_bottom <= block.rect.top and new_bottom >= block.rect.top:
                    self.pos.y = block.rect.top - self.rect.height
                    self.vel.y = 0
                    break

        # rect 위치 동기화
        self.rect.topleft = (int(self.pos.x), int(self.pos.y))

    def draw(self, surface):
        super().draw(surface)
        cx = self.rect.centerx
        cy = self.rect.centery
        pygame.draw.circle(surface, (0, 0, 0), (cx - 8, cy), 7)
        pygame.draw.circle(surface, (0, 0, 0), (cx, cy), 7)
        pygame.draw.circle(surface, (0, 0, 0), (cx + 8, cy), 7)


class Ball:
    def __init__(self, x, y, radius=8, mass=1.0):
        self.pos = pygame.Vector2(x, y)
        self.vel = pygame.Vector2(0, -350)
        self.base_bounce_speed = abs(self.vel.y)
        self.radius = radius
        self.mass = mass

        self.has_dash = False
        self.is_dashing = False
        self.dash_dir = 0
        self.dash_time = 0
        self.dash_duration = 0.23
        self.dash_speed = 650
        self.dash_height = 12
        self.dash_base_y = y

        self.is_captured = False
        self.captive_block = None
        self.control_enabled = True

        # 발사 관련 (해석적 궤적)
        self.is_launched = False
        self.launched_start_pos = None        # pygame.Vector2
        self.launched_init_vel = None         # pygame.Vector2
        self.launch_elapsed = 0.0

        # 발사 재포획 방지 타이머 등 기존 필드
        self.launch_timer = 0.0

    def start_dash(self, direction):
        if not self.has_dash:
            return
        if self.is_dashing:
            return

        self.has_dash = False
        self.is_dashing = True
        self.dash_dir = direction
        self.dash_time = 0
        self.dash_base_y = self.pos.y

    def update_dash(self, dt):
        if not self.is_dashing:
            return False

        self.dash_time += dt
        t = self.dash_time / self.dash_duration

        # 대시가 끝나는 순간, 바로 속도를 0으로 만들지 않고 잔류 속도를 남김
        if t >= 1.0:
            self.is_dashing = False
            residual_factor = 0.30  # 덜 갑작스럽게 멈추도록
            self.vel.x = self.dash_dir * self.dash_speed * residual_factor
            self.vel.y = max(self.vel.y, 50.0) 
            # 대시가 끝난 직후 자연스럽게 떨어지도록 살짝 아래방향 속도 유지
            return False

        decel = (1 - t)
        # 현재 프레임 기준 수평 이동량과 물리 속도 동기화
        horiz_vel = self.dash_dir * self.dash_speed * decel
        self.pos.x += horiz_vel * dt
        self.vel.x = horiz_vel

        # 아크(높이) 계산 및 수직 속도 미분값으로 부드럽게 연결
        arc = math.sin(t * math.pi) * self.dash_height
        self.pos.y = self.dash_base_y - arc
        # arc의 시간 미분 -> 수직속도로 설정 (연속성 확보)
        arc_vel = math.cos(t * math.pi) * math.pi * self.dash_height / self.dash_duration
        # pos.y = base - arc 이므로 vel.y = -d(arc)/dt
        self.vel.y = -arc_vel

        return True

    def apply_gravity(self, dt):
        self.vel.y += GRAVITY * dt

    def integrate(self, dt):
        self.pos += self.vel * dt

    def tick(self, dt):
        """매 프레임 호출: 내부 타이머 업데이트"""
        if self.launch_timer > 0.0:
            self.launch_timer = max(0.0, self.launch_timer - dt)
        # 해석발사 상태이면 시간 누적
        if self.is_launched:
            # launch elapsed 증가는 update_launched에서 처리하거나 여기서 증가
            pass

    # 새 메서드: 해석식 발사 시작
    def start_analytic_launch(self, start_pos, init_vel):
        """발사 시작: 해석식(역학식)으로 궤적을 따라 움직이게 설정."""
        self.is_launched = True
        self.launched_start_pos = pygame.Vector2(start_pos)
        self.launched_init_vel = pygame.Vector2(init_vel)
        self.launch_elapsed = 0.0
        self.control_enabled = False
        # 재포획 방지 타이머(적절히 설정)
        self.launch_timer = 0.25

    def update_launched(self, dt):
        """is_launched 상태에서 해석적으로 위치/속도 업데이트. 매 프레임 호출."""
        if not self.is_launched:
            return
        self.launch_elapsed += dt
        t = self.launch_elapsed
        g = pygame.Vector2(0, GRAVITY)
        # p(t) = p0 + v0 * t + 0.5 * g * t^2
        self.pos = self.launched_start_pos + self.launched_init_vel * t + 0.5 * g * (t * t)
        # v(t) = v0 + g * t
        self.vel = self.launched_init_vel + g * t

    def collide_with_walls_impulse(self):
        """월드 경계 충돌 — 간단한 노멀 반사 및 위치 보정 처리."""
        # 바닥
        if self.pos.y + self.radius > GROUND_Y:
            self.pos.y = GROUND_Y - self.radius
            # 바닥 위로 튀어오르는 속도는 항상 base_bounce_speed로 설정
            self.vel.y = -self.base_bounce_speed
            # 벽/바닥에 닿으면 조작 허용 재개, 발사 상태 해제
            self.control_enabled = True
            self.launch_timer = 0.0
            self.is_launched = False

        # 천장
        if self.pos.y - self.radius < 0:
            self.pos.y = self.radius
            n = pygame.Vector2(0, 1)
            v_n = self.vel.dot(n)
            if v_n < 0:
                self.vel -= (1 + RESTIUTION) * v_n * n
            self.control_enabled = True
            self.launch_timer = 0.0
            self.is_launched = False

        # 좌벽
        if self.pos.x - self.radius < 0:
            self.pos.x = self.radius
            n = pygame.Vector2(1, 0)
            v_n = self.vel.dot(n)
            if v_n < 0:
                self.vel -= (1 + RESTIUTION) * v_n * n
            self.control_enabled = True
            self.launch_timer = 0.0
            self.is_launched = False

        # 우벽
        if self.pos.x + self.radius > WIDTH:
            self.pos.x = WIDTH - self.radius
            n = pygame.Vector2(-1, 0)
            v_n = self.vel.dot(n)
            if v_n < 0:
                self.vel -= (1 + RESTIUTION) * v_n * n
            self.control_enabled = True
            self.launch_timer = 0.0
            self.is_launched = False

    def collide_with_blocks(self, blocks, boost_blocks, deadly_blocks=None):
        """원-사각 충돌: 침투 보정 후 노멀 성분 반사(마찰 없음).
           ShooterBlock 포획은 launch_timer로 재포획 방지.
        """
        for block in blocks:
            is_colliding, normal = block.check_collision(self.pos, self.radius)
            if is_colliding and normal is not None:
                # ShooterBlock 재포획을 방지: 발사 후 잠깐 무시(launch_timer > 0이면 무시)
                if isinstance(block, ShooterBlock) and (not self.is_captured) and (self.launch_timer <= 0.0):
                    self.is_captured = True
                    self.captive_block = block
                    self.control_enabled = False
                    self.is_launched = False
                    # 공을 블록 중앙으로 옮기고 속도 0
                    self.pos = pygame.Vector2(block.rect.centerx, block.rect.centery)
                    self.vel = pygame.Vector2(0, 0)
                    block.has_ball = True
                    return

                # 기존 블록 충돌 처리 (간단한 침투 보정 + 반사)
                closest = block.get_closest_point(self.pos)
                dist_vec = self.pos - closest
                dist_sq = dist_vec.length_squared()

                if dist_sq > 0:
                    dist = math.sqrt(dist_sq)
                    overlap = self.radius - dist
                    if overlap > 0:
                        self.pos += normal * (overlap + 0.1)
                else:
                    self.pos += normal * (self.radius + 0.1)

                v_n = self.vel.dot(normal)
                if v_n < 0:
                    self.vel -= (1 + RESTIUTION) * v_n * normal
                    if normal.y < -0.5:
                        self.vel.y = -self.base_bounce_speed
                    elif normal.y > 0.5:
                        self.vel.y = self.base_bounce_speed
                    # 블록에 닿았으니 조작 허용, 발사 상태 해제
                    self.control_enabled = True
                    self.launch_timer = 0.0
                    self.is_launched = False

        # BoostBlock 픽업 처리 (기존 AABB 방식 유지)
        for boost in list(boost_blocks):
            a = AABB(self.pos.x - self.radius,
                     self.pos.y - self.radius,
                     self.pos.x + self.radius,
                     self.pos.y + self.radius)

            b = AABB.from_rect(boost.rect)

            if collision_aabb_aabb(a, b):
                self.has_dash = True
                boost_blocks.remove(boost)

    def draw(self, surface):
        color = (255, 0, 0) if self.has_dash else (255, 255, 255)
        pygame.draw.circle(surface, color, self.pos, self.radius)
        pygame.draw.circle(surface, (0, 0, 0), self.pos, self.radius, 2)


# 기존 DeadlyBlock은 그대로 둠
class DeadlyBlock(Block):
    def __init__(self, x, y, width, height, color=(200, 30, 30)):
        super().__init__(x, y, width, height, color)

    def _draw_dashed_rect(self, surface, rect, color, width=2, dash_len=8, gap=6):
        # 각 변을 따라 대시 라인 그리기
        x0, y0, w, h = rect.left, rect.top, rect.width, rect.height
        # top
        i = 0
        while i < w:
            sx = x0 + i
            ex = x0 + min(i + dash_len, w)
            pygame.draw.line(surface, color, (sx, y0), (ex, y0), width)
            i += dash_len + gap
        # bottom
        i = 0
        while i < w:
            sx = x0 + i
            ex = x0 + min(i + dash_len, w)
            pygame.draw.line(surface, color, (sx, y0 + h), (ex, y0 + h), width)
            i += dash_len + gap
        # left
        i = 0
        while i < h:
            sy = y0 + i
            ey = y0 + min(i + dash_len, h)
            pygame.draw.line(surface, color, (x0, sy), (x0, ey), width)
            i += dash_len + gap
        # right
        i = 0
        while i < h:
            sy = y0 + i
            ey = y0 + min(i + dash_len, h)
            pygame.draw.line(surface, color, (x0 + w, sy), (x0 + w, ey), width)
            i += dash_len + gap

    def _draw_lightning(self, surface, rect, color=(255, 255, 0)):
        # 번개 아이콘을 사각형 중앙에 그림 (크기 증대 및 수평 확장)
        cx = rect.centerx
        cy = rect.centery
        # 이전보다 크게: rect 크기의 비율을 키움
        s = min(rect.width, rect.height) * 0.75
        # 수평 확장 비율을 크게 하여 좌우로 더 넓게 보이도록 조정
        hx = 0.5
        pts = [
            (cx - s * hx * 0.5, cy - s * 0.55),
            (cx + s * hx * 0.6, cy - s * 0.05),
            (cx - s * hx * 0.15, cy - s * 0.05),
            (cx + s * hx * 0.7, cy + s * 0.55),
            (cx - s * hx * 0.25, cy + s * 0.10),
            (cx + s * hx * 0.15, cy + s * 0.10),
        ]
        pygame.draw.polygon(surface, color, pts)
        pygame.draw.polygon(surface, (0, 0, 0), pts, 2)

    def draw(self, surface):
        # 점선 사각을 그리고 이미지(또는 폴리곤)를 중앙에 표시
        self._draw_dashed_rect(surface, self.rect, self.color, width=3, dash_len=10, gap=6)
        self._draw_lightning(surface, self.rect)


# 새 클래스: ShooterBlock (블록 내부로 공을 포획하고 조준/발사)
class ShooterBlock(Block):
    def __init__(self, x, y, width, height, color=(70,130,180)):
        super().__init__(x, y, width, height, color)
        self.aim_angle = 0.0          # radians
        self.aim_speed = math.radians(160.0)  # rad/s 회전 속도
        # 더 멀리 발사되도록 속도 증가 및 시작 오프셋 추가
        self.launch_speed = 1000.0
        # 블록 중심에서 바깥으로 공을 얼마나 멀리 배치할지 (블록 크기 비율)
        self.launch_offset = 1.1
        self.has_ball = False         # 현재 공을 품고 있는지

    def update(self, dt):
        # 공이 들어있을 때만 조준 회전
        if self.has_ball:
            self.aim_angle = (self.aim_angle + self.aim_speed * dt) % (2 * math.pi)

    def draw(self, surface):
        # 기본 블록 그리기
        super().draw(surface)
        # 조준 표시: 공을 품고 있을때만 회전선(조준) 표시
        if self.has_ball:
            cx = self.rect.centerx
            cy = self.rect.centery
            length = max(self.rect.width, self.rect.height) * 0.7
            dx = math.cos(self.aim_angle) * length
            dy = math.sin(self.aim_angle) * length
            pygame.draw.line(surface, (255, 220, 0), (cx, cy), (cx + dx, cy + dy), 4)
            # 조준 끝에 화살표 원
            pygame.draw.circle(surface, (255, 180, 0), (int(cx + dx), int(cy + dy)), 6)


# 새로 추가: 움직이는 치명적 블록 (중력 적용, 땅에 닿으면 broken)
class DynamicDeadlyBlock(DeadlyBlock):
    """파란 점선 블록(각 면 중앙에 작은 notch). 떨어졌다가 바닥에 닿으면 broken -> 조각으로 분해"""
    def __init__(self, x, y, width, height, color=(70, 140, 255), vx=0.0, vy=0.0, respawn_delay=1.0):
        super().__init__(x, y, width, height, color)
        self.spawn_pos = pygame.Vector2(x, y)
        self.pos = pygame.Vector2(x, y)
        self.vel = pygame.Vector2(vx, vy)
        self.initial_vel = pygame.Vector2(vx, vy)
        self.broken = False
        self.active = True
        self.is_dynamic = True
        self.respawn_delay = float(respawn_delay)
        self.respawn_timer = 0.0

        # 조각 생성 관련
        self.pieces_spawned = False

    def update(self, dt):
        if not self.active:
            if self.respawn_timer > 0.0:
                self.respawn_timer -= dt
            if self.respawn_timer <= 0.0 and self.broken:
                self._respawn()
            return

        # 중력 적용
        self.vel.y += GRAVITY * dt
        self.pos += self.vel * dt
        self.rect.x = int(self.pos.x)
        self.rect.y = int(self.pos.y)

        # 바닥에 닿으면 파괴(조각 분해 시작)
        if self.rect.bottom >= GROUND_Y:
            self.broken = True
            self.active = False
            self.respawn_timer = self.respawn_delay

    def _respawn(self):
        self.pos = pygame.Vector2(self.spawn_pos)
        self.vel = pygame.Vector2(self.initial_vel)
        self.rect.topleft = (int(self.pos.x), int(self.pos.y))
        self.broken = False
        self.active = True
        self.pieces_spawned = False

    def _draw_notched_dashed_rect(self, surface, rect, color, width=3, dash_len=12, gap=8, notch=14):
        x0, y0, w, h = rect.left, rect.top, rect.width, rect.height
        cx = x0 + w // 2
        cy = y0 + h // 2

        # helper: draw dashed horizontal between xstart..xend at y
        def dash_h(xstart, xend, y):
            x = xstart
            while x < xend:
                ex = min(x + dash_len, xend)
                pygame.draw.line(surface, color, (x, y), (ex, y), width)
                x += dash_len + gap

        # helper: draw dashed vertical between ystart..yend at x
        def dash_v(ystart, yend, x):
            y = ystart
            while y < yend:
                ey = min(y + dash_len, yend)
                pygame.draw.line(surface, color, (x, y), (x, ey), width)
                y += dash_len + gap

        # Top: left segment, right segment (leave notch around cx)
        dash_h(x0, cx - notch // 2, y0)
        dash_h(cx + notch // 2, x0 + w, y0)
        # Bottom
        dash_h(x0, cx - notch // 2, y0 + h)
        dash_h(cx + notch // 2, x0 + w, y0 + h)
        # Left
        dash_v(y0, cy - notch // 2, x0)
        dash_v(cy + notch // 2, y0 + h, x0)
        # Right
        dash_v(y0, cy - notch // 2, x0 + w)
        dash_v(cy + notch // 2, y0 + h, x0 + w)

        # Draw small inward cut-lines to emphasize notch (use background color)
        cut_len = notch // 2
        bg = BG_COLOR if 'BG_COLOR' in globals() else (0, 0, 0)
        # top notch inward
        pygame.draw.line(surface, bg, (cx, y0), (cx, y0 + cut_len), width)
        # bottom notch inward
        pygame.draw.line(surface, bg, (cx, y0 + h), (cx, y0 + h - cut_len), width)
        # left notch inward
        pygame.draw.line(surface, bg, (x0, cy), (x0 + cut_len, cy), width)
        # right notch inward
        pygame.draw.line(surface, bg, (x0 + w, cy), (x0 + w - cut_len, cy), width)

    def draw(self, surface):
        if not self.active:
            return
        # 내부 반투명 채움
        try:
            fill_surf = pygame.Surface((self.rect.width, self.rect.height), pygame.SRCALPHA)
            fill_color = (70, 140, 255, 90)
            fill_surf.fill(fill_color)
            surface.blit(fill_surf, self.rect.topleft)
        except Exception:
            pygame.draw.rect(surface, (70, 140, 255), self.rect)
        # 테두리
        self._draw_notched_dashed_rect(surface, self.rect, (70, 140, 255), width=3, dash_len=12, gap=8, notch=16)

    def spawn_pieces(self):
        """깨질 때 4개의 Piece 객체를 반환.
           초기 속도를 낮은 포물선 궤적으로 날아가도록 설정.
        """
        if self.pieces_spawned:
            return []
        self.pieces_spawned = True

        import random

        pieces = []
        w = self.rect.width // 2
        h = self.rect.height // 2
        sx, sy = self.rect.left, self.rect.top

        # block velocity (기존 블록의 순간 속도)
        block_v = pygame.Vector2(self.vel)
        block_center = pygame.Vector2(self.rect.center)

        # 파편 튀어오르는 기본 파라미터 (조정 가능)
        base_h_speed = 160.0    # 수평 기본 속도
        base_up_speed = 140.0   # 위로 튀는 초기 속도 (양수 -> 위)
        spread_factor = 1.0     # 좌우 퍼짐 계수

        for iy in range(2):
            for ix in range(2):
                px = sx + ix * w
                py = sy + iy * h
                piece_rect = pygame.Rect(px, py, w, h)
                center = pygame.Vector2(piece_rect.center)
                mass = 1.0
                I = mass * ( (w*w) + (h*h) ) / 12.0

                # x offset relative to block center (-1..1)
                rel_x = (center.x - block_center.x) / max(1.0, self.rect.width * 0.5)

                # 수평 속도: block의 수평성분에 더해 중심에서의 offset 기반으로 크게 퍼지게
                vx = rel_x * base_h_speed * spread_factor
                # 약간 랜덤 추가
                vx += (random.uniform(-0.25, 0.25) * base_h_speed)
                # 수평에 block의 기존 속도 일부 합침
                vx += block_v.x * 0.25

                # 수직 속도: 위쪽으로 약하게 튀기되 block의 수직 속도 영향 반영
                vy = - (base_up_speed * (0.7 + 0.6 * random.random()))  # 음수 = 위
                vy += block_v.y * 0.15  # block이 아래로 내려오는 경우 약간 보정

                init_vel = pygame.Vector2(vx, vy)

                # r vector from piece center to block center
                r = center - pygame.Vector2(block_center)
                r_cross = r.x * init_vel.y - r.y * init_vel.x
                
                init_ang_vel = (r_cross / I) * 0.6 if I != 0 else 0.0
                # clamp
                max_ang = 9.0
                if init_ang_vel > max_ang:
                    init_ang_vel = max_ang
                elif init_ang_vel < -max_ang:
                    init_ang_vel = -max_ang

                piece = Piece(center.x - w/2, center.y - h/2, w, h,
                              mass=mass, pos=center, vel=init_vel, angle=0.0, ang_vel=init_ang_vel)
                pieces.append(piece)

        return pieces


class Piece:
    """분해된 조각: 회전·중력·간단한 벽/지면 반사 처리 및 렌더(회전된 사각형)."""
    def __init__(self, x, y, w, h, mass=1.0, pos=None, vel=None, angle=0.0, ang_vel=0.0, color=(60,160,230, 200)):
        self.w = int(w)
        self.h = int(h)
        self.mass = float(mass)
        self.pos = pygame.Vector2(pos if pos is not None else (x, y))
        self.vel = pygame.Vector2(vel if vel is not None else (0.0, 0.0))
        self.angle = float(angle)

        # initialize angular velocity with slightly larger scaling and higher clamp
        # -> 회전 초깃값을 좀 더 주어 시각적으로 자연스럽게 보이도록 함
        self.ang_vel = float(ang_vel) * 0.85
        self._max_ang_vel = 9.0
        if self.ang_vel > self._max_ang_vel:
            self.ang_vel = self._max_ang_vel
        elif self.ang_vel < -self._max_ang_vel:
            self.ang_vel = -self._max_ang_vel

        self.color = color
        # moment of inertia
        self.I = self.mass * ((self.w * self.w) + (self.h * self.h)) / 12.0
        # 조각 수명: 1.2초로 약간 연장해 애니메이션이 더 잘 보이게 함
        self.life = 1.2

    def update(self, dt):
        # apply gravity (linear)
        self.vel.y += GRAVITY * dt
        self.pos += self.vel * dt

        # integrate angle
        self.angle += self.ang_vel * dt

        # angular damping: 느리게 감소하도록 낮은 damping 사용 -> 회전이 더 자연스럽게 보임
        ang_damping = 0.8
        factor = max(0.0, 1.0 - ang_damping * dt)
        self.ang_vel *= factor

        # clamp angular velocity to avoid spikes
        if abs(self.ang_vel) > getattr(self, "_max_ang_vel", 6.0):
            self.ang_vel = math.copysign(getattr(self, "_max_ang_vel", 6.0), self.ang_vel)

        # simple world bounds collision with restitution
        half_h = self.h / 2.0
        half_w = self.w / 2.0

        # floor
        if self.pos.y + half_h >= GROUND_Y:
            self.pos.y = GROUND_Y - half_h
            # 정상적으로 아래로 내려오는 경우: 반사
            if self.vel.y > 1.0:
                self.vel.y = -self.vel.y * RESTIUTION
                self.ang_vel *= 0.6
            else:
                # 거의 수직 이동이 없는 상태에서 좌우로 미끄러지는 조각들에
                # 약간의 '통통' 튀는 효과를 줘 자연스럽게 보이게 함
                # 수평 속도가 충분하면 위로 작은 킥을 주고 수평에 작은 산란 추가
                import random
                min_bounce = 120.0
                horizontal_threshold = 50.0
                if abs(self.vel.x) > horizontal_threshold:
                    kick = min_bounce + abs(self.vel.x) * 0.12
                    # 위로 튀기기
                    self.vel.y = -kick * (0.85 + 0.3 * random.random())
                    # 수평에 소량의 산란 추가 (밖으로 밀려나게)
                    self.vel.x += math.copysign(30.0 * (0.6 + 0.8 * random.random()), self.vel.x)
                    # 회전도 약간 증가시켜 더 역동적으로 보이게
                    self.ang_vel += math.copysign(1.2 + random.random() * 1.6, self.vel.x)
                else:
                    # 거의 정지한 경우엔 마찰로 감속
                    self.vel.y = 0.0
                    self.vel.x *= 0.55

        # ceiling
        if self.pos.y - half_h <= 0:
            self.pos.y = half_h
            if self.vel.y < 0:
                self.vel.y = -self.vel.y * RESTIUTION

        # left wall
        if self.pos.x - half_w <= 0:
            self.pos.x = half_w
            if self.vel.x < 0:
                self.vel.x = -self.vel.x * RESTIUTION

        # right wall
        if self.pos.x + half_w >= WIDTH:
            self.pos.x = WIDTH - half_w
            if self.vel.x > 0:
                self.vel.x = -self.vel.x * RESTIUTION

        # lifetime decay
        self.life -= dt

    def draw(self, surface):
        # render rotated rect
        surf = pygame.Surface((self.w, self.h), pygame.SRCALPHA)
        surf.fill(self.color)
        rot = pygame.transform.rotate(surf, math.degrees(self.angle))
        rrect = rot.get_rect(center=(int(self.pos.x), int(self.pos.y)))
        surface.blit(rot, rrect.topleft)