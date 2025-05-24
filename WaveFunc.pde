 //<>//
final int[] opposite = { 2, 3, 0, 1 };

boolean[][] wave;
int[] Output;

Tile[] paterns;

boolean[][][] paterns_relation;
int[][][] compatible;

int gridX;
int gridY;
int cellSizeX = 50;
int cellSizeY = 50;

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

  compatible = new int[wave.length][paterns.length][4];

  // finale initialisation
  wave = new boolean[gridX*gridY][paterns.length];
  Output = new int[wave.length];

  for (int i = 0; i < wave.length; i++ ) {
    for (int j = 0; j < paterns.length; j++ ) {
      wave[i][j] = true;
    }
  }

  propaStack = new StackInt(true, (paterns.length * wave.length));
  initStack = new StackInt(true, (paterns.length * wave.length));
}

//fonction d'init
void ResetCompatible() {
  for (int i = 0; i < wave.length; i++ ) {
    for (int j = 0; j < paterns.length; j++ ) {
      for (int d = 0; d < 4; d++) {
        
      }
    }
  }
  
  
  compatible[i][j][d] 
}


void draw() {
  background(128);

  int min = MinimalEntropy();// selection la cellule a éfondrer
  if (min != -1) {
    printWave();// imprime l'etat de l'image
    colorCell(min, color(0, 0, 255));
    int t = collapseCell(min);// on effondre la cellule
    propagate(min, t); // et on propage
  } else {
    printOutput(); // resultat finale
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

int collapseCell(int pos) {
  int choice = int(random(totalValueCell(pos)));
  int[] valid = validCoeficientCell(pos);

  int landedPatern = 0;
  while (choice > paterns[valid[landedPatern]].proba) {
    choice -= paterns[valid[landedPatern]].proba;
    landedPatern ++;
  }

  println(paterns[valid[landedPatern]].name);
  Output[pos] = valid[landedPatern];

  for (int j = 0; j < paterns.length; j++ ) {
    wave[pos][j] = false;
  }

  //wave[pos][valid[landedPatern]] = false;

  return valid[landedPatern];
}

void propagate(int initPos, int initBan ) {
  propaStack.empiler(initPos);
  initStack.empiler(initBan);

  while (!propaStack.isEmpty()) {
    int pos = propaStack.depiler();
    int Ban = initStack.depiler();
    for (int d = 0; d < 4; d++)
    {
      int x = (pos + delta[d]) % gridX;
      int y = (pos + delta[d]) / gridX;

      if (x < 0) x += gridX;
      else if (x >= gridX) x -= gridX;
      if (y < 0) y += gridY;
      else if (y >= gridY) y -= gridY;

      int nPos = x + (y*gridX);

      for (int i = 0; i < paterns.length; i++) {
        if (paterns_relation[Ban][i][d]) {
          //println(x,y,nPos,nBan);
          if (wave[nPos][i] == true) {
            propaStack.empiler(nPos);
            initStack.empiler(i);
            wave[nPos][i] = false;
          }
        }
      }
    }
  }
  propaStack = new StackInt(true, (paterns.length * wave.length));
  initStack = new StackInt(true, (paterns.length * wave.length));
}



// output
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
  for (int x = 0; x < gridX; x++ ) {
    for (int y = 0; y < gridY; y++ ) {
      printTexture(x, y, Output[x+y*gridX]);
    }
  }
}

void printTexture(int x, int y, int j) {
  beginShape();
  texture(paterns[j].display);
  if (paterns[j].rotation == 0) {
    vertex(x*cellSizeX, y*cellSizeY, 0, 0);
    vertex((x+1)*cellSizeX, y*cellSizeY, 1, 0);
    vertex((x+1)*cellSizeX, (y+1)*cellSizeY, 1, 1);
    vertex(x*cellSizeX, (y+1)*cellSizeY, 0, 1);
  } else if (paterns[j].rotation == 1) {
    vertex(x*cellSizeX, y*cellSizeY, 1, 0);
    vertex((x+1)*cellSizeX, y*cellSizeY, 1, 1);
    vertex((x+1)*cellSizeX, (y+1)*cellSizeY, 0, 1);
    vertex(x*cellSizeX, (y+1)*cellSizeY, 0, 0);
  } else if (paterns[j].rotation == 2) {
    vertex(x*cellSizeX, y*cellSizeY, 1, 1);
    vertex((x+1)*cellSizeX, y*cellSizeY, 0, 1);
    vertex((x+1)*cellSizeX, (y+1)*cellSizeY, 0, 0);
    vertex(x*cellSizeX, (y+1)*cellSizeY, 1, 0);
  } else if (paterns[j].rotation == 3) {
    vertex(x*cellSizeX, y*cellSizeY, 0, 1);
    vertex((x+1)*cellSizeX, y*cellSizeY, 0, 0);
    vertex((x+1)*cellSizeX, (y+1)*cellSizeY, 1, 0);
    vertex(x*cellSizeX, (y+1)*cellSizeY, 1, 1);
  }
  endShape();
}
