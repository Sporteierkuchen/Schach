
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schach/components/Schachfigur.dart';
import '../values/colors.dart';

class Feld extends StatelessWidget{

  final bool istWeiss;
  final Schachfigur? figur;
  final bool ausgewaehlt;
  final bool isValidMove;
  final bool lastMoveFrom;
  final bool lastMoveTo;
  final bool kingInCheck;
  final bool isCheckmate;
  final void Function()? onTap;

  const Feld({
    super.key,
    required this.istWeiss,
    required this.figur,
    required this.ausgewaehlt,
    required this.isValidMove,
    required this.lastMoveFrom,
    required this.lastMoveTo,
    required this.kingInCheck,
    required this.isCheckmate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    Color? feldFarbe;

    if(ausgewaehlt){
      feldFarbe= Colors.green;
    }
    else if(isValidMove){
      feldFarbe= Colors.green[200];
    }
    else if(lastMoveFrom){
      feldFarbe= Colors.yellow[300];
    }
    else if(lastMoveTo){
      feldFarbe= Colors.yellow[200];
    }
    else if(isCheckmate){
      feldFarbe= Colors.red;
    }
    else if(kingInCheck){
      feldFarbe= Colors.red[200];
    }
    else{
      feldFarbe= istWeiss ? foregroundColor : backgroundColor;
    }

    return 
      
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black38,width:1),
            color: feldFarbe,
          ),
        child: figur!= null ?
        Image.asset(
            figur!.bild,
          color: figur!.istWeiss ? Colors.white : Colors.black,
        
        )
        : null,
            ),
      );

  }

}