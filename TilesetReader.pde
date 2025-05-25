class TileSetReader {

  JSONArray tileset;

  TileSetReader(String name) {
    tileset = loadJSONArray(name );
  }

  Tile[] GeneratePatern() {
    ArrayList<Tile> paternsArray = new ArrayList<Tile>();
    for (int i = 0; i < tileset.size(); i++) {

      JSONObject tile = tileset.getJSONObject(i);
      String symmetry = tile.getString("symmetry");

      if (symmetry.equals("X")) {
        paternsArray.add( new Tile( tile.getString("adress"),
          tile.getInt("probabilite"),
          byte(0),
          tile.getInt("id")+"x"));
      } else if (symmetry.equals("L")) {
        paternsArray.add( new Tile( tile.getString("adress"),
          tile.getInt("probabilite"),
          byte(0),
          tile.getInt("id")+"|"));
        paternsArray.add( new Tile( tile.getString("adress"),
          tile.getInt("probabilite"),
          byte(1),
          tile.getInt("id")+"-"));
      } else if (symmetry.equals("O")) {
        for (byte w = 0; w < 4; w++) {
          paternsArray.add( new Tile(tile.getString("adress"),
            tile.getInt("probabilite"), byte(w), tile.getInt("id")+reader[w].substring(0, 1) ));
        }
      }
    }
    Tile[] paternsList = new Tile[paternsArray.size()];
    for (int i = 0; i <  paternsArray.size(); i++) {
      paternsList[i] = paternsArray.get(i);
    }
    return paternsList;
  }

  boolean[][][] generateRelation() {
    boolean[][][] relation = new boolean[4][paterns.length][paterns.length];
    for (int i = 0; i < tileset.size(); i++) {
      JSONObject tile = tileset.getJSONObject(i);
      for (int r = 0; r < nLoopFromSymetry(tile); r++) {
        makeConnection(tile, r, relation);
      }
    }
    return relation;
  }

  void makeConnection(JSONObject tile, int rotation, boolean[][][] relation) {
    int indexT = getIndexTile(tile, rotation);
    for (byte j = 0; j < 4; j++) {
      String[] temp = getConectionList(tile, rotation, j);
      for (int i = 0; i < temp.length; i++) {
        int indexC = getIndexTile(temp[i]);
        relation[(rotation+j)%4][indexT][indexC] = true;
      }
    }
  }

  int getIndexTile(JSONObject tile, int rotation) {
    String tileName = getTileNames(tile)[rotation];
    return getIndexTile(tileName);
  }

  int getIndexTile(String tileName) {
    int retour = -1;
    for (int i = 0; i < paterns.length; i++) {
      if (paterns[i].name.equals(tileName)) {
        retour = i;
      }
    }
    return retour;
  }

  String[] getTileNames(JSONObject tile) {
    String[] retour = {};
    String symmetry = tile.getString("symmetry");
    if (symmetry.equals("X")) {
      retour = new String[1];
      retour[0] = tile.getInt("id")+"x";
    } else if (symmetry.equals("L")) {
      retour = new String[2];
      retour[0] = tile.getInt("id")+"|";
      retour[1] = tile.getInt("id")+"-";
    } else if (symmetry.equals("O")) {
      retour = new String[4];
      for (byte w = 0; w < 4; w++) {
        retour[w] = tile.getInt("id")+reader[w].substring(0, 1);
      }
    }
    return retour;
  }

  String[] getConectionList(JSONObject tile, int rotation, int j) {
    String[] intitList = transformJSONArrayToStringList(tile.getJSONArray(reader[j]));
    for (int i = 0; i < intitList.length; i++) {
      int Crotation = RotationFromName(intitList[i]);
      String symetry = SymetryFromName(intitList[i]);
      String id = IdFromName(intitList[i]);
      intitList[i] =  id + SimboleFromRotation((Crotation+rotation)%4, symetry);
    }
    return intitList;
  }


  String[] transformJSONArrayToStringList(JSONArray in) {
    String[] retour = new String[in.size()];
    for (int i = 0; i < in.size(); i++) {
      retour[i] = in.getString(i);
    }
    return retour;
  }

  String IdFromName(String tileName) {
    return tileName.substring(0, tileName.length()-1);
  }

  int RotationFromName(String tileName) {
    char lastChar = tileName.charAt(tileName.length()-1);
    if (lastChar == 'u' || lastChar == '|' || lastChar == 'x') {
      return 0;
    } else if (lastChar == 'l' || lastChar == '-') {
      return 1;
    } else if (lastChar == 'd') {
      return 2;
    } else if (lastChar == 'r') {
      return 3;
    } 
    return -1;
  }

  String SymetryFromName(String tileName) {
    char lastChar = tileName.charAt(tileName.length()-1);
    if (lastChar == 'u' || lastChar == 'l' || lastChar == 'd' || lastChar == 'r' ) {
      return "O";
    } else if (lastChar == '|' || lastChar == '-') {
      return "L";
    } else if (lastChar == 'x') {
      return "X";
    }
    return null;
  }

  String SimboleFromRotation(int rotation, String symetry) {
    if (symetry.equals("X")) {
      return "x";
    } else if (symetry.equals("L")) {
      if (rotation%2 == 0) {
        return "-";
      } else if (rotation%2 == 1) {
        return "|";
      }
    } else if (symetry.equals("O")) {
      if (rotation == 0) {
        return "u";
      } else if (rotation == 1) {
        return "l";
      } else if (rotation == 2) {
        return "d";
      } else if (rotation == 3) {
        return "r";
      }
    }
    return null;
  }

  int nLoopFromSymetry(JSONObject tile) {
    String symmetry = tile.getString("symmetry");
    if (symmetry.equals("X")) {
      return 1;
    } else if (symmetry.equals("L")) {
      return 2;
    } else if (symmetry.equals("O")) {
      return 4;
    }
    return 0;
  }
}
