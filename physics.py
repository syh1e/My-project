import pygame

class AABB:
    """Axis-Aligned Bounding Box"""
    def __init__(self, min_x, min_y, max_x, max_y):
        self.min = pygame.Vector2(min_x, min_y)
        self.max = pygame.Vector2(max_x, max_y)

    @classmethod
    def from_rect(cls, rect):
        return cls(rect.left, rect.top, rect.right, rect.bottom)


def collision_aabb_aabb(a: AABB, b: AABB) -> bool:
    if (a.max.x < b.min.x) or (b.max.x < a.min.x):
        return False
    if (a.max.y < b.min.y) or (b.max.y < a.min.y):
        return False
    return True

# 새로 추가: 2D 원-원(구) 충돌 검사 (성능을 위해 제곱거리 사용)
def circle_circle_collision(pos1: pygame.Vector2, r1: float, pos2: pygame.Vector2, r2: float) -> bool:
    """두 원의 충돌 여부를 반환합니다. pos는 Vector2, r은 반지름."""
    rsum = r1 + r2
    return (pos1 - pos2).length_squared() <= (rsum * rsum)