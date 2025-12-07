import pygame
from entities import Block, BoostBlock, Ball, DeadlyBlock, DynamicDeadlyBlock, ShooterBlock

def setup_boost_block(blocks, boost_blocks):
    first = blocks[0]
    x = first.rect.x + first.rect.width // 2 - 20
    y = first.rect.y - 40
    boost_blocks.append(BoostBlock(x, y))


def reset_game():
    ball = Ball(100, 500)

    blocks = [
        Block(150, 520, 50, 30),
        Block(300, 480, 100, 30),
        Block(450, 440, 100, 30),
        Block(600, 400, 100, 30),
        Block(750, 360, 100, 30),
        Block(800, 320, 100, 30),
        Block(0, 320, 200, 20)
    ]

    # ShooterBlock 추가
    shooter = ShooterBlock(920, 300, 50, 50)
    blocks.append(shooter)

    boost_blocks = []
    setup_boost_block(blocks, boost_blocks)

    deadly_blocks = [
        DeadlyBlock(150, 280, 50, 40),
        DeadlyBlock(0, 500, 50, 50),
    ]

    falling = DynamicDeadlyBlock(650, 200, 48, 48, color=(200, 30, 30), vx=0, vy=0)
    deadly_blocks.append(falling)

    # 기존 별(목표)
    star_pos = pygame.Vector2(875, 260)
    # 추가 별
    star2_pos = pygame.Vector2(50, 270)

    star_radius = 18
    star_collected = False
    star2_collected = False
    success = False

    last_left_time = 0
    last_right_time = 0
    return ball, blocks, boost_blocks, deadly_blocks, star_pos, star2_pos, star_radius, star_collected, star2_collected, success, last_left_time, last_right_time