import 'dart:math';
import 'package:flutter/material.dart';
import 'package:schach/components/Spielart.dart';
import 'package:schach/components/Toast.dart';
import 'package:schach/spielbrett.dart';
import 'package:schach/values/colors.dart';

class SpielAuswahl extends StatefulWidget {
  const SpielAuswahl({super.key});

  @override
  State<SpielAuswahl> createState() => _SpielAuswahlState();
}

class _SpielAuswahlState extends State<SpielAuswahl> {
  late bool figurenfarbe; //false=schwarz true=weiß

  List<SpielArt> spielartenListe = <SpielArt>[
    SpielArt(path: "assets/images/figuren/koenig_gold.png", figurenfarbe: 1),
    SpielArt(path: "", figurenfarbe: -1),
    SpielArt(path: "assets/images/figuren/koenig_gold.png", figurenfarbe: 0),
  ];

  List<int> spielModusListe = <int>[
  0,1,-1
  ];

  SpielArt? selectedSpielArt;
  int? selectedSpielModus;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    return
      SafeArea(
        child: Scaffold(
        backgroundColor: backgroundColorSpielAuswahl,
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            Padding(
              padding: const EdgeInsets.only(left: 15,right: 15,top: 30,bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                const Text(
                  "Schach",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 40,
                      height: 0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),

                ),

                const SizedBox(height: 10,),

                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(15.0),
                  ),
                  child:
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0), // Runde Ecken
                    child:  Image.asset(
                      "assets/images/figuren/schach.png",
                    ),
                  ),

                ),

              ],),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Center(
                    child:

                    Padding(
                      padding: EdgeInsets.only(left: 10,right: 10, bottom: 10,top: 0),
                      child: Text(
                        "ICH SPIELE ALS",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            height: 0,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),

                      ),
                    ),
                  ),

                  Container(
                    color: Colors.transparent,
                    height: 120,
                    alignment: Alignment.center,
                    child:

                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: spielartenListe.length,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {

                          SpielArt spielart =spielartenListe[index];

                          return

                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSpielArt= spielart;
                                      });
                                    },
                                    child:
                                    Container(
                                      width: 100,
                                      height: 100,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: spielart.figurenfarbe== 1 ? Colors.white :  spielart.figurenfarbe== 0 ? Colors.black : Colors.grey,
                                          borderRadius: BorderRadius.circular(15.0),
                                          border: selectedSpielArt == spielart ? Border.all(color: Colors.green,width: 5.0,) : Border.all(color: Colors.black,width: 1.0,)
                                      ),
                                      child:
                                      spielart.figurenfarbe != -1 ?
                                      Image.asset(
                                        spielartenListe[index].path,
                                      )
                                          :
                                      const Icon(color: Colors.amber, size: 50, Icons.question_mark),
                                    ),
                                  ),
                                ),
                              ],
                            );

                        }),
                  ),

                ],),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Center(
                    child:

                    Padding(
                      padding: EdgeInsets.only(left: 10,right: 10, bottom: 5,top: 0),
                      child: Text(
                        "Spielmodus",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            height: 0,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),

                      ),
                    ),
                  ),

                  Container(
                    color: Colors.transparent,
                    height: 70,
                    alignment: Alignment.center,
                    child:

                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: spielartenListe.length,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {

                          int spielmodus =spielModusListe[index];

                          return

                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSpielModus= spielmodus;
                                      });
                                    },
                                    child:
                                    Container(
                                      width: 60,
                                      height: 60,
                                      alignment:Alignment.center,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Colors.white54,
                                          borderRadius: BorderRadius.circular(15.0),
                                          border: selectedSpielModus == spielmodus ? Border.all(color: Colors.green,width: 3.0,) : Border.all(color: Colors.black,width: 1.0,)
                                      ),
                                      child:
                                       Text(
                                        "$spielmodus",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 30,
                                            height: 0,
                                            color: Colors.deepOrangeAccent,
                                            fontWeight: FontWeight.bold),

                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );

                        }),
                  ),

                ],),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 50),
              child: ElevatedButton(
                onPressed: ()  async {

                  if(selectedSpielArt != null && selectedSpielModus != null){

                  int spielfarbe= selectedSpielArt!.figurenfarbe;

                  if(spielfarbe== -1){
                    Random random = Random();
                    spielfarbe = random.nextInt(2);

                  }

                  if(spielfarbe==1){
                    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SpielBrett(figurenfarbe: true, spielModus: selectedSpielModus!,)));
                  }
                  else{
                    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SpielBrett(figurenfarbe: false, spielModus: selectedSpielModus!,)));
                  }

                  }
                  else{

                    if(selectedSpielArt == null && selectedSpielModus == null){
                      showInfo(context: context, text: "Wähle die Farbe deiner Figuren aus und den Spielmodus!");
                    }
                    else if(selectedSpielArt == null){
                      showInfo(context: context, text: "Wähle die Farbe deiner Figuren aus, mit denen du spielen willst!");
                    }
                    else if(selectedSpielModus == null){
                      showInfo(context: context, text: "Wähle einen Spielmodus aus!");
                    }

                  }

                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  side: const BorderSide(color: Colors.black, width: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 10),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Spielen',
                  style: TextStyle(
                      fontSize: 25,
                      height: 0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

          ],
        ),
            ),
      );
  }
}
