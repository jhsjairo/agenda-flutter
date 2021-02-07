import 'package:flutter/material.dart';

import 'package:agenda/modules/contatos/ContatoLista.dart';
import 'package:flutter_localizations/flutter_localizations.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agenda de Contatos',
      
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        // const Locale('es'), // Spanish
        // const Locale('fr'), // French
        // const Locale('zh'),
        const Locale('pt'), // 
      ],
      home: ContatoLista(),
      // home: TesteCnpj(),
      
    );
  }
}


