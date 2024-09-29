
import 'package:flutter/material.dart';
import 'package:schach/components/Enums.dart';
import 'package:schach/components/Schachfigur.dart';
import 'Toast.dart';

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

class DialogBauernUmwandlung extends StatefulWidget {

  final bool isWhite;
  final bool isEnemy;

  final Function(Schachfigur) onReturnValue;

   const DialogBauernUmwandlung({super.key, required this.isWhite, required this.isEnemy, required this.onReturnValue});

  @override
  State<StatefulWidget> createState() => _DialogBauernUmwandlungState();
}


class _DialogBauernUmwandlungState extends State<DialogBauernUmwandlung>{

  List<Schachfigur> figurenListe = <Schachfigur>[];
  Schachfigur? selectedFigur;


    @override
  void initState() {
    super.initState();

    figurenListe.add(Schachfigur(art: Schachfigurenart.DAME, istWeiss: widget.isWhite, isEnemy: widget.isEnemy));
    figurenListe.add(Schachfigur(art: Schachfigurenart.TURM, istWeiss: widget.isWhite, isEnemy: widget.isEnemy,hasMoved: true));
    figurenListe.add(Schachfigur(art: Schachfigurenart.SPRINGER, istWeiss: widget.isWhite, isEnemy: widget.isEnemy));
    figurenListe.add(Schachfigur(art: Schachfigurenart.LAEUFER, istWeiss: widget.isWhite, isEnemy: widget.isEnemy));

  }

  @override
  Widget build(BuildContext context) {

    return

      PopScope(
        canPop: false,
        child: AlertDialog(
          titlePadding: const EdgeInsets.only(left: 15, right: 20,top: 25,bottom: 20),
          contentPadding: const EdgeInsets.only(left: 20,right: 20, top: 0, bottom: 0),
          actionsPadding: const EdgeInsets.only(left: 20,right: 20, top: 10, bottom: 20),
          title:
          Container(
            alignment: Alignment.center,
            child:
             Text(
              "Bauer umwandeln!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30,
                  height: 0,
                  color: widget.isWhite ? Colors.black: Colors.white,
                  fontWeight: FontWeight.bold),

            ),
          ),
          surfaceTintColor: Colors.black,
          backgroundColor: widget.isWhite ? Colors.white : Colors.black,
          content:

          Container(
            width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Center(
                  child:

                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10, bottom: 15,top: 0),
                    child: Text(
                      "Bauer umwandeln in",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          height: 0,
                          color: widget.isWhite ? Colors.black38: Colors.white54,
                          fontWeight: FontWeight.bold),

                    ),
                  ),
                ),

                ListView.builder(
                    shrinkWrap: true,
                    itemCount: figurenListe.length,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {

                      Schachfigur figur =figurenListe[index];

                      return

                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFigur= figur;
                              });
                            },
                            child:
                            Container(
                             // width:100,
                              height: 80,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: figur.istWeiss ? Colors.black38: Colors.white54,
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: selectedFigur == figur ? Border.all(color: Colors.green,width: 5.0,) : Border.all(color: widget.isWhite ? Colors.black : Colors.white, width: 3.0,)
                              ),
                              child:
                              Image.asset(
                               figur.bild,
                                color: figur.istWeiss ? Colors.white : Colors.black,
                                scale: 0.5,
                              )

                            ),
                          ),
                        );

                    }),

              ],),
          ),


          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: (){

                    if(selectedFigur != null){
                      widget.onReturnValue(selectedFigur!);
                    }
                    else{
                      showInfo(context: context, text: "Wähle die Figur aus, in die du den Bauern umwandeln möchtest!");
                    }
                    Navigator.pop(context);

                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: widget.isWhite ? Colors.black : Colors.white,
                    side:  BorderSide(color: widget.isWhite ? Colors.white54: Colors.black38, width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Text Color (Foreground color)
                  ),
                  child:
                  Text(
                    'OK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        height: 0,
                        color: widget.isWhite ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold
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
