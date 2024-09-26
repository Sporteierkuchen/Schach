
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schach/components/Enums.dart';

class DialogSpielende extends StatelessWidget{

  final Spielende spielende;
  final bool isWhiteTurn;
  final bool figurenfarbe;
  final String text;
  final void Function()? onTapNochmal;
  final void Function()? onTapBack;

  const DialogSpielende({
    super.key,
    required this.spielende,
    required this.isWhiteTurn,
    required this.figurenfarbe,
    required this.text,
    required this.onTapNochmal,
    required this.onTapBack,
  });

  @override
  Widget build(BuildContext context) {

    return

    PopScope(
      canPop: false,
      child: AlertDialog(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
        contentPadding: const EdgeInsets.only(left: 20,right: 20, top: 0, bottom: 25),
        actionsPadding: const EdgeInsets.only(left: 20,right: 20, top: 0, bottom: 10),
        title:
        Container(
          alignment: Alignment.center,
          child: Text(
            spielende == Spielende.SCHACHMATT ? "Schachmatt!" : "Remis!",
            style: const TextStyle(
                fontSize: 35,
                height: 0,
                color: Colors.black,
                fontWeight: FontWeight.bold),

          ),
        ),
        surfaceTintColor: Colors.black,
        backgroundColor: spielende == Spielende.SCHACHMATT ?    isWhiteTurn == figurenfarbe ? Colors.green[200] : Colors.red[200]   :  Colors.grey,
        content:
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 30,
              height: 0,
              color: Colors.blue,
              fontWeight: FontWeight.bold),

        ) ,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: ElevatedButton(
                  onPressed: onTapBack,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey, width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Text Color (Foreground color)
                  ),
                  child:
                  const Text(
                    'Spielauswahl',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        height: 0
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20,),

              Expanded(
                child: ElevatedButton(
                  onPressed: onTapNochmal,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey, width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Text Color (Foreground color)
                  ),
                  child:
                  const Text(
                    'Nochmal spielen!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        height: 0
                    ),
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );

  }

}

class DialogSpielabbruch extends StatelessWidget{

  final void Function()? onTapNein;
  final void Function()? onTapJa;

  const DialogSpielabbruch({
    super.key,
    required this.onTapNein,
    required this.onTapJa,
  });

  @override
  Widget build(BuildContext context) {

    return

      AlertDialog(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
        contentPadding: const EdgeInsets.only(left: 20,right: 20, top: 0, bottom: 25),
        actionsPadding: const EdgeInsets.only(left: 20,right: 20, top: 0, bottom: 10),
        title:
        Container(
          alignment: Alignment.center,
          child: const Text(
           "Abbrechen",
            style: TextStyle(
                fontSize: 35,
                height: 0,
                color: Colors.black,
                fontWeight: FontWeight.bold),

          ),
        ),
        surfaceTintColor: Colors.black,
        backgroundColor: Colors.grey,
        content:
        const Text(
          "Willst du das Spiel wirklich abbrechen?",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 30,
              height: 0,
              color: Colors.white,
              fontWeight: FontWeight.bold),

        ) ,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: ElevatedButton(
                  onPressed: onTapNein,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey, width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Text Color (Foreground color)
                  ),
                  child:
                  const Text(
                    'Nein',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        height: 0
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20,),

              Expanded(
                child: ElevatedButton(
                  onPressed: onTapJa,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey, width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Text Color (Foreground color)
                  ),
                  child:
                  const Text(
                    'Ja',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        height: 0
                    ),
                  ),
                ),
              ),

            ],
          ),

        ],
      );

  }

}