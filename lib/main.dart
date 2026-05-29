import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ejemplos de Dart',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4965)),
      ),
      home: const EjemplosDartPage(),
    );
  }
}

class EjemplosDartPage extends StatelessWidget {
  const EjemplosDartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4965),
        foregroundColor: Colors.white,
        title: const Text('Estructuras básicas de Dart'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Ejemplo práctico con variables, constantes, tipos de datos, condicionales, bucles y funciones.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          ExampleCard(
            title: 'Variables',
            code: "var nombre = 'Ana';\nint edad = 20;\ndouble altura = 1.68;\nbool esEstudiante = true;",
            result: 'Nombre: Ana, edad: 20, altura: 1.68, estudiante: true',
          ),
          ExampleCard(
            title: 'Constantes',
            code: "const String pais = 'Perú';\nfinal DateTime fechaActual = DateTime.now();",
            result: 'País: Perú. Fecha actual: se calcula al iniciar la app.',
          ),
          ExampleCard(
            title: 'Tipos de datos',
            code: "int, double, String, bool, List y Map",
            result: 'int: 10, double: 3.14, String: Hola Dart, bool: false',
          ),
          ExampleCard(
            title: 'Estructura condicional',
            code: "if (edad >= 18) {\n  print('Es mayor de edad');\n} else {\n  print('Es menor de edad');\n}",
            result: 'Como la edad es 20, el ejemplo muestra: es mayor de edad.',
          ),
          ExampleCard(
            title: 'Estructura repetitiva',
            code: "for (var i = 1; i <= 3; i++) {\n  print(i);\n}\n\nwhile (contador < 3) {\n  print(contador);\n  contador++;\n}",
            result: 'for: [1, 2, 3] | while: [0, 1, 2]',
          ),
          ExampleCard(
            title: 'Funciones',
            code: "String saludar(String nombre) {\n  return 'Hola, \$nombre';\n}",
            result: 'Hola, Luis',
          ),
        ],
      ),
    );
  }
}

class ExampleCard extends StatelessWidget {
  const ExampleCard({
    super.key,
    required this.title,
    required this.code,
    required this.result,
  });

  final String title;
  final String code;
  final String result;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD7E3F4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B4965),
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Código:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                code,
                style: const TextStyle(fontFamily: 'monospace', height: 1.4),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Resultado:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(result),
          ],
        ),
      ),
    );
  }
}
