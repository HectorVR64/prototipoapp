import 'package:flutter/material.dart';

void main() => runApp(const MiAppFinanzas());

class MiAppFinanzas extends StatelessWidget {
  const MiAppFinanzas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'sans-serif'),
      home: const PantallaPrototipo(),
    );
  }
}

class PantallaPrototipo extends StatelessWidget {
  const PantallaPrototipo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Encabezado: Perfil y Título "Mis Gastos"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(
                color: Color.fromARGB(
                  255,
                  82,
                  93,
                  143,
                ), // Color verde azulado del diseño
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color.fromARGB(60, 255, 255, 255),
                    child: Icon(Icons.person, color: Colors.white, size: 35),
                  ),
                  const Expanded(
                    child: Text(
                      "Mis Gastos",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50), // Espacio para centrar el texto
                ],
              ),
            ),

            // 2. Área Central: Monto Grande y Burbujas de Historial
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "0ºº", // Cantidad que se ingresa con el teclado
                      style: TextStyle(
                        fontSize: 60,
                        color: Color(0xFF425C5C),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Registro visual tipo chat
                    _crearBurbujaChat(
                      "Gasolina 5 ⛽",
                      const Color.fromARGB(255, 178, 198, 215),
                      Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
            ),

            // 3. Botones de Categorías (Casa, Coche, Comida, Ocio)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _botonCategoria(Icons.restaurant, const Color(0xFFD1E8E8)),
                  _botonCategoria(
                    Icons.directions_car,
                    const Color(0xFF528F8F),
                    seleccionado: true,
                  ),
                  _botonCategoria(
                    Icons.videogame_asset,
                    const Color(0xFFD2C1B0),
                  ),
                  _botonCategoria(Icons.home, const Color(0xFFB2D7D7)),
                ],
              ),
            ),

            // 4. Teclado Numérico Personalizado
            const TecladoNumerico(),
          ],
        ),
      ),
    );
  }

  // Función para generar las burbujas de texto del historial
  Widget _crearBurbujaChat(
    String contenido,
    Color colorFondo,
    Alignment alineacion,
  ) {
    return Align(
      alignment: alineacion,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          contenido,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // Función para los iconos de categorías (comida, coche, etc.)
  Widget _botonCategoria(
    IconData icono,
    Color colorFondo, {
    bool seleccionado = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorFondo,
        shape: BoxShape.circle,
        boxShadow: seleccionado
            ? [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Icon(
        icono,
        size: 30,
        color: seleccionado ? Colors.white : Colors.black54,
      ),
    );
  }
}

// Clase separada para el teclado inferior
class TecladoNumerico extends StatelessWidget {
  const TecladoNumerico({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: [
          _crearFilaBotones(['1', '2', '3']),
          _crearFilaBotones(['4', '5', '6']),
          _crearFilaBotones(['7', '8', '9']),
          _crearFilaBotones(['', '0', '⌫']),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF528F8F),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "OK",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _crearFilaBotones(List<String> etiquetas) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: etiquetas.map((texto) => _botonDelTeclado(texto)).toList(),
    );
  }

  Widget _botonDelTeclado(String texto) {
    return Expanded(
      child: TextButton(
        onPressed: () {},
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 28,
            color: Colors.black87,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
