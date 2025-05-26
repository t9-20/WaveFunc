class StackInt {
  
  int[] stack;
  int stackHead;
  int limit;

  StackInt (int limit) {
    stack = new int[limit];
    this.limit = limit;
    reset();
  }
  
  void reset(){
    stackHead = 0;
  }

  void empiler(int n) {
    stack[stackHead] = n;
    stackHead ++;
  }

  int depiler() {
    stackHead --;
    return stack[stackHead+1]; 
  }
  
  int size(){
    return stackHead;
  }
  
  boolean isEmpty(){
    return stackHead == 0;
  }
}
