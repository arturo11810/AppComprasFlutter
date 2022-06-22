import 'dart:convert';

import 'package:aplicacion_de_ventas/Models/products.dart';
import 'package:aplicacion_de_ventas/Models/productsxpurchase.dart';
import 'package:aplicacion_de_ventas/Models/purchase.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class shopping_record extends StatefulWidget {
  const shopping_record({Key? key}) : super(key: key);

  @override
  State<shopping_record> createState() => _MyAppState();
}

class _MyAppState extends State<shopping_record> {
  List<purchase> PurchasesList = [];
  bool showCircurlarProgress=true;

  @override
  void initState() {
    CargarCompras();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, //centrar titulo
        title: const Text("Historial de compras",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo.shade900,
        leading: Text(""),
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
      body:
      showCircurlarProgress==false  
      ?Body(context)
      :const Center(
        child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
      ),
    );
  }

  Widget Body(context) {
    return Container(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //Text('Historial de ventas',),
            ...GetPurchases(context),
          ],
        ),
      ),
    );
  }

  List<Widget> GetPurchases(context) {
    List<Widget> AllPurchases = [];

    for (var item in PurchasesList.reversed) {
      AllPurchases.add(Container(
        //padding: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: const Border(
            bottom: BorderSide(
              //                   <--- left side
              color: Colors.black,
              width: 2,
            ),
            top: BorderSide(
              //                    <--- top side
              color: Colors.black,
              width: 2,
            ),
          ),
          color: Colors.indigo.shade900,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        margin: EdgeInsets.symmetric(vertical: 2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag,
                      size: 50, color: Colors.yellow),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        String.fromCharCode(36) + " " + item.Amount!,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        item.Date!,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ButtonsPurchase(item.Clave!,context),
          ],
        ),
      ));
    }
    return AllPurchases;
  }

  Widget ButtonsPurchase(String ClaveCompra,context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, //same space between widgets
        children: [
          //Cancel button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: OutlinedButton(
                onPressed: () async {
                  setState(() {
                    showCircurlarProgress=true;
                    PurchasesList.clear();
                  });
                  List<productsxpurchase> ProductsxPurchaseList2 = await getRequestProductsxPurchase(ClaveCompra);//obtener los productos de la compra
                  await DeleteRequestProductsxPurchase(ProductsxPurchaseList2);
                  await deleteRequest(context,ClaveCompra);//delete purchases
                  await getRequestPurchase();
                  setState(() {
                    showCircurlarProgress=false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  primary: Colors.white,
                  textStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  backgroundColor: Colors.red,
                ),
                child: Center(child: const Text("Cancelar compra", textAlign: TextAlign.center,),),
              ),
            ),
          ),

          //Confirm button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    ShowSnackBar(context);
                    List<productsxpurchase> ProductsxPurchaseList2 = await getRequestProductsxPurchase(ClaveCompra);
                    Widget Content=await CargarProducts(ProductsxPurchaseList2);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    
                    showDialog(
                        context: context,
                        builder: (BuildContext context2) => AlertDialog(
                              title: Column(
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.cancel),
                                      padding: EdgeInsets.all(0),
                                      iconSize: 30.0,
                                      color: Colors.red,
                                      onPressed: () {
                                        Navigator.pop(context2);
                                      }),
                                  const Center(
                                      child: Text(
                                    "Productos de esta compra",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0),
                                  )),
                                ],
                              ),
                              content: Content,
                            ));
                  },
                  child: const Center(
                      child: Text(
                    "Ver detalle",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ))),
            ),
          ),
        ],
      ),
    );
  }

  CargarCompras() async {
    await getRequestPurchase();
    setState(() {
      showCircurlarProgress=false;
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

  Future<Widget> CargarProducts (List<productsxpurchase> ProductsxPurchaseList2)async {
    print("Entro al cargarproductos");
    return Container(
      width: double.maxFinite,
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Expanded(
            child: ListView(
                //padding: EdgeInsets.all(10),
                shrinkWrap: true, //scroll
                children:await BuildProductsList(ProductsxPurchaseList2)))
      ]),
    );
  }

  Future<List<Widget>> BuildProductsList(List<productsxpurchase> ProductsxPurchaseList2)async {
    print("Entro al buildproductslist");
    List<Widget> ListStructure = [];
    for (var i = 0; i < ProductsxPurchaseList2.length; i++) {
      //print(ProductsxPurchaseList2[i].ProductCode!);
      product item= await getinfoproduct(ProductsxPurchaseList2[i].ProductCode!);
      print("Busco correctamente el producto"+item.name!);
      ListStructure.add(
        Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                // Text(ProductsxPurchaseList2[i].ClaveCompra! +
                //     '  ' +
                //     ProductsxPurchaseList2[i].ProductCode!),

                Expanded(
                    child: SizedBox(
                        height: 100, child: BringImage(item.image))),
                SizedBox(
                  //width: MediaQuery.of(context2).size.width * 0.30,
                  child: Column(
                    children: [
                      Text("Nombre: " +
                          item.name! +
                          "\nPrecio: " +
                          (item.price).toString() +
                          "\nCantidad: " +
                          ProductsxPurchaseList2[i].quantity! +
                          "\nImporte: " +
                          ((item.price!) * double.parse((ProductsxPurchaseList2[i].quantity!)))
                              .toString()),
                    ],
                  ),
                ),
              ],
            )),
      );
    }
    return ListStructure;
  }

  Future<product> getinfoproduct(String CodigoProducto)async{
    product producto=product();
     final response = await http.get(
        Uri.parse(
            'https://v7m9qx5n3k.execute-api.us-east-1.amazonaws.com/Test/products/{code}?code=' +
                CodigoProducto),
        headers: {
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 200) {
      print("Get correcto");
      var responseJson = jsonDecode(response.body);
      print(responseJson);
      setState(() {
        print(responseJson[0]['code']);
          producto = product(
            code: responseJson[0]['code'],
            name: responseJson[0]['name'],
            category: responseJson[0]['category'],
            price: double.parse(responseJson[0]['price']),
            image: responseJson[0]['image']
          );
          print(producto);
      });
      //print(producto);
    }
      return producto;
  }

  Widget BringImage(String? image) {
    if (image != null && image != "" && image.isNotEmpty) {
      var _byteImage = Base64Decoder().convert(image);
      Widget? imageHere = Image.memory(_byteImage);
      return imageHere;
    } else {
      return const Text("");
    }
  }


    ShowSnackBar(context){
    final snackBar = SnackBar(
          backgroundColor: Colors.transparent,
            content: 
            Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Transform.scale(
                  //para cambiar la escala en este caso del progressindicator
                  scale: 1,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            //Text(message, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),textAlign: TextAlign.center,),
            //Center(child: Text("Usuario no valido", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),)),
            duration: Duration(seconds: 20),
          );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //delete products in purchase
  DeleteRequestProductsxPurchase(List<productsxpurchase> ProductsxPurchaseList) async {
    //encode Map to JSON
    //recorrer el arreglo de productosxventa
    for (var item in ProductsxPurchaseList) {
      
    final response = await http.delete(
        Uri.parse(
            'https://v7m9qx5n3k.execute-api.us-east-1.amazonaws.com/Test/productoxcompra?id=' +item.Clave!+"&id2="+item.ClaveCompra!),
        headers: {
          'Content-Type': 'application/json',
        });
    //print(response);

    if (response.statusCode == 200) {
      //final responseJson = jsonDecode(response.body);
      print("Se elimino correctamente");
    }
    }
  }


  //deleteRequest
  Future<void> deleteRequest(context,String ClaveCompra) async {
    String User=await _GetUser();
    //encode Map to JSON
    final response = await http.delete(
        Uri.parse('https://v7m9qx5n3k.execute-api.us-east-1.amazonaws.com/Test/compras?Clave='+ClaveCompra+'&User='+User+''),
        headers: {
          'Content-Type': 'application/json',
        });
    
    if (response.statusCode == 200) {
      showDailogMessage(context, "Cancelado correctamente");
    }
    

  }


  showDailogMessage(context,String message){
    showDialog(
                  context: context,
                  builder: (BuildContext context2) => AlertDialog(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                    contentPadding: EdgeInsets.only(top: 10.0),
                        title: Column(
                          children: [
                            IconButton(
                                icon: Icon(Icons.check_circle),
                                padding: EdgeInsets.all(0),
                                iconSize: 60.0,
                                color: Colors.green,
                                onPressed: () {
                                  Navigator.pop(context2);
                                }),
                            Center(
                                child: Text(
                              message,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0),
                            )),
                          ],
                        ),
                        //content: ,
                        actions: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      textStyle: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context2);
                                    },
                                    child: const Center(
                                        child: Text(
                                      "Aceptar",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ))),
                              ),
                            ],
                          ),
                        ],
                      ));
  }
}
