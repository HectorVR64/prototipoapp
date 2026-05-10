import 'package:flutter/material.dart';

void main() => runApp(const MiAppFinanzas());

class MiAppFinanzas extends StatelessWidget {
  const MiAppFinanzas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'sans-serif'),
      home: const PantallaDelPrototipo(),
    );
  }
}

class PantallaDelPrototipo extends StatefulWidget {
  const PantallaDelPrototipo({super.key});

  @override
  State<PantallaDelPrototipo> createState() => _EstadoDeMiPantalla();
}

class _EstadoDeMiPantalla extends State<PantallaDelPrototipo> {
  // --- VARIABLES DE ESTADO ---
  double _dineroTotalEnCuenta = 0.0;
  String _numeroQueEstoyEscribiendo = "0";

  String _nombreCategoriaElegida = "Comida";
  IconData _iconoCategoriaElegida = Icons.restaurant;

  final List<Map<String, dynamic>> _listaDeMovimientos = [];

  // --- FUNCIONES DE LÓGICA ---

  void _seleccionarNuevaCategoria(String nombre, IconData icono) {
    setState(() {
      _nombreCategoriaElegida = nombre;
      _iconoCategoriaElegida = icono;
    });
  }

  void _logicaDelTeclado(String valorTecla) {
    setState(() {
      if (valorTecla == "⌫") {
        if (_numeroQueEstoyEscribiendo.length > 1) {
          _numeroQueEstoyEscribiendo = _numeroQueEstoyEscribiendo.substring(
            0,
            _numeroQueEstoyEscribiendo.length - 1,
          );
        } else {
          _numeroQueEstoyEscribiendo = "0";
        }
      } else if (_numeroQueEstoyEscribiendo == "0") {
        _numeroQueEstoyEscribiendo = valorTecla;
      } else {
        _numeroQueEstoyEscribiendo += valorTecla;
      }
    });
  }

  void _finalizarYRegistrarGasto() {
    double cantidadAGastar = double.tryParse(_numeroQueEstoyEscribiendo) ?? 0;
    if (cantidadAGastar <= 0) return;

    setState(() {
      _dineroTotalEnCuenta -= cantidadAGastar;
      _listaDeMovimientos.insert(0, {
        "texto": "$_nombreCategoriaElegida \$$cantidadAGastar",
        "monto": cantidadAGastar,
        "icono": _iconoCategoriaElegida,
        "esGasto": true,
      });
      _numeroQueEstoyEscribiendo = "0";
    });
  }

  // FUNCIÓN PARA ELIMINAR REGISTRO
  void _eliminarRegistro(int indice) {
    final movimiento = _listaDeMovimientos[indice];
    double monto = movimiento["monto"];
    bool esGasto = movimiento["esGasto"];

    setState(() {
      if (esGasto) {
        _dineroTotalEnCuenta += monto; // Reembolsar
      } else {
        _dineroTotalEnCuenta -= monto; // Quitar ingreso
      }
      _listaDeMovimientos.removeAt(indice);
    });
  }

