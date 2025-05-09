class Tile {
  PImage display;
  int proba;

  Tile(String adress,int proba) {
    display = loadImage(adress);
    this.proba = proba;
  }

  Tile(color imgColor,int proba) {
    
    display = createImage(264, 264, RGB);
    display.loadPixels();
    for (int i = 0; i < display.pixels.length; i++) {
      display.pixels[i] = imgColor;
    }
    display.updatePixels();
    this.proba = proba;
  }
}
