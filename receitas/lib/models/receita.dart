
class Receita {
  final String id;
  final String nome;
  final String tipo;
  final String ingredientes;
  final String modoPreparo;
  final String imagem;
  final double custo;

  const Receita({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.ingredientes,
    required this.modoPreparo,
    required this.imagem,
    required this.custo,
  });

  factory Receita.fromJson(Map<String, dynamic> json) {
    String valor(List<String> chaves) {
      for (final chave in chaves) {
        if (json[chave] != null) {
          return json[chave].toString();
        }
      }
      return '';
    }

    return Receita(
      id: valor(['id', '_id']),
      nome: valor(['nome']),
      tipo: valor(['tipo']),
      ingredientes: valor(['ingredientes']),
      modoPreparo: valor(['modoFazer']),
      imagem: valor(['img']),
      custo: double.tryParse(
            valor(['custoAproximado']).replaceAll(',', '.'),
          ) ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'tipo': tipo,
      'ingredientes': ingredientes,
      'modoFazer': modoPreparo,
      'img': imagem,
      'custoAproximado': custo,
    };
  }
}
