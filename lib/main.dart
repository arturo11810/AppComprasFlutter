import 'dart:convert';

import 'package:aplicacion_de_ventas/Pages/navigator_menu.dart';
import 'package:flutter/material.dart';
import "dart:async";
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var UserText = new TextEditingController();
  var PasswordText = new TextEditingController();

  String? UserFromLambda;
  String? PasswordFromLamda;
  bool showCircurlarProgress=false;
  bool isCheked=false;

  @override
  void initState() {
    VerificarInicioSesion();
  }

  VerificarInicioSesion() async{
    print(await _obtenerValorSesion());
    if(await _obtenerValorSesion()=="1"){
      //si ya tenia la sesion iniciada va a llenar los textediting controller y verificarlos
      isCheked=true;
      UserText.text=await _GetUser();
      PasswordText.text=await _GetPass();
      setState(() {
        showCircurlarProgress=true;
      });
      VerificarUsuario();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text("Aplicacion"),),
      body: Body(context),
    );
  }

  Widget Body(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.circular(16.0),
        color: Colors.indigo.shade900,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: BodyStructure(context), //get body structure
        ),
      ),
    );
  }

  Widget BodyStructure(BuildContext context) {
    return Column(
      children: [
        
        Tittle(),
        User(),
        Password(),
        StatusCheckBox(),
        ButtonLogin(context),
        BoxSize(),
        TextoFinal(),
        ImagenFinal(),
      ],
    );
  }

  Widget Tittle() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Text(
        'SimplePoint',
        style: TextStyle(
          fontSize: 40,
          color: Colors.white, //font color
          letterSpacing: -1, //letter spacing
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget User() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: UserText,//le asigna la variabl en la que guardara lo que haya en este textfield
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Usuario',
          hintStyle: const TextStyle(color: Colors.black54),
          //errorText: textErrorMonto ? mensajeError : null,
          border: const OutlineInputBorder(
            //borderRadius: BorderRadius.all(Radius.circular(20.0),),
            borderSide: BorderSide(
              width: 0.5,
              style: BorderStyle.solid,
              color: Colors.grey,
            ),
          ),
          fillColor: Colors.lightBlue[50], //el color con el que estara relleno
          filled: true, //para que se rellene
          //isDense: true, //la densidad del textfield (el espacio vertical)
          contentPadding: const EdgeInsets.only(
              left: 10.0), //el padding del texto dentro del textfield
        ),
        style: const TextStyle(
            fontSize: 20,
            //height: 1.2,
            color: Colors.black), //estilo del texto
      ),
    );
  }

  Widget Password() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
      child: TextField(
        //For password desing
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        controller: PasswordText,//le asigna la variabl en la que guardara lo que haya en este textfield
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: const TextStyle(color: Colors.black54),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 0.5,
              style: BorderStyle.solid,
              color: Colors.grey,
            ),
          ),
          fillColor: Colors.lightBlue[50], //el color con el que estara relleno
          filled: true, //para que se rellene
          contentPadding: const EdgeInsets.only(
              left: 10.0), //el padding del texto dentro del textfield
        ),
        style: const TextStyle(
            fontSize: 20, color: Colors.black), //estilo del texto
      ),
    );
  }

  Widget StatusCheckBox() {
    return Theme(
    data: ThemeData(unselectedWidgetColor: Colors.white),
      child: CheckboxListTile(
        title: const Text('Mantener Sesión', style: TextStyle(color: Colors.white, fontSize: 18),),
        value:isCheked,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (bool? value) {
          setState(() {
            isCheked = value!;
          });
        }, 
      ),
    );
  }

  Widget ButtonLogin(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.only(left: 20.0, right: 20.0, top: 0, bottom: 0.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.white, //font color
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    //height: 2.0,
                    //fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                //side: const BorderSide(width: 2.0,color: Color(0xFF2B1640),),
                onPrimary: Colors.white, //color de la letra
                primary: Colors.indigo.shade800, //color del relleno
                padding: const EdgeInsets.symmetric(
                    horizontal: 20), //padding del boton
                shape: const RoundedRectangleBorder(
                  //para redondear el borde
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              onPressed: () {
                setState(() {
                  showCircurlarProgress=true;
                });
                VerificarUsuario();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget BoxSize(){
    return SizedBox(
      height: 70,
      width: 70,
      child: 
      showCircurlarProgress== true 
      ?Container(
        padding: const EdgeInsets.all(15),
        child: Transform.scale(
          //para cambiar la escala en este caso del progressindicator
          scale: 1,
          child: const CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      )
      :Text(""),
    );
  }

  Widget TextoFinal() {
    return const Text(
      "Crear cuenta",
      style: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.underline,
        fontSize: 18.0,
      ),
    );
  }

  Widget ImagenFinal() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Image.asset(
        'assets/Logo.png',
        width: 30,
        height: 30,
      ),
    );
  }


  VerificarUsuario () async {
      await postRequest();
      ComprobarDatos();
      setState(() {
        showCircurlarProgress=false;
      });
  }

    Future<void> postRequest() async {

    //encode Map to JSON
    final response = await http.get(
        Uri.parse('https://v7m9qx5n3k.execute-api.us-east-1.amazonaws.com/Test/users/{byusername}?username='+UserText.text),
        headers: {
          'Content-Type': 'application/json',
          "Access-Control-Allow-Origin": "*",
        });
    print((response.statusCode).toString()+"  "+UserText.text);
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);

      //solo treae un dato, no una lista
      setState(() {
        UserFromLambda=responseJson['UserName'];
        PasswordFromLamda=responseJson['Contrasena'];
      });
    }
    else
    {
      setState(() {
        UserFromLambda=null;
        PasswordFromLamda=null;
      });
    }

  }

  ComprobarDatos(){
    if(UserFromLambda!=null && PasswordFromLamda!=null){
      if(UserText.text==UserFromLambda && PasswordText.text==PasswordFromLamda)//si coinciden va a entrar
      {
        if (isCheked == true) //guaradar el estatus del inicio de sesion en cache
        {
          _GuardarValorInicioSesion("1");
        } else {
          _GuardarValorInicioSesion("0");
        }
        _SaveUserAndPass(UserText.text, PasswordText.text);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => navigator_menu()));
      }else
      {
        ShowSnackBar("Usuario o contraseña incorrecta");
        print("Contraseña incorrecta");
      }
    }
    else
    {
      ShowSnackBar("Usuario o contraseña incorrecta");
      print("Usuario no encontrado");
    }
  }

  ShowSnackBar(String message){
    final snackBar = SnackBar(
          backgroundColor: Colors.transparent,
            content: 
            Text(message, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),textAlign: TextAlign.center,),
            //Center(child: Text("Usuario no valido", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),)),
            duration: Duration(seconds: 1),
          );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }




  //Guardar estatus del checkbox
  _GuardarValorInicioSesion(String sesionIniciada) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("sesion", sesionIniciada);
    });
  }

  //obtener de la cache el estatus de la sesion
  Future<String> _obtenerValorSesion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("sesion") ?? "";
  }

    //Guardar el usuario y contraseña en la cache
  _SaveUserAndPass(String user, String pass) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("UseName", user);
      prefs.setString("Password", pass);
    });
  }

  //obtener de la cache el usuario
  Future<String> _GetUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("UseName") ?? "";
  }
  //obtener de la cache la contraseña
  Future<String> _GetPass() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("Password") ?? "";
  }
  
}
