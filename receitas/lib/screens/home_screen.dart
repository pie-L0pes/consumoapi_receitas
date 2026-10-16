
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receita.dart';
import '../services/receita_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = ReceitaService();
  final busca = TextEditingController();
  List<Receita> receitas = [];
  bool carregando = true;
  String? erro;
  int aba = 0;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  void dispose() {
    busca.dispose();
    super.dispose();
  }

  Future<void> carregar() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final resultado = await service.listar();
      if (mounted) setState(() => receitas = resultado);
    } catch (e) {
      if (mounted) setState(() => erro = e.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> abrirFormulario([Receita? receita]) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioReceita(
          service: service,
          receita: receita,
        ),
      ),
    );
    if (alterou == true && mounted) carregar();
  }

  Future<void> excluir(Receita receita) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir receita?'),
        content: Text('Deseja excluir "${receita.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;
    try {
      await service.excluir(receita.id);
      if (mounted) {
        mensagem('Receita excluída!');
        carregar();
      }
    } catch (e) {
      if (mounted) mensagem('Não foi possível excluir: $e');
    }
  }

  void mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final filtradas = receitas.where((r) {
      final termo = busca.text.toLowerCase();
      return r.nome.toLowerCase().contains(termo) ||
          r.tipo.toLowerCase().contains(termo);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          aba == 0 ? 'Minhas receitas' : 'Nova receita',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (aba == 0)
            IconButton(
              onPressed: carregar,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: aba == 1
          ? FormularioReceita(
              service: service,
              incorporado: true,
              aoSalvar: () {
                setState(() => aba = 0);
                carregar();
              },
            )
          : RefreshIndicator(
              onRefresh: carregar,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Seu livro de sabores',
                    style: TextStyle(
                      fontSize: 14,
                      color: cores.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'O que vamos cozinhar?',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: busca,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar uma receita...',
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (carregando)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (erro != null)
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 44),
                          const SizedBox(height: 12),
                          Text(
                            'Não foi possível acessar a API.\n$erro',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: carregar,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    )
                  else if (filtradas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text('Nenhuma receita encontrada.'),
                      ),
                    )
                  else
                    ...filtradas.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Card(
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetalhesReceita(
                                    receita: r,
                                    editar: () => abrirFormulario(r),
                                    excluir: () => excluir(r),
                                  ),
                                ),
                              );
                              if (mounted) carregar();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  ImagemReceita(
                                    url: r.imagem,
                                    largura: 88,
                                    altura: 88,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.nome,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          r.tipo,
                                          style: TextStyle(
                                            color: cores.secondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          moeda(r.custo),
                                          style: TextStyle(
                                            color: cores.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (v) {
                                      if (v == 'editar') {
                                        abrirFormulario(r);
                                      } else {
                                        excluir(r);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'editar',
                                        child: Text('Editar'),
                                      ),
                                      PopupMenuItem(
                                        value: 'excluir',
                                        child: Text('Excluir'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: aba,
        onTap: (v) => setState(() => aba = v),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Receitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'Nova',
          ),
        ],
      ),
      floatingActionButton: aba == 0
          ? FloatingActionButton(
              onPressed: () => setState(() => aba = 1),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

String moeda(double valor) {
  return NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  ).format(valor);
}

class ImagemReceita extends StatelessWidget {
  final String url;
  final double largura;
  final double altura;

  const ImagemReceita({
    super.key,
    required this.url,
    required this.largura,
    required this.altura,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: largura,
        height: altura,
        child: url.isEmpty
            ? const ColoredBox(
                color: Color(0xFFF2E4D8),
                child: Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFFAD6D4C),
                  size: 34,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFF2E4D8),
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }
}

class DetalhesReceita extends StatelessWidget {
  final Receita receita;
  final VoidCallback editar;
  final VoidCallback excluir;

  const DetalhesReceita({
    super.key,
    required this.receita,
    required this.editar,
    required this.excluir,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              editar();
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              excluir();
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          ImagemReceita(
            url: receita.imagem,
            largura: double.infinity,
            altura: 240,
          ),
          const SizedBox(height: 22),
          Text(
            receita.nome,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            receita.tipo,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Custo estimado: ${moeda(receita.custo)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Ingredientes',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            receita.ingredientes,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 26),
          const Text(
            'Modo de preparo',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            receita.modoPreparo,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class FormularioReceita extends StatefulWidget {
  final ReceitaService service;
  final Receita? receita;
  final bool incorporado;
  final VoidCallback? aoSalvar;

  const FormularioReceita({
    super.key,
    required this.service,
    this.receita,
    this.incorporado = false,
    this.aoSalvar,
  });

  @override
  State<FormularioReceita> createState() => _FormularioReceitaState();
}

class _FormularioReceitaState extends State<FormularioReceita> {
  final form = GlobalKey<FormState>();
  late final TextEditingController nome;
  late final TextEditingController ingredientes;
  late final TextEditingController preparo;
  late final TextEditingController imagem;
  late final TextEditingController custo;
  String tipo = 'DOCE';
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    final r = widget.receita;
    nome = TextEditingController(text: r?.nome ?? '');
    ingredientes = TextEditingController(text: r?.ingredientes ?? '');
    preparo = TextEditingController(text: r?.modoPreparo ?? '');
    imagem = TextEditingController(text: r?.imagem ?? '');
    custo = TextEditingController(
      text: r == null ? '' : r.custo.toStringAsFixed(2),
    );
    if (['DOCE', 'SALGADA', 'BEBIDA'].contains(r?.tipo)) {
      tipo = r!.tipo;
    }
  }

  @override
  void dispose() {
    for (final c in [nome, ingredientes, preparo, imagem, custo]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> salvar() async {
    if (!form.currentState!.validate()) return;
    setState(() => salvando = true);

    final receita = Receita(
      id: widget.receita?.id ?? '',
      nome: nome.text.trim(),
      tipo: tipo,
      ingredientes: ingredientes.text.trim(),
      modoPreparo: preparo.text.trim(),
      imagem: imagem.text.trim(),
      custo: double.parse(custo.text.trim().replaceAll(',', '.')),
    );

    try {
      if (widget.receita == null) {
        await widget.service.criar(receita);
      } else {
        await widget.service.atualizar(receita);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receita salva com sucesso!')),
      );

      if (widget.incorporado) {
        widget.aoSalvar?.call();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conteudo = SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.receita == null
                  ? 'Uma nova delícia'
                  : 'Editar receita',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Guarde os sabores que você ama.'),
            const SizedBox(height: 24),
            campo('Nome da receita', nome),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de receita',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'DOCE',
                  child: Text('Doce'),
                ),
                DropdownMenuItem(
                  value: 'SALGADA',
                  child: Text('Salgada'),
                ),
                DropdownMenuItem(
                  value: 'BEBIDA',
                  child: Text('Bebida'),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => tipo = v);
              },
            ),
            const SizedBox(height: 14),
            campo('Ingredientes', ingredientes, linhas: 4),
            const SizedBox(height: 14),
            campo('Modo de preparo', preparo, linhas: 5),
            const SizedBox(height: 14),
            campo(
              'URL da imagem',
              imagem,
              obrigatorio: false,
              teclado: TextInputType.url,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: custo,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Custo (R\$)',
              ),
              validator: (v) {
                final numero = double.tryParse(
                  (v ?? '').trim().replaceAll(',', '.'),
                );
                if (numero == null || !numero.isFinite || numero < 0) {
                  return 'Informe um custo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: salvando ? null : salvar,
              icon: salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                widget.receita == null
                    ? 'Salvar receita'
                    : 'Atualizar receita',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(17),
              ),
            ),
          ],
        ),
      ),
    );

    return widget.incorporado
        ? conteudo
        : Scaffold(
            appBar: AppBar(title: const Text('Editar receita')),
            body: conteudo,
          );
  }

  Widget campo(
    String rotulo,
    TextEditingController controller, {
    int linhas = 1,
    bool obrigatorio = true,
    TextInputType? teclado,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: linhas,
      keyboardType: teclado,
      decoration: InputDecoration(
        labelText: rotulo,
        alignLabelWithHint: linhas > 1,
      ),
      validator: (v) {
        if (obrigatorio && (v == null || v.trim().isEmpty)) {
          return 'Preencha este campo';
        }
        return null;
      },
    );
  }
}
