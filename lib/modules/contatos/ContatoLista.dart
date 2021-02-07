
import 'package:agenda/modules/contatos/Contato.dart';
import 'package:agenda/modules/contatos/ContatoOrdenar.dart';
import 'package:flutter/material.dart';
import 'package:agenda/Config.dart';
import 'package:agenda/models/ContatoRepositorio.dart';

import 'ContatoPesquisa.dart';

import '../../Config.dart';

class ContatoLista extends StatefulWidget {
 
  @override
  _ContatoListaState createState() => _ContatoListaState();
}

class _ContatoListaState extends State<ContatoLista> {
 

  var contatos;
  var rp = ContatoRepositorio();

  String _filtro = "";
  String _ordenar = "";

  @override
  void initState() {
    super.initState();

    rp.listar(filtro: _filtro, order: _ordenar).then((lista) {
      
      setState(() {
        contatos = lista;
        
      });
    });

  
  }

  Future<Null> _filtrar() async {
   contatos = await rp
        .listar(filtro: _filtro ,order: _ordenar );
        
      setState(() {
       
      });
    
    return null;
  }



  _detalhar(BuildContext contextSnak, int index) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Contato(
                
                id: Config.intFormat(contatos[index]["id"].toString()),
                )));

    

    _filtrar();
  }

  _novo(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Contato()),
    );

    _filtrar();
  }

  _listaContatos(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
       
          _detalhar(context, index);
        
      },
      child: Container(
          height: 100,
          child: Card(
              elevation: 1,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                            //color: Color(Colors.lightBlue[200]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(Config.intFormat(
                                          contatos[index]["id"].toString()) >
                                      0
                                  ? contatos[index]["nome"][0].toString()
                                              .toUpperCase() +
                                      contatos[index]["nome"][1].toString()
                                              .toUpperCase()
                                  : "".toUpperCase()),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(3),
                                child: Text(
                                  contatos[index]["id"]
                                              .toString()
                                              .toUpperCase() +
                                          " - " +
                                          contatos[index]["nome"]
                                              .toUpperCase() ??
                                      "",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                                 Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text("Fone: " +
                                  contatos[index]["fone"]
                                              .toUpperCase()
                                              .toString() 
                                         ,
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              
                                Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text("E-mail: " +
                                  contatos[index]["email"]
                                              
                                              .toString() 
                                         ,
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text("Data Inclusão: " +
                                 Config.dataConvert( contatos[index]["data_cadastro"]
                                              
                                              .toString() )
                                         ,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue
                                  ),
                                ),
                              ),
                             
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ))),
    );
  }

  void _abrirPesquisa() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContatoPesquisa()));

    if (result != null && result != "") {
      _filtro = result;
      print("FIltro: " + _filtro);
      _filtrar();
    }
  }

  void _abrirOrdenar() async {
    
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContatoOrdenar()));

    if (result != null && result != "") {
      _ordenar = result;
      _filtrar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text(
          'Contatos',
        
        ),
        
        actions: <Widget>[
         
            IconButton(
              icon: Icon(
                Icons.search,
                // color: widget.config.corTextoAppBar,
              ),
              onPressed: () {
                _abrirPesquisa();
              },
            ),
          IconButton(
            icon: Icon(Icons.filter_list, 
            // color: widget.config.corTextoAppBar
            ),
            onPressed: () {
              _abrirOrdenar();
            },
          ),
        
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                // Container(height: 30),
                Expanded(
                    child: RefreshIndicator(
                  child: new FutureBuilder(
                      future: rp.listar(filtro: _filtro,order: _ordenar),
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
                                
                                shrinkWrap: true,
                                padding: EdgeInsets.all(10),
                                itemBuilder: (context, index) {
                                  return _listaContatos(context, index);
                                },
                                itemCount:
                                    contatos != null ? contatos.length : 0,
                              );
                        }
                      }),
                  onRefresh: _filtrar,
                )),
              ],
            ),
          ),
         

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _novo(context);
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
         backgroundColor: Colors.blue,
      ),
    );
  }
}

