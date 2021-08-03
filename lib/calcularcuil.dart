import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CalcularCuilPage extends StatefulWidget {
  static String tag = 'CalcularCuil-page';

  @override
  CalcularCuilPageState createState() {
    return new CalcularCuilPageState();
  }
}

class TitularData {
  String dni = '';
  String genero = '';
  String cuil = '';
}

String opcionElegida;
bool calculoRealizado = false;

class CalcularCuilPageState extends State<CalcularCuilPage> {
  int bandera = 0;
  String opcion = "";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TitularData titularSave = TitularData();

  void showInSnackBar(String value, Color color) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: color,
    ));
  }

  bool _autovalidate = false;
  bool _formWasEdited = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();
  final _UsNumberTextInputFormatter _dniFormatter =
      _UsNumberTextInputFormatter();

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    print(form);
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Por favor revise los datos.', Colors.red);
    } else {
      form.save();

      _calcularCuil(titularSave.dni, titularSave.genero);

      //showInSnackBar('${person.nombre}\'s phone number is ${person.dni}');
    }
  }

  _limpiarControles() {
    _dniController.text = "";
    //_generoController.text="M";
    _cuilController.text = "";
  }

  _handCopiar() {
    Clipboard.setData(ClipboardData(text: _cuilController.text));
    print("strcuil" + _cuilController.text);
  }

  void launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?text=${Uri.parse(message)}";
        //return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  // controllers for form text controllers
  final TextEditingController _generoController = new TextEditingController();
  String genero = '';
  final TextEditingController _dniController = new TextEditingController();
  String dni = '';
  final TextEditingController _cuilController = new TextEditingController();
  String cuil = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cuilController.text = cuil;
    _dniController.text = dni;
    _generoController.text = "M";
    opcionElegida = "M";
    titularSave.genero = "M";
    //_loadFromFirebase();
  }

  setOpcionElegida(String val) {
    setState(() {
      opcionElegida = val;
      titularSave.genero = val;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  _calcularCuil(String numerodni, String genero) {
    String strCuil = "";
    String ab = "";
    String c = "";
    String strDni = numerodni;
    int digito1 = 0;
    int digito2 = 0;
    var calculo = 0;

    if (strDni.length == 6) {
      strDni = '00' + strDni;
    } else if (strDni.length == 7) {
      strDni = '0' + strDni;
    } else {}

    if (genero == "M") {
      ab = '20';
    } else if (genero == "F") {
      ab = '27';
    } else {
      ab = '30';
    }

    var multiplicadores = [3, 2, 7, 6, 5, 4, 3, 2];

    digito1 = int.parse('${ab[0]}');
    digito2 = int.parse('${ab[1]}');

    calculo = ((digito1 * 5) + (digito2 * 4));

    for (var i = 0; i < 8; i++) {
      var aux = strDni[i];
      //print (" i: " + i.toString() +" aux: "+aux);
      calculo += (int.parse(aux)) * multiplicadores[i];
      //print ("calculo: "+ calculo.toString());
    }

    var resto = ((calculo)) % 11;

    if ((genero != "E") && (resto == 1)) {
      if (genero == "M") {
        c = '9';
      } else {
        c = '4';
      }
      ab = '23';
    } else if (resto == 0) {
      c = '0';
    } else {
      c = (11 - resto).toString();
    }

    strCuil = ab + strDni + c;

    print("cuil: " + strCuil);

    _cuilController.text = strCuil;
    calculoRealizado = true;
  }

  String _validatedni(String value) {
    _formWasEdited = true;
    final RegExp dniExp = RegExp(r'^[0-9]{6,8}$');
    if (!dniExp.hasMatch(value))
      return 'Ingrese un DNI que contenga 6 a 8 números.';
    return null;
  }

  Future<bool> _warnUserAboutInvalidData() async {
    final FormState form = _formKey.currentState;
    if (form == null || !_formWasEdited || form.validate()) return true;

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Este formulario tiene errores'),
              content: const Text('Desea salir del formulario?'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('SI'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                FlatButton(
                  child: const Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //backgroundColor: Colors.white70,
      appBar: AppBar(
        title: const Text('Averiguar Nº CUIL/CUIT',
            style: TextStyle(color: Colors.white)),
        shadowColor: Colors.amber,
        //backgroundColor: Colors.blue[100],
        //actions: <Widget>[MaterialDemoDocumentationButton(TextFormFieldDemo.routenombre)],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          onWillPop: _warnUserAboutInvalidData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 24.0),
                Text('Completa los datos'),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _dniController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: Icon(Icons.credit_card),
                    hintText: 'Ingresá el número de DNI',
                    labelText: 'Número de DNI*',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (String value) {
                    titularSave.dni = value;
                  },
                  validator: _validatedni,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 24.0),
                Text('Elige una opción'),
                const SizedBox(height: 24.0),
                RadioListTile(
                  value: "M",
                  groupValue: opcionElegida,
                  title: Text("Masculino"),
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      _generoController.text = "M";
                      titularSave.genero = "M";
                      opcionElegida = val;
                    });
                    //print("Radio $val");
                    //setOpcionElegida(val);
                    //titularSave.genero = val;
                    //print(titularSave.genero);
                  },
                ),
                RadioListTile(
                  value: "F",
                  groupValue: opcionElegida,
                  title: Text("Femenino"),
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      _generoController.text = "F";
                      titularSave.genero = "F";
                      opcionElegida = val;
                    });
                    //print("Radio $val");
                    //setOpcionElegida(val);
                    //titularSave.genero = val;
                    //print(titularSave.genero);
                  },
                ),
                RadioListTile(
                  value: "E",
                  groupValue: opcionElegida,
                  title: Text("Empresa"),
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      _generoController.text = "E";
                      titularSave.genero = "E";
                      opcionElegida = val;
                    });
                    //print("Radio $val");
                    //setOpcionElegida(val);
                    //titularSave.genero = val;
                    //print(titularSave.genero);
                  },
                ),

                const SizedBox(height: 24.0),
                Container(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      RaisedButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: const Text('CONSULTAR'),
                        onPressed: _handleSubmitted,
                      ),
                      RaisedButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: const Text('NUEVA CONSULTA'),
                        onPressed: _limpiarControles,
                      ),
                    ])),
                const SizedBox(height: 24.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        autofocus: false,
                        //initialValue: 'alucard@gmail.com',
                        controller: _cuilController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          //icon: Icon(Icons.file_present),
                          hintText: 'Cuil/Cuit',
                          labelText: 'Cuil/Cuit',
                          //enabled: false,
                          //prefixText: '+54 9 ',
                        ),
                        // validator: (input) {
                        //   if (input.isEmpty || input.length <= 6) {
                        //     return 'Ingrese su número de documento';
                        //   }
                        // },
                        // onSaved: (String value) {
                        //   titularSave.cuil = _calcularCuil;
                        // },
                        //onSaved: (input) => _cuil = input,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy),
                      color: Colors.blue,
                      onPressed: () {
                        if (calculoRealizado) {
                          _handCopiar();
                        }
                      }, //
                    ),
                    IconButton(
                      icon: Icon(Icons.share),
                      color: Colors.blue,
                      onPressed: () {
                        if (calculoRealizado) {
                          launchWhatsApp(
                              phone: null, message: _cuilController.text);
                        }
                      }, //
                    ),
                  ],
                ),

                // Text('* indica que campos son obligatorios',
                //     style: Theme.of(context).textTheme.caption),
                // const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
        child: Icon(Icons.exit_to_app),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Format incoming numeric text to fit the format of (###) ###-#### ##...
class _UsNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();
    // if (newTextLength >= 1) {
    //   newText.write('(');
    //   if (newValue.selection.end >= 1) selectionIndex++;
    // }
    if (newTextLength > 3) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 3) + '.');
      if (newValue.selection.end >= 3) selectionIndex++;
    }
    if (newTextLength > 6) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 6) + '.');
      if (newValue.selection.end >= 6) selectionIndex++;
    }
    // if (newTextLength >= 11) {
    //   newText.write(newValue.text.substring(6, usedSubstringIndex = 10) + ' ');
    //   if (newValue.selection.end >= 10) selectionIndex++;
    // }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
