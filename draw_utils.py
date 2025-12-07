import pygame
import math
from constants import WIDTH, HEIGHT, SUCCESS_BG

def draw_star(surface, center, radius, color):
    cx, cy = center
    points = []
    for i in range(10):
        angle = math.pi / 2 + i * math.pi / 5
        r = radius if i % 2 == 0 else radius * 0.5
        x = cx + r * math.cos(angle)
        y = cy - r * math.sin(angle)
        points.append((x, y))
    pygame.draw.polygon(surface, color, points)
    pygame.draw.polygon(surface, (0, 0, 0), points, 1)


def draw_success_screen(surface):
    surface.fill(SUCCESS_BG)
    font_big = pygame.font.SysFont("consolas", 48)
    font_small = pygame.font.SysFont("consolas", 24)
    text = font_big.render("SUCCESS!", True, (255, 255, 255))
    sub = font_small.render("Press Q to exit.", True, (200, 200, 200))
    rect = text.get_rect(center=(WIDTH // 2, HEIGHT // 2 - 20))
    rect_sub = sub.get_rect(center=(WIDTH // 2, HEIGHT // 2 + 30))
    surface.blit(text, rect)
    surface.blit(sub, rect_sub)