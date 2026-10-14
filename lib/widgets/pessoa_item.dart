import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/pessoa.dart';

class PessoaItem extends StatelessWidget {
  final Pessoa pessoa;
  final VoidCallback onSaida;
  final VoidCallback onExcluir;

  const PessoaItem({
    super.key,
    required this.pessoa,
    required this.onSaida,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final formatadorData = DateFormat("dd/MM/yyyy 'às' HH:mm");
    final dataEntradaStr = formatadorData.format(pessoa.dataEntrada);
    final dataSaidaStr = pessoa.dataSaida != null
        ? formatadorData.format(pessoa.dataSaida!)
        : null;

    final corStatus = pessoa.estaNoAmbiente
        ? const Color(0xFF00E676)
        : const Color(0xFFB0BEC5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Slidable(
        key: ValueKey('${pessoa.identificacao}_${pessoa.dataEntrada.millisecondsSinceEpoch}'),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.52,
          children: [
            SlidableAction(
              onPressed: (_) => onSaida(),
              backgroundColor: const Color(0xFFFF8F00),
              foregroundColor: Colors.white,
              icon: Icons.logout_rounded,
              label: 'SAÍDA',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
            ),
            SlidableAction(
              onPressed: (_) => onExcluir(),
              backgroundColor: const Color(0xFFD50000),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline_rounded,
              label: 'EXCLUIR',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(14),
              ),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1124).withOpacity(0.88),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: pessoa.estaNoAmbiente
                  ? const Color(0xFFE91E63).withOpacity(0.55)
                  : const Color(0xFF546E7A).withOpacity(0.4),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: corStatus.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: corStatus, width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    pessoa.estaNoAmbiente
                        ? Icons.person_pin_circle_rounded
                        : Icons.person_off_rounded,
                    color: corStatus,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pessoa.nome,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${pessoa.identificacao}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFFF8BBD0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Entrada: $dataEntradaStr',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    if (dataSaidaStr != null)
                      Text(
                        'Saída: $dataSaidaStr',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFFFCC80),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: corStatus,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Situação: ${pessoa.situacao}',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: corStatus,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pessoa.estaNoAmbiente)
                    IconButton(
                      tooltip: 'Registrar saída',
                      onPressed: onSaida,
                      icon: const Icon(
                        Icons.exit_to_app_rounded,
                        color: Color(0xFFFFAB40),
                      ),
                    ),
                  const Icon(
                    Icons.swipe_left_rounded,
                    color: Colors.white38,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

