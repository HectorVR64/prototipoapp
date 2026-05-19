import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PantallaGrafica extends StatelessWidget {
  final List<Map<String, dynamic>> movimientos;

  const PantallaGrafica({super.key, required this.movimientos});

  @override
  Widget build(BuildContext context) {
    double comida = 0;
    double transporte = 0;
    double casa = 0;
    double ocio = 0;
    double otros = 0;

    for (var movimiento in movimientos) {
      if (movimiento["esGasto"]) {
        String categoria =
            movimiento["categoria"]?.toString() ??
            movimiento["texto"].toString();

        if (categoria.contains("Comida")) {
          comida += movimiento["monto"];
        } else if (categoria.contains("Transporte")) {
          transporte += movimiento["monto"];
        } else if (categoria.contains("Casa")) {
          casa += movimiento["monto"];
        } else if (categoria.contains("Ocio")) {
          ocio += movimiento["monto"];
        } else {
          otros += movimiento["monto"];
        }
      }
    }

    double total = comida + transporte + casa + ocio + otros;

    double porcentaje(double cantidad) {
      if (total == 0) return 0;
      return (cantidad / total) * 100;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gráfica de Gastos"),
        backgroundColor: const Color(0xFF528F8F),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  "Porcentaje de Gastos",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Total de gastos: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 300,

                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 55,

                      sections: [
                        PieChartSectionData(
                          value: comida,
                          title: "${porcentaje(comida).toStringAsFixed(0)}%",
                          color: Colors.orange,
                          radius: 80,
                        ),

                        PieChartSectionData(
                          value: transporte,
                          title:
                              "${porcentaje(transporte).toStringAsFixed(0)}%",
                          color: Colors.blue,
                          radius: 80,
                        ),

                        PieChartSectionData(
                          value: casa,
                          title: "${porcentaje(casa).toStringAsFixed(0)}%",
                          color: Colors.green,
                          radius: 80,
                        ),

                        PieChartSectionData(
                          value: ocio,
                          title: "${porcentaje(ocio).toStringAsFixed(0)}%",
                          color: Colors.purple,
                          radius: 80,
                        ),

                        PieChartSectionData(
                          value: otros,
                          title: "${porcentaje(otros).toStringAsFixed(0)}%",
                          color: Colors.grey,
                          radius: 80,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _filaPorcentaje(
                  "Comida",
                  comida,
                  porcentaje(comida),
                  Colors.orange,
                ),

                _filaPorcentaje(
                  "Transporte",
                  transporte,
                  porcentaje(transporte),
                  Colors.blue,
                ),

                _filaPorcentaje("Casa", casa, porcentaje(casa), Colors.green),

                _filaPorcentaje("Ocio", ocio, porcentaje(ocio), Colors.purple),

                _filaPorcentaje("Otros", otros, porcentaje(otros), Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filaPorcentaje(
    String nombre,
    double monto,
    double porcentaje,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [
          CircleAvatar(radius: 8, backgroundColor: color),

          const SizedBox(width: 10),

          Expanded(child: Text(nombre, style: const TextStyle(fontSize: 16))),

          Text(
            "\$${monto.toStringAsFixed(2)} - ${porcentaje.toStringAsFixed(1)}%",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
