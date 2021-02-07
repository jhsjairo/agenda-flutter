import 'dart:convert';

import 'package:agenda/models/Enderecos.dart';
import 'package:agenda/models/EnderecosRepositorio.dart';
import 'package:flutter/material.dart';
import 'package:agenda/Config.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

class Enderecos extends StatefulWidget {
  int contatoId = 0;
  int id = 0;
  String contato;
  Enderecos(this.contatoId,this.contato,{ this.id});

  @override
  _EnderecosState createState() => _EnderecosState();
}

class _EnderecosState extends State<Enderecos> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();


  TextEditingController _logradouroController;
  TextEditingController _numeroController;
  TextEditingController _complementoController;
  TextEditingController _bairroController;
  TextEditingController _cepController;
  TextEditingController _cidadeController;
  TextEditingController _ufController;

  bool switchRegimeEspecial = false;



  @override
  void initState() {
    super.initState();

    _logradouroController = TextEditingController();
    _numeroController = TextEditingController();
    _complementoController = TextEditingController();
    _bairroController = TextEditingController();
    _cepController = TextEditingController();
    _cidadeController = TextEditingController();
    _ufController = TextEditingController();

    carregaRegistro();
  }

  salvar(BuildContext context) async {
    try {
      var rp = EnderecosRepositorio();

      EnderecosModel ob = new EnderecosModel();

      ob.id = widget.id;
      ob.contatoId = widget.contatoId;
      ob.logradouro = _logradouroController.text;
      ob.numero = _numeroController.text;
      ob.bairro = _bairroController.text;
      ob.cidade = _cidadeController.text;
      ob.uf = _ufController.text;
      ob.cep = _cepController.text;
      ob.complemento = _complementoController.text;

      await rp.inserir(ob);

      Navigator.pop(context);
    } catch (e) {
      Config.mensagem(context, e.toString());
    }
  }

  
  
  void _showDialogExcluir(  int id) {
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Atenção"),
          content: new Text("Deseja realmente excluir?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Excluir"),
              onPressed: () {
                 Navigator.of(context).pop();
                _excluir(context,id);
              },
            ),
          ],
        );
      },
    );
  }


  void _excluir(BuildContext context, int id) async {
    if (id > 0) {
      var rp  = new EnderecosRepositorio();
      var r = await rp.excluir(id);

      if (r > 0) {
        Navigator.pop(context);
      } else {
        Config.mensagem(context, "Erro ao excluir");
      }
    }
  }

  void carregaRegistro() async {
    EnderecosRepositorio r = new EnderecosRepositorio();
    var dados = await r.listar(filtro: "WHERE id =" + widget.id.toString());

    setState(() {
      for (var linha in dados) {
        widget.id = Config.intFormat(linha["id"].toString());

        _logradouroController.text = linha["logradouro"].toString();
        _numeroController.text = linha["numero"].toString();
        _complementoController.text = linha["complemento"].toString();
        _bairroController.text = linha["bairro"].toString();
        _cepController.text = linha["cep"].toString();
        _cidadeController.text = linha["cidade"].toString();
        _ufController.text = linha["uf"].toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          
          title: Text(
            widget.contatoId.toString() + " - " + widget.contato.toString().replaceAll("null", "") ,
            
          ),
          
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  salvar(context);
                } else {
                  Config.mensagem(context, "Campos obrigatórios não informados");
                }
              },
            ),

            if (widget.id != null)
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDialogExcluir( widget.id);
                },
              ),
          ],
        ),
        body: Form(key: _formKey, child: formEndereco()),
      ),
    );
  }

  _buscaCep(BuildContext context) async {

    if(_cepController.text.trim() == null || _cepController.text.trim().length != 8){
      return  Config.mensagem(context, "CEP inválido");
    }

    ProgressDialog pr = new ProgressDialog(context);
    try {
      pr.show();
      pr.update(message: "Aguarde, buscando cep...");
      var cep = _cepController.text.replaceAll("-", "").replaceAll(".", "").trim();
      var data;
      var url = "https://viacep.com.br/ws/" + Config.intFormat(cep).toString() + "/json";

      var response = await http.get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        data = json.decode(response.body);
        setState(() {
          _logradouroController.text = data["logradouro"].toString().replaceAll("null", "");
          _bairroController.text = data["bairro"].toString().replaceAll("null", "");
          _complementoController.text = data["complemento"].toString().replaceAll("null", "");
          _ufController.text = data["uf"].toString().replaceAll("null", "");
          _cidadeController.text = data["localidade"].toString().replaceAll("null", "");
        });

        if(data["erro"].toString() == "true"){
             pr.hide();
            Config.mensagem(context, "CEP inválido");
        }

      } else {
         pr.hide();
        Config.mensagem(context, "CEP inválido");
      }

      pr.hide();
    } catch (e) {
      pr.hide();
      Config.mensagem(context, e.toString());
    }
  }

  Widget formEndereco() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Informações do endereço",
              style: TextStyle(fontSize: 20, color: Colors.lightGreen),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              child: TextFormField(
                 validator: (value) {
                      if (value.isEmpty) {
                        return 'Campo obrigatorio';
                      }
                      return null;
                    },
                keyboardType: TextInputType.number,
                controller: _cepController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: _ufController.text == '' ? Icon(Icons.search) : Icon(Icons.clear),
                    onPressed: () {
                      _buscaCep(context);
                    },
                  ),
                  labelText: "CEP",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Campo obrigatorio';
                      }
                      return null;
                    },
                    controller: _logradouroController,
                    decoration: InputDecoration(
                      labelText: "*Logradouro",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 100,
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Campo obrigatorio';
                      }
                      return null;
                    },
                    controller: _numeroController,
                    decoration: InputDecoration(
                      labelText: "*Numero",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _complementoController,
              decoration: InputDecoration(
                labelText: "Complemento",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Campo obrigatorio';
                      }
                      return null;
                    },
                    controller: _bairroController,
                    decoration: InputDecoration(
                      labelText: "*Bairro",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Campo obrigatorio';
                      }
                      return null;
                    },
                    controller: _cidadeController,
                    decoration: InputDecoration(
                      labelText: "*Cidade",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 100,
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Campo obrigatorio';
                      }
                      return null;
                    },
                    controller: _ufController,
                    decoration: InputDecoration(
                      labelText: "*UF",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton.icon(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    salvar(context);
                  } else {
                    Config.mensagem(context, "Campos obrigatórios não informados");
                  }
                },
                elevation: 2.0,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                color: Colors.blue,
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                label: Text(
                  "Salvar",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

 
}
