import 'package:aplicacion_de_ventas/Pages/articles.dart';
import 'package:aplicacion_de_ventas/Pages/shopping_record.dart';
import 'package:aplicacion_de_ventas/Pages/purchase.dart';
import 'package:flutter/material.dart';

class navigator_menu extends StatefulWidget {
  const navigator_menu({Key? key}) : super(key: key);

  @override
  State<navigator_menu> createState() => _MyAppState();
}

class _MyAppState extends State<navigator_menu> {
  // This widget is the root of your application.
  int _actual_page = 0;

  final List<Widget> _paginas = [
    purchase(),
    articles(),
    shopping_record(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginas[_actual_page],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.indigo.shade900,
          onTap: (index) {
            setState(() {
              _actual_page = index;
            });
          },
          currentIndex: _actual_page,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.sell,color: Colors.white,), label: "Comprar", ),
            BottomNavigationBarItem(icon: Icon(Icons.analytics,color: Colors.white,), label: "Estadisticas"),
            BottomNavigationBarItem(icon: Icon(Icons.history,color: Colors.white,), label: "Historial"),
          ],
          selectedLabelStyle: TextStyle(fontSize: 17),     
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white38,
          unselectedLabelStyle: TextStyle(fontSize: 15),
        ),
    );
  }
}
