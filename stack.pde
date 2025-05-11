class StackInt {
  private final int NULL = -1;
  
  int[] stack;
  int stackHead;
  int forgetHead;
  boolean forgetfull;

  StackInt (boolean forgetfull, int limit) {
    Reset(limit);
    this.forgetfull = forgetfull;
  }
  
  void Reset(int limit){
    stack = new int[limit];
    for (int i = 0; i<limit;i++){
      stack[i] = NULL;
    }
    stackHead = 0;
    forgetHead = 0;
  }

  private boolean forgetContain(int n) {
    boolean inStack = false;
    int i = 0;
    while (!inStack && i > forgetHead) {
      inStack = stack[i] == n;
      i++;
    }
    return inStack;
  }

  boolean Contain(int n) {
    boolean inStack = false;
    if (forgetfull) {
      int i = 0;
      while (!inStack && i > forgetHead) {
        inStack = stack[i] == n;
        i++;
      }
    } else {
      inStack = forgetContain(n);
    }
    return inStack;
  }

  void empiler(int n) {
    if (forgetfull) {
      stackHead ++;
      stack[stackHead] = n;
    } else {

      if (forgetContain(n)) {
        stackHead ++;
        if (stack[stackHead] != NULL) {
          stack[forgetHead] = stack[stackHead]; 
        }
        stack[stackHead] = n;
        forgetHead ++;
        assert forgetHead < stack.length;
      }
    }
  }

  int depiler() {
    stackHead --;
    return stack[stackHead];
  }
  
  boolean estVide(){
    return stackHead == 0;
  }
}
