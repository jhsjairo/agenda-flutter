import 'package:agenda/models/EnderecosRepositorio.dart';
import 'package:flutter/material.dart';
import 'package:agenda/Config.dart';

import 'package:agenda/models/Contato.dart';
import 'package:agenda/models/ContatoRepositorio.dart';
import 'package:agenda/modules/contatos/Enderecos.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart';

class Contato extends StatefulWidget {
  int id = 0;

  Contato({this.id});

  @override
  _ContatoState createState() => _ContatoState();
}

class _ContatoState extends State<Contato> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  var dadosEndereco;
  TabController _tabController;
  ProgressDialog pr;

  TextEditingController _nomeController;

  TextEditingController _emailController;

  TextEditingController _foneController;

  TextEditingController _dataCadastroController;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController();

    _emailController = TextEditingController();

    _foneController = TextEditingController();
    _dataCadastroController = TextEditingController();

    _tabController = TabController(length: 2, vsync: this);

    carregaRegistro();
  }

  salvar(BuildContext context) async {
    try {
      if (_nomeController.text == null || _nomeController.text.length < 2) {
        return Config.mensagem(context, "nome do contato deve ter no mínimo 2 caracteres");
      }

      DateTime now = DateTime.now();
      String dataCadastro = DateFormat('yyyy-MM-dd').format(now);

      var rp = ContatoRepositorio();

      ContatoModel ob = new ContatoModel();

      ob.id = widget.id;

      ob.nome = _nomeController.text;

      ob.email = _emailController.text;
      ob.fone = _foneController.text;

      if (_dataCadastroController.text != null && _dataCadastroController.text != "") {
        ob.dataCadastro = Config.dataFormat(_dataCadastroController.text);
      } else {
        ob.dataCadastro = dataCadastro;
      }

      widget.id = await rp.inserir(ob);
      carregaRegistro();

      await Config.mensagem(context, "Cadastrado com Sucesso!");
    } catch (e) {
      Config.mensagem(context, e.toString());
    }
  }

  _detalharEndereco(BuildContext contextSnak, int index) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Enderecos(
                  widget.id,
                  _nomeController.text,
                  id: Config.intFormat(dadosEndereco[index]["id"].toString()),
                )));

    carregarEnderecos();
  }

  void _showDialogExcluir(int id) {
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
                _excluir(context, id);
              },
            ),
          ],
        );
      },
    );
  }

  void _excluir(BuildContext context, int id) async {
    if (id > 0) {
      var rp = ContatoRepositorio();
      var r = await rp.excluir(widget.id);

      if (r > 0) {
        Navigator.pop(context);
      } else {
        Config.mensagem(context, "Erro ao excluir");
      }
    }
  }

  void carregaRegistro() async {
    ContatoRepositorio r = new ContatoRepositorio();
    var dados = await r.listar(filtro: "WHERE id =" + widget.id.toString());

    setState(() {
      for (var linha in dados) {
        widget.id = Config.intFormat(linha["id"].toString());

        _nomeController.text = linha["nome"].toString();
        _emailController.text = linha["email"].toString();
        _foneController.text = linha["fone"].toString();
        var now = DateTime.parse(linha["data_cadastro"].toString());

        _dataCadastroController.text = DateFormat('dd/MM/yyyy').format(now);
      }
    });
  }

  Future carregarEnderecos() async {
    EnderecosRepositorio r = new EnderecosRepositorio();
    await r.listar(filtro: "where contato_id =" + widget.id.toString()).then((value) => {dadosEndereco = value});

    return dadosEndereco;
  }

  _abrirEndereco(BuildContext context) async {
    if (widget.id == null || widget.id == 0) {
      return Config.mensagem(context, "Cadastre um contato antes de adicionar os endereços");
    }

    await Navigator.push(context, MaterialPageRoute(builder: (context) => Enderecos(widget.id, _nomeController.text)));

    carregaRegistro();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                  // iconTheme: IconThemeData(color: Colors.blue),
                  title: Text(
                    (widget.id.toString() != "null"
                        ? widget.id.toString().replaceAll("null", "") + " - " + _nomeController.text
                        : "Novo Contato"),
                    // style: TextStyle(color: widget.config.corTextoAppBar),
                  ),
                  // backgroundColor: widget.config.corAppBar,
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
                          _showDialogExcluir(widget.id);
                        },
                      ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    labelStyle: TextStyle(fontSize: 16),
                    labelColor: Colors.white,
                    indicatorColor: Colors.grey,
                    isScrollable: true,
                    tabs: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Tab(text: "Dados"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Tab(text: "Endereços"),
                      ),
                    ],
                  )),
              body: TabBarView(
                  controller: _tabController,
                  children: <Widget>[Form(key: _formKey, child: tabDados()), _tabEndereco(context)])),
        ));
  }

  Widget tabDados() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Informações do Contato",
              style: TextStyle(fontSize: 20, color: Colors.lightGreen),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Campo obrigatorio';
                }
                return null;
              },
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: "*Nome",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _foneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Telefone",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "E-mail",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text("Data Inclusão: " + _dataCadastroController.text),
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

  Widget _tabEndereco(context) {
    // return Stack(children: <Widget>[

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton.icon(
                onPressed: () {
                  _abrirEndereco(context);
                },
                elevation: 2.0,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                color: Colors.blue,
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  "Adicionar Endereço",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          GestureDetector(
            child: Container(
                height: MediaQuery.of(context).size.height - 150,
                child: new FutureBuilder(
                    future: carregarEnderecos(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default:
                          if (snapshot.hasError)
                            return new Text('Error: ${snapshot.error}');
                          else
                            return ListView.builder(
                              padding: EdgeInsets.all(10),
                              itemBuilder: (context, index) {
                                return _listaEderecos(context, index);
                              },
                              itemCount: dadosEndereco != null ? dadosEndereco.length : 0,
                            );
                      }
                    })),
          ),
        ],
      ),
    );

    // ]);
  }

  Widget _listaEderecos(context, index) {
    return GestureDetector(
        onTap: () {
          _detalharEndereco(context, index);
        },
        child: Container(
            child: Card(
          margin: EdgeInsets.all(5),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 8),
                    // decoration: BoxDecoration(
                    //   shape: BoxShape.circle,
                    // ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            dadosEndereco[index]["logradouro"].toString().toUpperCase() +
                                " " +
                                dadosEndereco[index]["numero"].toString().toUpperCase() +
                                " - " +
                                dadosEndereco[index]["complemento"].toString().toUpperCase() +
                                " - " +
                                dadosEndereco[index]["bairro"].toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            dadosEndereco[index]["cidade"].toUpperCase().toString() +
                                " - " +
                                dadosEndereco[index]["uf"].toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "CEP: " + dadosEndereco[index]["cep"].toString(),
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )));
  }

  
}
