import arcade
import json

WIDTH = 800
HEIGHT = 800
TILESIZE = 60


class Tile(arcade.Sprite):
    def __init__(self, x, y):
        super().__init__("square.png", scale=(TILESIZE/10))
        self.center_x = (x * TILESIZE) + (TILESIZE/2)
        self.center_y = (y * TILESIZE) + (TILESIZE/2)

    def encode(self):
        return "tile"


class LevelEncoder(json.JSONEncoder):
    def default(self, object):
        if isinstance(object, Tile):
            return object.encode()
        return json.JSONEncoder.default(self, object)


def level_decoder(dct):
    if "tile" in dct:
        return Tile(0, 0)
    return dct


class GameWindow(arcade.Window):
    def __init__(self):
        super().__init__(WIDTH, HEIGHT, "mazegame")

        # create empty level
        self.level = []

        # create empty columns
        for i in range(int(WIDTH/TILESIZE)):
            col = []
            for j in range(int(HEIGHT/TILESIZE)):
                # fill with empty tiles
                col.append(None)
            self.level.append(col)

        self.tiles = arcade.SpriteList()

        self.mouse_x = 0
        self.mouse_y = 0
        self.mouse_pressed = False

    def on_draw(self):
        self.clear()

        self.tiles.draw()

    def on_update(self, delta_time):
        pass

    def on_mouse_release(self, mouse_x, mouse_y, button, modifiers):
        if button == arcade.MOUSE_BUTTON_LEFT:
            self.mouse_pressed = False

    def on_mouse_press(self, mouse_x, mouse_y, button, modifiers):
        if button == arcade.MOUSE_BUTTON_LEFT:
            self.mouse_pressed = True

        self.place_tile()

    def on_mouse_motion(self, mouse_x, mouse_y, dx, dy):
        self.mouse_x = mouse_x
        self.mouse_y = mouse_y

        self.place_tile()

    def on_key_press(self, key, modifiers):
        if key == arcade.key.S:
            success = self.save_level()

            if success:
                print("Saved level to file.")
        elif key == arcade.key.L:
            success = self.load_level()

            if success:
                print("Loaded level from file.")
            else:
                print("Error loading level")


    def save_level(self):
        try:
            with open("level.json", "w") as f:
                json.dump(self.level, f, cls=LevelEncoder)
            return True
        except:
            return False

    def load_level(self):
        # try:
        with open("level.json", "r") as f:
            self.level = json.load(f, object_hook=level_decoder)
            self.sync_tiles() # fix tiles that get instantiated at 0,0
        return True
        # except:
        #     return False

    def sync_tiles(self):
        for row_index, row in enumerate(self.level):
            for col_index, tile in enumerate(row):
                if tile is None:
                    continue
                try:
                    tile.center_x = row_index * TILESIZE
                    tile.center_y = col_index * TILESIZE
                except:
                    print(tile)

    def place_tile(self):
        if self.mouse_pressed:
            coord_x = int(self.mouse_x/TILESIZE)
            coord_y = int(self.mouse_y/TILESIZE)

            try:
                if self.level[coord_x][coord_y] is not None:
                    return

                new_tile = Tile(coord_x, coord_y)
                self.level[coord_x][coord_y] = new_tile

                self.tiles.append(new_tile)
            except IndexError:
                return


my_window = GameWindow()
arcade.run()
