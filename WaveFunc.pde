
boolean[][] wave;
int[] Output;

Tile[] paterns;

byte[][] patern_relation;

int gridX;
int gridY;
int cellSizeX = 50;
int cellSizeY = 50;

//Read the input bitmap and count NxN patterns.
//(optional) Augment pattern data with rotations and reflections.

//Create an array with the dimensions of the output (called "wave" in the source).
//Each element of this array represents a state of an NxN region in the output.
//A state of an NxN region is a superposition of NxN patterns of the input with boolean coefficients
//(so a state of a pixel in the output is a superposition of input colors with real coefficients).
//False coefficient means that the corresponding pattern is forbidden,
//true coefficient means that the corresponding pattern is not yet forbidden.


//Initialize the wave in the completely unobserved state, i.e. with all the boolean coefficients being true.

void setup() {
  size(1000, 1000, P2D);
  //fullScreen(P2D);

  gridX = width/cellSizeX;
  gridY = height/cellSizeY;

  paterns = new Tile[6];
  for (int i = 0; i < paterns.length; i++) {
    paterns[i] = new Tile("tile_"+i+".png", 10);
  }

  patern_relation = new byte[6][];

  wave = new boolean[gridX*gridY][patern_relation.length];
  Output = new int[wave.length];

  for (int i = 0; i < wave.length; i++ ) {
    for (int j = 0; j < patern_relation.length; j++ ) {
        wave[i][j] = true;
    }
  }
}

int calulateEntropy(int i) {
  int entropy = 0;
  for (int j = 0; j < paterns.length; j++ ) {
    if (wave[i][j]) {
      entropy ++;
    }
  }
  return entropy;
}

int MinimalEntropy() {
  ArrayList<Integer> minIndex = new ArrayList();
  minIndex.add(-1);
  int currentMin = paterns.length+1;
 
  for (int i = 0; i < wave.length; i++) {
    int entropy = calulateEntropy(i);
    if (entropy != 0 && entropy < currentMin) {
      currentMin = entropy ;
      minIndex = new ArrayList();
      minIndex.add(i);
    } else if (entropy == currentMin) {
      minIndex.add(i);
    }
  }

  for (int i = 0; i < minIndex.size(); i++) {
    colorCell(minIndex.get(i), color(0, 0, 255));
  }
  int randomChoice = int(random(0, minIndex.size()));
  return minIndex.get(randomChoice);
}

int totalValueCell(int i) {
  int total = 0;
  for (int j = 0; j < paterns.length; j++ ) {
    if (wave[i][j]) {
      total += paterns[j].proba;
    }
  }
  return total;
}

void collapseCell(int pos) {
  int choice = int(random(totalValueCell(pos)));

  int landedPatern = 0;
  while (choice > paterns[landedPatern].proba) {
    choice -= paterns[landedPatern].proba;
    landedPatern ++;
  }

  println(landedPatern);
  Output[pos] = landedPatern;

  for (int j = 0; j < patern_relation.length; j++ ) {
    wave[pos][j] = false;
  }
}


void draw() {
  background(128);
  
  int min = MinimalEntropy();
  if (min != -1) {
    printWave();
    colorCell(min, color(255, 0, 0));
    collapseCell(min);
  } else {
    printOutput();
  }
  
}
//Repeat the following steps:
//Observation:
//Find a wave element with the minimal nonzero entropy.
//If there is no such elements (if all elements have zero or undefined entropy) then break the cycle (4) and go to step (5).
//Collapse this element into a definite state according to its coefficients and the distribution of NxN patterns in the input.
//Propagation:
//propagate information gained on the previous observation step.
//By now all the wave elements are
//either in a completely observed state (all the coefficients except one being zero)
//In the first case return the output.
//or in the contradictory state (all the coefficients being zero).
//In the second case finish the work without returning anything.


// print things

void printEntropy() {
  // only prints the waves entropy
  fill(0);
  textAlign(CENTER);
  textSize(cellSizeY*0.4);
  for (int x = 0; x < gridX; x++ ) {
    for (int y = 0; y < gridY; y++ ) {
      strokeWeight(5);
      fill(255);
      rect(x*cellSizeX, y*cellSizeY, cellSizeX, cellSizeY);
      strokeWeight(1);
      fill(0);
      text(calulateEntropy(x+y*gridX), (x+0.5)*cellSizeX, (y+0.7)*cellSizeY);
    }
  }
  fill(255);
}

void printWave() {
  //print the wave with image + entropy
  fill(0);
  textAlign(CENTER);
  textSize(40);
  textureMode(NORMAL);

  for (int x = 0; x < gridX; x++ ) {
    for (int y = 0; y < gridY; y++ ) {
      printCell(x, y);
    }
  }
}

void printCell(int x, int y) {
  //print 1 cell with image + entropy
  tint(255, 128);
  for (int j = 0; j < patern_relation.length; j++ ) {
    if (wave[x + (y * gridX)][j]) {
      beginShape();
      texture(paterns[j].display);
      vertex(x*cellSizeX, y*cellSizeY, 0, 0);
      vertex((x+1)*cellSizeX, y*cellSizeY, 1, 0);
      vertex((x+1)*cellSizeX, (y+1)*cellSizeY, 1, 1);
      vertex(x*cellSizeX, (y+1)*cellSizeY, 0, 1);
      endShape();
    }
  }
  tint(255, 255);
  text(calulateEntropy(x+y*gridX), (x+0.5)*cellSizeX, (y+0.7)*cellSizeY);
}

void colorCell(int x, int y, color tint) {
  tint(255, 255);
  fill(tint);
  rect(x*cellSizeX, y*cellSizeY, cellSizeX, cellSizeY);
}

void colorCell(int pos, color tint) {
  int x = pos%gridX;
  int y = pos/gridX;
  colorCell(x, y, tint);
}

void printOutput(){
  for (int x = 0; x < gridX; x++ ) {
    for (int y = 0; y < gridY; y++ ) {
      printOutputCell(x,y);
    }
  } 
}

void printOutputCell(int x, int y){
  beginShape();
  texture(paterns[Output[x+y*gridX]].display);
  vertex(x*cellSizeX, y*cellSizeY, 0, 0);
  vertex((x+1)*cellSizeX, y*cellSizeY, 1, 0);
  vertex((x+1)*cellSizeX, (y+1)*cellSizeY, 1, 1);
  vertex(x*cellSizeX, (y+1)*cellSizeY, 0, 1);
  endShape();
}
