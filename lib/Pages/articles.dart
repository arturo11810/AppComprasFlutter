import 'dart:convert';

import 'package:aplicacion_de_ventas/Models/products.dart';
import 'package:aplicacion_de_ventas/Models/productsxpurchase.dart';
import 'package:aplicacion_de_ventas/Models/purchase.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../main.dart';
//import 'package:syncfusion_flutter_charts/sparkcharts.dart';

// ignore: camel_case_types
class articles extends StatefulWidget {
  const articles({Key? key}) : super(key: key);

  @override
  State<articles> createState() => _MyAppState();
}

class _MyAppState extends State<articles> {
  List<purchase> PurchasesList = []; //lista de compras
  List<product> Product = []; //lista de productos sin reetirse
  List<int> Productquality = []; //lista de la cantidad del productos
  List<productTemporaly> ProductTemporalyList = [];
  bool showCircurlarProgress = true;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    CargarCompras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        leading: Text(""),
        title: Center(child: Text("Estadisticas", style: TextStyle(fontSize: 20),)),
        backgroundColor: Colors.indigo.shade900,
        actions: [
          IconButton(
              padding: EdgeInsets.only(right: 5),
              alignment: Alignment.centerRight,
              icon: const Icon(Icons.logout_outlined),
              iconSize: 30,
              onPressed: () {
                setState(() {
                  _GuardarValorInicioSesion("0");
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyApp()));
                //Navigator.pop(context);
              },
            ),
        ],
      ),
      body: showCircurlarProgress == false
          ? Center(
              child: SfCircularChart(
                tooltipBehavior: _tooltipBehavior,
                title: ChartTitle(
                    text: 'Grafico de productos comprados',
                    textStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                series: <CircularSeries>[
                  // Render pie chart
                  PieSeries<productTemporaly, String>(
                      dataSource: ProductTemporalyList,
                      xValueMapper: (productTemporaly data, _) => data.name,
                      yValueMapper: (productTemporaly data, _) =>
                          double.parse(data.quality!),
                      dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17)),
                      enableTooltip: true)
                ],
                legend: Legend(
                    isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap,
                    textStyle: TextStyle(fontSize: 17)),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
    );
  }


  CargarCompras() async {
    await getRequestPurchase();
    List<String> ProductCode = [];

    for (var item in PurchasesList) {
      List<productsxpurchase> ProductsxPurchaseList2 =
          await getRequestProductsxPurchase(item.Clave!);
      for (var item in ProductsxPurchaseList2) {
        //print("Aqui 1");
        int index = (ProductCode).indexOf(item.ProductCode!);
        //print(item.ProductCode);
        if (index == -1) {
          ProductCode.add(item
              .ProductCode!); //agrega a la lista temporal el codigo del produto para checar si ya existe
          await GetProduct(
              item.ProductCode!); //agrega a la lista de productos el productos
          double valor=double.parse(item.quantity!);
          print("agregar "+valor.toString());
          Productquality.add(valor.round()); 
        } else {
          setState(() {
            print("Sumar");
            print(item.quantity);
            double valor=double.parse(item.quantity!);
            Productquality[index] = Productquality[index] + valor.round();
          });
        }
      }
    }
    

    for (var i = 0; i < Product.length; i++) {
      productTemporaly productoT = productTemporaly(
          name: Product[i].name, quality: (Productquality[i]).toString());
      ProductTemporalyList.add(productoT);
    }

    setState(() {
      showCircurlarProgress = false;
    });
  }

  Future<void> getRequestPurchase() async {
    //encode Map to JSON
    String user = await _GetUser();
    final response = await http.get(
        Uri.parse(
            'https://v7m9qx5n3k.execute-api.us-east-1.amazonaws.com/Test/compras/user?user=' +
                user),
        headers: {
          'Content-Type': 'application/json',
        });
    print(response);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      print(responseJson);
      setState(() {
        for (var response in responseJson) {
          purchase compraT = purchase(
            Clave: response['Clave'],
            Amount: response['Amount'],
            Date: response['Date'],
            User: response['User'],
          );
          PurchasesList.add(compraT);
        }
      });
      print(PurchasesList);
    }
  }

  Future<List<productsxpurchase>> getRequestProductsxPurchase(
      String ClaveCompra) async {
    //encode Map to JSON
    List<productsxpurchase> ProductsxPurchaseList = [];
    final response = await http.get(
        Uri.parse(
            'https://v7m9qx5n3k.execute-api.us-east-1.amazonaws.com/Test/productoxcompra/id?id=' +
                ClaveCompra),
        headers: {
          'Content-Type': 'application/json',
        });
    print(response);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      print("Correcto hasta obetener lso productos de la venta");
      print(responseJson);
      setState(() {
        for (var response in responseJson) {
          productsxpurchase productxpurchaseT = productsxpurchase(
            ClaveCompra: response['ClaveCompra'],
            Clave: response['Clave'],
            ProductCode: response['ProductCode'],
            User: response['User'],
            quantity: response['quantity'],
          );
          ProductsxPurchaseList.add(productxpurchaseT);
        }
      });
      print(ProductsxPurchaseList);
    }
    return ProductsxPurchaseList;
  }

  Future<void> GetProduct(String code) async {
    //encode Map to JSON
    final response = await http.get(
        Uri.parse(
            'https://v7m9qx5n3k.execute-api.us-east-1.amazonaws.com/Test/products/{code}?code=' +
                code),
        headers: {'Content-Type': 'application/json'});
    print((response.statusCode).toString());
    if (response.statusCode == 200) {
      var responseJson = jsonDecode(response.body);
      //print("Responsejson");
      setState(() {
        for (var item in responseJson) {
          product productoT = product(
              code: item['code'],
              name: item['name'],
              category: item['category'],
              price: double.parse(item['price']),
              image: item['image']);
          //print("Antes de add");
          Product.add(productoT);
        }
      });
    } else {
      print("producto no enconrado");
    }
  }

  //obtener de la cache el usuario
  Future<String> _GetUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("UseName") ?? "";
  }

    _GuardarValorInicioSesion(String sesionIniciada) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("sesion", sesionIniciada);
    });
  }
  
}

class productTemporaly {
  String? name;
  String? quality;

  productTemporaly({this.name, this.quality});
}
