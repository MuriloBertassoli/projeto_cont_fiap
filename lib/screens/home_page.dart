import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pessoa.dart';
import '../widgets/pessoa_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  final List<Pessoa> _pessoas = [];
  final int capacidadeMaxima = 15;

  int get pessoasNoAmbiente =>
      _pessoas.where((pessoa) => pessoa.estaNoAmbiente).length;

  String get mensagemSituacao {
    if (pessoasNoAmbiente >= capacidadeMaxima) {
      return 'Ambiente lotado!';
    } else if (pessoasNoAmbiente >= 10) {
      return 'Atenção: ambiente quase cheio!';
    } else {
      return 'Pode entrar!';
    }
  }

  Color get corSituacao {
    if (pessoasNoAmbiente >= capacidadeMaxima) {
      return const Color(0xFFFF1744);
    } else if (pessoasNoAmbiente >= 10) {
      return const Color(0xFFFF9100);
    } else {
      return const Color(0xFF00E676);
    }
  }

  void _mostrarFeedback(String mensagem, {Color corFundo = const Color(0xFF2E1A36)}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: corFundo,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _cadastrarPessoa() {
    final nome = _nomeController.text.trim();
    final identificacao = _idController.text.trim();

    if (nome.isEmpty || identificacao.isEmpty) {
      _mostrarFeedback(
        'Preencha o nome e a identificação/matrícula para cadastrar!',
        corFundo: const Color(0xFFD50000),
      );
      return;
    }

    if (pessoasNoAmbiente >= capacidadeMaxima) {
      _mostrarFeedback(
        'Não é possível realizar a entrada. Ambiente lotado!',
        corFundo: const Color(0xFFD50000),
      );
      return;
    }

    final idDuplicado = _pessoas.any(
      (p) =>
          p.identificacao.toLowerCase() == identificacao.toLowerCase() &&
          p.estaNoAmbiente,
    );

    if (idDuplicado) {
      _mostrarFeedback(
        'Já existe uma pessoa no ambiente com esta identificação!',
        corFundo: const Color(0xFFD50000),
      );
      return;
    }

    final novaPessoa = Pessoa(
      nome: nome,
      identificacao: identificacao,
      dataEntrada: DateTime.now(),
    );

    setState(() {
      _pessoas.insert(0, novaPessoa);
      _nomeController.clear();
      _idController.clear();
    });

    FocusScope.of(context).unfocus();

    _mostrarFeedback(
      'Pessoa cadastrada com sucesso!',
      corFundo: const Color(0xFF00C853),
    );
  }

  void _solicitarSaida(Pessoa pessoa) {
    // Regra 2 — Saída: não registrar saída duas vezes
    if (!pessoa.estaNoAmbiente) {
      _mostrarFeedback(
        '${pessoa.nome} já teve a saída registrada anteriormente!',
        corFundo: const Color(0xFFFF6D00),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1124),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE91E63), width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFFF9100)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Registrar saída?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Deseja realmente registrar a saída de ${pessoa.nome}?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8F00),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                pessoa.registrarSaida();
              });
              Navigator.of(ctx).pop();
              _mostrarFeedback(
                'Saída registrada com sucesso!',
                corFundo: const Color(0xFFEF6C00),
              );
            },
            child: Text(
              'CONFIRMAR',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _solicitarExclusao(Pessoa pessoa) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1124),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD50000), width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF1744)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Excluir registro?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Deseja realmente excluir o registro de ${pessoa.nome} (ID: ${pessoa.identificacao})?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD50000),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _pessoas.remove(pessoa);
              });
              Navigator.of(ctx).pop();
              _mostrarFeedback(
                'Registro de ${pessoa.nome} excluído com sucesso!',
                corFundo: const Color(0xFFC62828),
              );
            },
            child: Text(
              'CONFIRMAR',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120717),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/images.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: const Color(0xFF0D0412).withOpacity(0.76),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabeçalho e Status do Ambiente
                  Center(
                    child: Text(
                      'Seja bem-vindo(a) ao nosso cabarê!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1124).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: corSituacao.withOpacity(0.7),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mensagemSituacao,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: corSituacao,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Capacidade máxima: $capacidadeMaxima pessoas',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF120717),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE91E63)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.groups_rounded,
                                color: Color(0xFFE91E63),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$pessoasNoAmbiente / $capacidadeMaxima',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Área de Cadastro de Pessoas (Critério 1)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1124).withOpacity(0.88),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE91E63).withOpacity(0.45),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Color(0xFFE91E63),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Registrar Entrada de Pessoa',
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nomeController,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Nome da pessoa',
                            labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                            prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFFE91E63)),
                            filled: true,
                            fillColor: const Color(0xFF120717).withOpacity(0.8),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE91E63), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _idController,
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  labelText: 'Identificação / Matrícula',
                                  labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                                  prefixIcon: const Icon(Icons.pin_outlined, color: Color(0xFFE91E63)),
                                  filled: true,
                                  fillColor: const Color(0xFF120717).withOpacity(0.8),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.white24),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE91E63), width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _cadastrarPessoa,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE91E63),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.login_rounded, size: 18),
                              label: Text(
                                'Entrar',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cabeçalho da Lista de Pessoas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.fact_check_outlined,
                            color: Color(0xFFF8BBD0),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Registros de Acesso (${_pessoas.length})',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Deslize para Saída / Excluir',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Lista de Pessoas usando ListView (Critério 2)
                  Expanded(
                    child: _pessoas.isEmpty
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F1124).withOpacity(0.75),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.people_outline_rounded,
                                    size: 46,
                                    color: Colors.white54,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nenhuma pessoa registrada ainda.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _pessoas.length,
                            itemBuilder: (context, index) {
                              final pessoa = _pessoas[index];
                              return PessoaItem(
                                pessoa: pessoa,
                                onSaida: () => _solicitarSaida(pessoa),
                                onExcluir: () => _solicitarExclusao(pessoa),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}