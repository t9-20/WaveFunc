final int[] opposite = { 2, 3, 0, 1 }; //<>//

boolean[][] wave;
int[] Output;

Tile[] paterns;

boolean[][][] paterns_relation;
int[][][] compatible;

int gridX;
int gridY;
int cellSizeX = 250;
int cellSizeY = 250;

StackInt propaStack;
StackInt initStack;

int[] delta;
String[] reader;

TileSetReader tileSet;
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

  delta = new int[]{-1, -gridX, 1, gridX};
  reader = new String[]{"up", "right", "down", "left"};

  //chargement des tile
  tileSet = new TileSetReader("tileset.json");

  //initialise la liste des patern (paterne = tile)
  //creation des object de tuile
  paterns = tileSet.GeneratePatern();
  paterns_relation = tileSet.generateRelation();

  // finale initialisation
  wave = new boolean[gridX*gridY][paterns.length];
  Output = new int[wave.length];


  for (int i = 0; i < wave.length; i++ ) {
    for (int j = 0; j < paterns.length; j++ ) {
      wave[i][j] = true;
    }
    Output[i] = -1;
  }

  compatible = new int[wave.length][paterns.length][4];
  ResetCompatible();

  propaStack = new StackInt((paterns.length * wave.length));
  initStack = new StackInt((paterns.length * wave.length));
  println("initialised");
}

//fonction d'init
void ResetCompatible() {
  for (int i = 0; i < wave.length; i++ ) {
    for (int j = 0; j < paterns.length; j++ ) {
      for (int d = 0; d < 4; d++) {
        int total = 0;
        for (int f = 0; f < paterns.length; f++ ) {
          if (paterns_relation[opposite[d]][j][f])
            total ++;
        }
        //println(total);
        compatible[i][j][d] = total;
      }
    }
  }
}


void draw() {
  background(128);
  delay(5000);
  randomSeed(1);

  int min = MinimalEntropy();// selection la cellule a éfondrer
  if (min != -1) {
    collapseCell(min);// on effondre la cellule
    
    propagate(); // et on propage
    printWave();// imprime l'etat de l'image
    colorCell(min, color(0, 255, 0, 128));
    
  } else {
    
    for (int i = 0; i < wave.length; i++) {
      for (int t = 0; t < paterns.length; t++) {
        if (wave[i][t]) {
          Output[i] = t;
          break;
        }
      }
    }
    printOutput(); // resultat finale
    println("stop");
    noLoop();
  }
  
  //showRealtion();
  //saveFrame();
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
    if (entropy >= 2 && entropy < currentMin) {
      currentMin = entropy ;
      minIndex = new ArrayList();
      minIndex.add(i);
    } else if (entropy == currentMin) {
      minIndex.add(i);
    }
  }

  int randomChoice = int(random(0, minIndex.size()));
  return minIndex.get(randomChoice);
}

int totalValueCell(int i) {
  // nombre de coeficient positif (true)
  int total = 0;
  for (int j = 0; j < paterns.length; j++ ) {
    if (wave[i][j]) {
      total += paterns[j].proba;
    }
  }
  return total;
}

int[] validCoeficientCell(int i) {
  int[] valid = new int[paterns.length];
  int w = 0;
  for (int j = 0; j < paterns.length; j++ ) {
    if (wave[i][j]) {
      valid[w] = j;
      w++;
    }
  }
  return valid;
}

void collapseCell(int pos) {
  float choice = random(totalValueCell(pos));
  int[] valid = validCoeficientCell(pos);

  int landedPatern = 0;
  while (choice > paterns[valid[landedPatern]].proba) {
    choice -= paterns[valid[landedPatern]].proba;
    landedPatern ++;
  }

  for (int t = 0; t < paterns.length; t++) {
    if (wave[pos][t] != (t == valid[landedPatern])) {
      Ban(pos, t);
    }
  }
  println("collapsed !", pos, valid[landedPatern]);
}

void propagate() {

  while (!propaStack.isEmpty()) {
    int pos = propaStack.depiler();
    int Ban = initStack.depiler();
    //println(propaStack.size());
    for (int d = 0; d < 4; d++)
    {
      int x = (pos + delta[d]) % gridX;
      int y = (pos + delta[d]) / gridX;

      if (x < 0 || y < 0 || x + 2> gridX || y + 2> gridY) continue;

      if (x < 0) x += gridX;
      else if (x >= gridX) x -= gridX;
      if (y < 0) y += gridY;
      else if (y >= gridY) y -= gridY;

      int nPos = x + (y*gridX);
      boolean[] r = paterns_relation[d][Ban];
      int[][] compat = compatible[nPos];

      for (int i = 0; i < paterns.length; i++) {
        if (r[i]) {

          int[] comp = compat[i];

          comp[d]--;

          if (comp[d] == 0) {
            Ban(nPos, i);
            println(nPos,paterns[i].name);
          }
        }
      }
    }
  }
}

