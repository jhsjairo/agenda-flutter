import 'dart:math';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class Config {
  String nomeBanco = "database";

  static int intFormat(String valor) {
    int ret = 0;
    try {
      return ret = int.parse(valor);
    } catch (e) {
      return ret;
    }
  }

  static String dataFormat(String valor) {
    try {
      var dateTime1 = DateFormat('dd/MM/yyyy').parse(valor);
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String formatted = formatter.format(dateTime1);

      return formatted;
    } catch (e) {
      return null;
    }
  }

  static String dataConvert(String valor) {
    try {
      var dateTime1 = DateFormat('yyyy-MM-dd').parse(valor);
      DateFormat formatter = DateFormat('dd/MM/yyyy');
      String formatted = formatter.format(dateTime1);

      return formatted;
    } catch (e) {
      return null;
    }
  }

  static double decimalFormat(String valor) {
    double ret = 0;
    try {
      return ret = double.parse(valor);
    } catch (e) {
      return ret;
    }
  }

  static String decimalConvert(double valorValor) {
    try {
      var f = new NumberFormat.currency(locale: 'pt-BR', decimalDigits: 2, symbol: '');
      
      return f.format(valorValor);
    } catch (e) {
      return "0,00";
    }
  }

  static String currency(double valorValor) {
    try {
      var f = new NumberFormat.currency(locale: 'pt-BR', decimalDigits: 2, symbol: 'R\S');
      // f.maximumFractionDigits = 2;
      return f.format(valorValor);
    } catch (e) {
      return "0,00";
    }
  }

  static String numeroConvert(double valorValor) {
    try {
      var f = new NumberFormat.currency(locale: 'pt-BR', decimalDigits: 2, symbol: '');
      
      return f.format(valorValor);
    } catch (e) {
      return "0,00";
    }
  }

  static Future mensagem(BuildContext context, String mensagem) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Aviso"),
            content: new Text(mensagem),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  static double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
}
