import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Inicialización de la base de datos local
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Abrimos la "caja" para persistencia de datos
  await Hive.openBox('caja_finanzas');

  runApp(const MiAppFinanzas());
}

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

  // Guarda el filtro activo actual
  String _filtroSeleccionado = "Todos";

  final _miCaja = Hive.box('caja_finanzas');
  List<Map<String, dynamic>> _listaDeMovimientos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosDeLaMemoria();
  }

  // --- LÓGICA DE BASE DE DATOS ---

  void _cargarDatosDeLaMemoria() {
    final datosGuardados = _miCaja.get('historial', defaultValue: []);
    setState(() {
      _listaDeMovimientos = List<Map<String, dynamic>>.from(
        datosGuardados.map((item) => Map<String, dynamic>.from(item)),
      );
      _recalculateSaldo();
    });
  }

  void _recalculateSaldo() {
    double saldoTemporal = 0.0;
    for (var movimiento in _listaDeMovimientos) {
      double monto = movimiento['monto'];
      if (movimiento['esGasto']) {
        saldoTemporal -= monto;
      } else {
        saldoTemporal += monto;
      }
    }
    _dineroTotalEnCuenta = saldoTemporal;
  }

  void _guardarPermanentemente() {
    _miCaja.put('historial', _listaDeMovimientos);
    _recalculateSaldo();
    setState(() {});
  }

  // --- LÓGICA DE FILTRADO ---
  List<Map<String, dynamic>> _obtenerMovimientosFiltrados() {
    if (_filtroSeleccionado == "Todos") {
      return _listaDeMovimientos;
    } else if (_filtroSeleccionado == "Ingresos") {
      return _listaDeMovimientos.where((m) => m["esGasto"] == false).toList();
    } else if (_filtroSeleccionado == "Gastos") {
      return _listaDeMovimientos.where((m) => m["esGasto"] == true).toList();
    } else {
      return _listaDeMovimientos.where((m) {
        if (!m["esGasto"]) return false;

        int iconoCodigo = m["icono"];
        String categoriaDelMovimiento = "Otros";

        if (iconoCodigo == Icons.restaurant.codePoint)
          categoriaDelMovimiento = "Comida";
        if (iconoCodigo == Icons.directions_car.codePoint)
          categoriaDelMovimiento = "Transporte";
        if (iconoCodigo == Icons.home.codePoint)
          categoriaDelMovimiento = "Casa";
        if (iconoCodigo == Icons.videogame_asset.codePoint)
          categoriaDelMovimiento = "Ocio";

        return categoriaDelMovimiento == _filtroSeleccionado;
      }).toList();
    }
  }

  // --- LÓGICA DE INTERFAZ ---

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

  void _finalizarYRegistrarGasto() async {
    double cantidadAGastar = double.tryParse(_numeroQueEstoyEscribiendo) ?? 0;
    if (cantidadAGastar <= 0) return;

    String? detalleIngresado = await _pedirEspecificacion(
      "Detalle de $_nombreCategoriaElegida",
      "¿En qué gastaste exactamente?",
    );

    String especificacionFinal =
        (detalleIngresado == null || detalleIngresado.trim().isEmpty)
        ? _nombreCategoriaElegida
        : detalleIngresado;

    setState(() {
      _listaDeMovimientos.insert(0, {
        "texto": "$especificacionFinal \$$cantidadAGastar",
        "monto": cantidadAGastar,
        "icono": _iconoCategoriaElegida.codePoint,
        "esGasto": true,
      });
      _numeroQueEstoyEscribiendo = "0";
      _filtroSeleccionado = "Todos";
      _guardarPermanentemente();
    });
  }

  Future<String?> _pedirEspecificacion(String titulo, String sugerencia) {
    TextEditingController controlador = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: controlador,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: sugerencia),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ""),
            child: const Text("Omitir"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF528F8F),
            ),
            onPressed: () => Navigator.pop(context, controlador.text),
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _eliminarRegistro(int indiceEnListaFiltrada) {
    final movimientoAELiminar =
        _obtenerMovimientosFiltrados()[indiceEnListaFiltrada];
    setState(() {
      _listaDeMovimientos.remove(movimientoAELiminar);
      _guardarPermanentemente();
    });
  }

  void _editarRegistro(int indiceEnListaFiltrada) async {
    final listaFiltrada = _obtenerMovimientosFiltrados();
    final movimiento = listaFiltrada[indiceEnListaFiltrada];
    bool esGasto = movimiento["esGasto"];

    TextEditingController controladorTexto = TextEditingController(
      text: movimiento["texto"].toString().split(esGasto ? " \$" : ": +\$")[0],
    );
    TextEditingController controladorMonto = TextEditingController(
      text: movimiento["monto"].toString(),
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          esGasto ? "Editar Gasto 📝" : "Editar Ingreso 📝",
          style: const TextStyle(color: Color(0xFF425C5C)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controladorTexto,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: "Concepto / Descripción",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controladorMonto,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monto (\$)",
                prefixText: "\$ ",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF528F8F),
            ),
            onPressed: () {
              double nuevoMonto = double.tryParse(controladorMonto.text) ?? 0;
              String nuevoTexto = controladorTexto.text.trim();

              if (nuevoMonto > 0 && nuevoTexto.isNotEmpty) {
                setState(() {
                  int indiceReal = _listaDeMovimientos.indexOf(movimiento);

                  _listaDeMovimientos[indiceReal] = {
                    "texto": esGasto
                        ? "$nuevoTexto \$$nuevoMonto"
                        : "$nuevoTexto: +\$$nuevoMonto",
                    "monto": nuevoMonto,
                    "icono": movimiento["icono"],
                    "esGasto": esGasto,
                  };
                  _guardarPermanentemente();
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Actualizar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMenuOpciones(
    BuildContext contexto,
    Offset posicionGlobal,
    int indiceFiltrado,
  ) async {
    final resultado = await showMenu(
      context: contexto,
      // Corregido aquí: se usa posicionGlobal completo sin abreviaciones erróneas
      position: RelativeRect.fromLTRB(
        posicionGlobal.dx,
        posicionGlobal.dy,
        posicionGlobal.dx + 1,
        posicionGlobal.dy + 1,
      ),
      items: [
        const PopupMenuItem(
          value: 'editar',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 10),
              Text("Editar"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'eliminar',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 10),
              Text("Eliminar"),
            ],
          ),
        ),
      ],
    );

    if (resultado == 'eliminar') {
      _eliminarRegistro(indiceFiltrado);
    } else if (resultado == 'editar') {
      _editarRegistro(indiceFiltrado);
    }
  }

  void _abrirPanelDeIngreso() {
    TextEditingController controladorMonto = TextEditingController();
    TextEditingController controladorNota = TextEditingController();

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
              controller: controladorMonto,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "¿Cuánto dinero entró?",
                prefixText: "\$ ",
              ),
            ),
            TextField(
              controller: controladorNota,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: "Concepto (Ej: Sueldo, Beca...)",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF528F8F),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                double monto = double.tryParse(controladorMonto.text) ?? 0;
                String nota = controladorNota.text.isEmpty
                    ? "Ingreso"
                    : controladorNota.text;
                if (monto > 0) {
                  setState(() {
                    _listaDeMovimientos.insert(0, {
                      "texto": "$nota: +\$$monto",
                      "monto": monto,
                      "icono": Icons.add_card.codePoint,
                      "esGasto": false,
                    });
                    _filtroSeleccionado = "Todos";
                    _guardarPermanentemente();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Sumar al Saldo",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _construirBarraDeFiltros() {
    List<String> opcionesFiltros = [
      "Todos",
      "Ingresos",
      "Gastos",
      "Comida",
      "Transporte",
      "Casa",
      "Ocio",
      "Otros",
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: opcionesFiltros.length,
        itemBuilder: (context, index) {
          String filtro = opcionesFiltros[index];
          bool activo = _filtroSeleccionado == filtro;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filtro,
                style: TextStyle(
                  color: activo ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: activo,
              selectedColor: const Color(0xFF425C5C),
              backgroundColor: Colors.grey.shade200,
              onSelected: (bool seleccionado) {
                setState(() {
                  _filtroSeleccionado = filtro;
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movimientosFiltrados = _obtenerMovimientosFiltrados();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  const Text(
                    "Saldo disponible:",
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
                    "Tecleando: \$$_numeroQueEstoyEscribiendo",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  _construirBarraDeFiltros(),
                  const Divider(),

                  Expanded(
                    child: movimientosFiltrados.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay movimientos en este filtro",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: movimientosFiltrados.length,
                            itemBuilder: (context, posicion) {
                              return GestureDetector(
                                onLongPressStart: (detalles) =>
                                    _mostrarMenuOpciones(
                                      context,
                                      detalles.globalPosition,
                                      posicion,
                                    ),
                                child: _dibujarBurbuja(
                                  movimientosFiltrados[posicion],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            _construirBarraDeCategorias(),
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
          _crearBotonDeIcono(Icons.home, "Casa"),
          _crearBotonDeIcono(Icons.videogame_asset, "Ocio"),
          _crearBotonDeIcono(Icons.more_horiz, "Otros"),
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
            if (!esGasto)
              Icon(
                IconData(datosDeBurbuja["icono"], fontFamily: 'MaterialIcons'),
                size: 18,
              ),
            const SizedBox(width: 8),
            Text(
              datosDeBurbuja["texto"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            if (esGasto)
              Icon(
                IconData(datosDeBurbuja["icono"], fontFamily: 'MaterialIcons'),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

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
    return Column(
      children: [
        _crearFilaTeclado(['1', '2', '3']),
        _crearFilaTeclado(['4', '5', '6']),
        _crearFilaTeclado(['7', '8', '9']),
        _crearFilaTeclado(['', '0', '⌫']),
        Padding(
          padding: const EdgeInsets.all(10),
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
