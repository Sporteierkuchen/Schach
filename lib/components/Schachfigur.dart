
import 'Enums.dart';

class Schachfigur{

final Schachfigurenart art;
final bool istWeiss;
final bool isEnemy;
late final String bild;

Schachfigur({
  required this.art,
  required this.istWeiss,
  required this.isEnemy
}){

  switch (art) {
    case Schachfigurenart.BAUER:
      bild="assets/images/figuren/bauer.png";
      break;
    case Schachfigurenart.SPRINGER:
      bild="assets/images/figuren/springer.png";
      break;
    case Schachfigurenart.LAEUFER:
      bild="assets/images/figuren/laeufer.png";
      break;
    case Schachfigurenart.TURM:
      bild="assets/images/figuren/turm.png";
      break;
    case Schachfigurenart.DAME:
      bild="assets/images/figuren/dame.png";
      break;
    case Schachfigurenart.KOENIG:
      bild="assets/images/figuren/koenig.png";
      break;
    default:
  }

}

@override
  String toString() {
  // TODO: implement toString


  if (art.name == "BAUER") {
    return istWeiss?  "Weißer Bauer Feind: $isEnemy": "Schwarzer Bauer Feind: $isEnemy";
  }
  if (art.name == "SPRINGER") {
    return istWeiss?  "Weißer Springer Feind: $isEnemy": "Schwarzer Springer Feind: $isEnemy";
  }
  if (art.name == "LAEUFER") {
    return istWeiss?  "Weißer Läufer Feind: $isEnemy": "Schwarzer Läufer Feind: $isEnemy";
  }
  if (art.name == "TURM") {
    return istWeiss?  "Weißer Turm Feind: $isEnemy": "Schwarzer Turm Feind: $isEnemy";
  }
  if (art.name == "DAME") {
    return istWeiss?  "Weiße Dame Feind: $isEnemy": "Schwarze Dame Feind: $isEnemy";
  }
  if (art.name == "KOENIG") {
    return istWeiss?  "Weißer König Feind: $isEnemy": "Schwarzer König Feind: $isEnemy";
  }

  return "Unbekannte Figur";
}

}