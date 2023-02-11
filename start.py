import arcade
import json

WIDTH = 800
HEIGHT = 800

class GameWindow(arcade.Window):
    def __init__(self):
        super().__init__(WIDTH, HEIGHT, "arcade testing game")

my_window = GameWindow()
arcade.run()
