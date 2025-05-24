class Tile {
  PImage display;
  int proba;
  byte rotation;
  String name;

  Tile(String adress,int proba,byte rotation,String name) {
    display = loadImage(adress+".png");
    this.proba = proba;
    this.rotation = rotation;
    this.name = name;
  }

  Tile(color imgColor,int proba,String name) {
    
    display = createImage(264, 264, RGB);
    display.loadPixels();
    for (int i = 0; i < display.pixels.length; i++) {
      display.pixels[i] = imgColor;
    }
    display.updatePixels();
    this.proba = proba;
    this.name = name;
  }
}
