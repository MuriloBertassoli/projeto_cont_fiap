class Pessoa {
  String nome;
  String identificacao;
  DateTime dataEntrada;
  DateTime? dataSaida;

  Pessoa({
    required this.nome,
    required this.identificacao,
    required this.dataEntrada,
    this.dataSaida,
  });

  bool get estaNoAmbiente => dataSaida == null;

  String get situacao => estaNoAmbiente ? 'No ambiente' : 'Saiu';

  void registrarSaida() {
    dataSaida = DateTime.now();
  }
}