  // --- NUEVA FUNCIÓN: MENÚ ESTILO WHATSAPP ---
  void _mostrarMenuOpciones(
    BuildContext contexto,
    Offset posicionGlobal,
    int indice,
  ) async {
    final resultado = await showMenu(
      context: contexto,
      position: RelativeRect.fromLTRB(
        posicionGlobal.dx,
        posicionGlobal.dy,
        posicionGlobal.dx + 1,
        posicionGlobal.dy + 1,
      ),
      items: [
        const PopupMenuItem(
          value: 'eliminar',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 10),
              Text("Eliminar", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );

    if (resultado == 'eliminar') {
      _eliminarRegistro(indice);
    }
  }

  void _abrirPanelDeIngreso() {
    TextEditingController controladorDeTexto = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Registrar Ingreso 💰",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: controladorDeTexto,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "¿Cuánto dinero entró?",
                prefixText: "\$ ",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF528F8F),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                double montoEntrante =
                    double.tryParse(controladorDeTexto.text) ?? 0;
                if (montoEntrante > 0) {
                  setState(() {
                    _dineroTotalEnCuenta += montoEntrante;
                    _listaDeMovimientos.insert(0, {
                      "texto": "Ingreso: +\$$montoEntrante",
                      "monto": montoEntrante,
                      "icono": Icons.add_card,
                      "esGasto": false,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Sumar a mi Cartera",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra Superior
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xFF528F8F),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: const Center(
                child: Text(
                  "Control de Mis Gastos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 2. Sección Central
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  const Text(
                    "Saldo disponible actualmente:",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "\$${_dineroTotalEnCuenta.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF425C5C),
                        ),
                      ),
                      IconButton(
                        onPressed: _abrirPanelDeIngreso,
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF528F8F),
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Escribiendo: \$$_numeroQueEstoyEscribiendo",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),

                  // Listado con interacción mejorada
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _listaDeMovimientos.length,
                      itemBuilder: (context, posicion) {
                        return GestureDetector(
                          // Detectamos la posición exacta del toque para mostrar el menú ahí
                          onLongPressStart: (detalles) {
                            _mostrarMenuOpciones(
                              context,
                              detalles.globalPosition,
                              posicion,
                            );
                          },
                          child: _dibujarBurbuja(_listaDeMovimientos[posicion]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 3. Barra de Categorías
            _construirBarraDeCategorias(),

            // 4. Teclado
            WidgetTecladoPropio(
              alTocarNumero: _logicaDelTeclado,
              alConfirmarTodo: _finalizarYRegistrarGasto,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirBarraDeCategorias() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _crearBotonDeIcono(Icons.restaurant, "Comida"),
          _crearBotonDeIcono(Icons.directions_car, "Transporte"),
          _crearBotonDeIcono(Icons.videogame_asset, "Ocio"),
          _crearBotonDeIcono(Icons.home, "Casa"),
        ],
      ),
    );
  }

  Widget _crearBotonDeIcono(IconData elIcono, String elNombre) {
    bool seleccionado = _nombreCategoriaElegida == elNombre;
    return GestureDetector(
      onTap: () => _seleccionarNuevaCategoria(elNombre, elIcono),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: seleccionado
                  ? const Color(0xFF528F8F)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              elIcono,
              color: seleccionado ? Colors.white : Colors.black45,
            ),
          ),
          Text(
            elNombre,
            style: TextStyle(
              fontSize: 10,
              fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dibujarBurbuja(Map<String, dynamic> datosDeBurbuja) {
    bool esGasto = datosDeBurbuja["esGasto"];
    return Align(
      alignment: esGasto ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: esGasto ? const Color(0xFFD2C1B0) : const Color(0xFFB2D7D7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!esGasto) Icon(datosDeBurbuja["icono"], size: 18),
            const SizedBox(width: 8),
            Text(
              datosDeBurbuja["texto"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            if (esGasto) Icon(datosDeBurbuja["icono"], size: 18),
          ],
        ),
      ),
    );
  }
}

// --- CLASE DEL TECLADO ---
class WidgetTecladoPropio extends StatelessWidget {
  final Function(String) alTocarNumero;
  final VoidCallback alConfirmarTodo;
  const WidgetTecladoPropio({
    super.key,
    required this.alTocarNumero,
    required this.alConfirmarTodo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          _crearFilaTeclado(['1', '2', '3']),
          _crearFilaTeclado(['4', '5', '6']),
          _crearFilaTeclado(['7', '8', '9']),
          _crearFilaTeclado(['', '0', '⌫']),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: ElevatedButton(
              onPressed: alConfirmarTodo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF528F8F),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "REGISTRAR GASTO AHORA",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearFilaTeclado(List<String> listaDeTeclas) {
    return Row(
      children: listaDeTeclas
          .map(
            (caracter) => Expanded(
              child: TextButton(
                onPressed: caracter.isEmpty
                    ? null
                    : () => alTocarNumero(caracter),
                child: Text(
                  caracter,
                  style: const TextStyle(fontSize: 24, color: Colors.black87),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
