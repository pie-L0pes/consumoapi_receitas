
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/receita.dart';

class ReceitaService {
  static const String baseUrl = 'https://receitasapi-b-2025.vercel.app';
  static const String caminho = '/receitas';

  Uri url([String id = '']) {
    final base = Uri.parse('$baseUrl$caminho');
    return id.isEmpty ? base : base.replace(pathSegments: [...base.pathSegments.where((s) => s.isNotEmpty), id]);
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  Future<List<Receita>> listar() async {
    try {
      final resposta = await http.get(
        url(),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      verificar(resposta);

      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      final lista = dados is List
          ? dados
          : dados is Map
              ? dados['receitas'] ?? dados['data'] ?? dados['dados']
              : null;

      if (lista is! List) {
        throw Exception('Formato de resposta inesperado da API.');
      }

      return lista.map((item) {
        return Receita.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar receitas: $e');
    }
  }

  Future<Receita> buscarPorId(String id) async {
    if (id.isEmpty) {
      throw Exception('ID da receita não informado.');
    }

    try {
      final resposta = await http.get(
        url(id),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      verificar(resposta);

      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      final receita = dados is Map && dados['receita'] is Map
          ? dados['receita']
          : dados;

      return Receita.fromJson(
        Map<String, dynamic>.from(receita as Map),
      );
    } catch (e) {
      throw Exception('Erro ao buscar receita: $e');
    }
  }

  Future<void> criar(Receita receita) async {
    try {
      final resposta = await http.post(
        url(),
        headers: headers,
        body: jsonEncode(receita.toJson()),
      ).timeout(const Duration(seconds: 30));

      verificar(resposta);
    } catch (e) {
      throw Exception('Erro ao cadastrar receita: $e');
    }
  }

  Future<void> atualizar(Receita receita) async {
    if (receita.id.isEmpty) {
      throw Exception('ID da receita não informado.');
    }

    try {
      final resposta = await http.put(
        url(receita.id),
        headers: headers,
        body: jsonEncode(receita.toJson()),
      ).timeout(const Duration(seconds: 30));

      verificar(resposta);
    } catch (e) {
      throw Exception('Erro ao atualizar receita: $e');
    }
  }

  Future<void> excluir(String id) async {
    if (id.isEmpty) {
      throw Exception('ID da receita não informado.');
    }

    try {
      final resposta = await http.delete(
        url(id),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      verificar(resposta);
    } catch (e) {
      throw Exception('Erro ao excluir receita: $e');
    }
  }

  void verificar(http.Response resposta) {
    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      return;
    }

    final corpo = utf8.decode(resposta.bodyBytes);

    String mensagem = corpo;

    try {
      final dados = jsonDecode(corpo);
      if (dados is Map) {
        mensagem = (dados['message'] ??
                dados['mensagem'] ??
                dados['error'] ??
                dados['erro'] ??
                corpo)
            .toString();
      }
    } catch (_) {}

    if (mensagem.trim().isEmpty) {
      mensagem = 'Não foi possível completar a solicitação.';
    }

    throw Exception('Erro ${resposta.statusCode}: $mensagem');
  }
}
