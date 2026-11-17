import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/territorio.dart';

typedef LeitorDeAsset = Future<String> Function(String caminho);

class TerritorioRepositorio {
  TerritorioRepositorio({LeitorDeAsset? leitor}) : _leitor = leitor ?? rootBundle.loadString;

  static const caminho = 'assets/dados/territorio.json';

  final LeitorDeAsset _leitor;

  Future<Territorio> carregar() async {
    final bruto = await _leitor(caminho);
    return Territorio.fromJson(jsonDecode(bruto) as Map<String, dynamic>);
  }
}