void Ban(int i, int t) {

  wave[i][t] = false;

  int[] comp = compatible[i][t];
  for (int d = 0; d < 4; d++) {
    comp[d] = 0;
  }
  propaStack.empiler(i);
  initStack.empiler(t);
}


// output
void showRealtion() {
  background(0);
  float gX = width/paterns.length-5;
  float gY = height/paterns.length-5;

  float[] dx = {0.25, 0.75, 0.25, 0};
  float[] dy = {0, 0.25, 0.75, 0.25};
  
  float[] sx = {2, 4, 2, 4};
  float[] sy = {4, 2, 4, 2};
  
  color[] dc = {color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(255, 0, 255)};

  fill(0, 0, 0);
  stroke(255);
  strokeWeight(2);
  for (int i = 1; i < paterns.length+1; i++ ) {
    line(i*gX, 0, i*gX, height);
    line(0, i*gY, width, i*gY);
    printTexture(i, 0, i-1, gX, gY);
    printTexture(0, i, i-1, gX, gY);
  }
  for (int w = 0; w < 4; w++) {
    fill(dc[w]);
    for (int x = 1; x < paterns.length+1; x++ ) {
      for (int y = 1; y < paterns.length+1; y++ ) {
        if (paterns_relation[w][x-1][y-1]) {
          rect((x+dx[w])*gX, (y+dy[w])*gY, gX/sx[w], gY/sy[w]);
        }
      }
    }
  }
}

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

void printCellCompat(int x, int y) {
  //print 1 cell with image + entropy
  tint(255, 25);
  for (int j = 0; j < paterns.length; j++ ) {
    if (wave[x + (y * gridX)][j]) {
      printTexture(x, y, j);
    }
  }
  textAlign(CENTER, CENTER);
  textSize(cellSizeY*0.2);
  tint(255, 255);
  for (int j = 0; j < 10; j++ ) {
    for (int d = 0; d < 4; d++) {
      text(compatible[x + (y * gridX)][j][d], (x+(d/4f))*cellSizeX, (y+float(j)/10)*cellSizeY);
    }
  }
}

void printCell(int x, int y) {
  //print 1 cell with image + entropy
  tint(255, 25);
  for (int j = 0; j < paterns.length; j++ ) {
    if (wave[x + (y * gridX)][j]) {
      printTexture(x, y, j);
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

void printOutput() {
  stroke(255);
  for (int x = 0; x < gridX; x++ ) {
    for (int y = 0; y < gridY; y++ ) {
      if (Output[x+y*gridX] != -1) {
        printTexture(x, y, Output[x+(y*gridX)]);
      } else {
        colorCell(x+y*gridX, color(255, 255, 255));
      }
    }
  }
}

void printTexture(int x, int y, int j) {
  printTexture(x, y, j, cellSizeX, cellSizeY);
}

void printTexture(float x, float y, int j, float xs, float ys) {
  beginShape();
  texture(paterns[j].display);
  if (paterns[j].rotation == 0) {
    vertex(x*xs, y*ys, 0, 0);
    vertex((x+1)*xs, y*ys, 1, 0);
    vertex((x+1)*xs, (y+1)*ys, 1, 1);
    vertex(x*xs, (y+1)*ys, 0, 1);
  } else if (paterns[j].rotation == 1) {
    vertex(x*xs, y*ys, 1, 0);
    vertex((x+1)*xs, y*ys, 1, 1);
    vertex((x+1)*xs, (y+1)*ys, 0, 1);
    vertex(x*xs, (y+1)*ys, 0, 0);
  } else if (paterns[j].rotation == 2) {
    vertex(x*xs, y*ys, 1, 1);
    vertex((x+1)*xs, y*ys, 0, 1);
    vertex((x+1)*xs, (y+1)*ys, 0, 0);
    vertex(x*xs, (y+1)*ys, 1, 0);
  } else if (paterns[j].rotation == 3) {
    vertex(x*xs, y*ys, 0, 1);
    vertex((x+1)*xs, y*ys, 0, 0);
    vertex((x+1)*xs, (y+1)*ys, 1, 0);
    vertex(x*xs, (y+1)*ys, 1, 1);
  }
  endShape();
}
