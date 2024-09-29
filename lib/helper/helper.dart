bool istWeiss(int index) {

  int x = index ~/ 8;
  int y = index % 8;

  bool istWeiss = (x+y) % 2 == 0;

  return istWeiss;
}

bool isInBoard(int row, int col){

  return row >= 0 && row <8 && col >= 0 && col < 8;

}

bool isShortCastle(int col){

  if(col == 1 || col == 6){
      return true;
  }
  else if(col == 2 || col == 5){
    return false;
  }
  return false;
}

bool isRochade(int oldCol, newCol){

  if((oldCol - newCol).abs() == 2){
    return true;
  }

  return false;

}