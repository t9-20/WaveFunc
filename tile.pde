class Tile {
  PImage display;
  int proba;
  byte rotation;

  Tile(String adress,int proba,byte rotation) {
    display = loadImage(adress+".png");
    this.proba = proba;
    this.rotation = rotation;
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
