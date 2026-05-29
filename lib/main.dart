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
      title: 'Nova Calc',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF22D3EE)),
        scaffoldBackgroundColor: const Color(0xFF040816),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '0';
  String _result = '0';
  bool _isNewInput = true;

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '0';
        _result = '0';
        _isNewInput = true;
        return;
      }

      if (value == 'DEL') {
        if (_expression.length <= 1) {
          _expression = '0';
          _isNewInput = true;
          return;
        }

        _expression = _expression.substring(0, _expression.length - 1);
        if (_expression.isEmpty) {
          _expression = '0';
          _isNewInput = true;
          return;
        }

        if (_isOperatorChar(_expression[_expression.length - 1])) {
          _isNewInput = true;
        }
        return;
      }

      if (value == '=') {
        final expressionToEvaluate = _trimTrailingOperator(_expression);
        _result = _formatNumber(_evaluateExpression(expressionToEvaluate));
        _expression = _result;
        _isNewInput = true;
        return;
      }

      if (_isOperatorChar(value)) {
        if (_expression == '0' && value == '-') {
          _expression = '-';
          _isNewInput = false;
          return;
        }

        if (_expression.isNotEmpty && _isOperatorChar(_expression[_expression.length - 1])) {
          _expression = _expression.substring(0, _expression.length - 1) + value;
        } else {
          _expression += value;
        }

        _isNewInput = true;
        return;
      }

      if (value == '.') {
        final currentToken = _currentNumberToken(_expression);
        if (currentToken.contains('.')) {
          return;
        }

        if (_isNewInput || _expression == '0') {
          _expression = '0.';
          _isNewInput = false;
          return;
        }

        if (_expression.isNotEmpty && _isOperatorChar(_expression[_expression.length - 1])) {
          _expression += '0.';
          _isNewInput = false;
          return;
        }
      }

      if (_isNewInput || _expression == '0') {
        _expression = value;
      } else {
        _expression += value;
      }
      _isNewInput = false;
    });
  }

  bool _isOperatorChar(String value) => value.length == 1 && const ['+', '-', '×', '÷'].contains(value);

  String _currentNumberToken(String expression) {
    var index = expression.length - 1;
    while (index >= 0 && !_isOperatorChar(expression[index])) {
      index--;
    }
    return expression.substring(index + 1);
  }

  String _trimTrailingOperator(String expression) {
    if (expression.isNotEmpty && _isOperatorChar(expression[expression.length - 1])) {
      return expression.substring(0, expression.length - 1);
    }
    return expression;
  }

  double _evaluateExpression(String expression) {
    if (expression.isEmpty || expression == '-') {
      return 0;
    }

    final sanitized = expression.replaceAll('×', '*').replaceAll('÷', '/');
    final tokens = _tokenize(sanitized);
    final postfix = _toPostfix(tokens);
    return _evaluatePostfix(postfix);
  }

  List<String> _tokenize(String expression) {
    final tokens = <String>[];
    final buffer = StringBuffer();

    for (var index = 0; index < expression.length; index++) {
      final char = expression[index];

      if ('0123456789.'.contains(char)) {
        buffer.write(char);
        continue;
      }

      if (char == '-' && (index == 0 || '+-*/'.contains(expression[index - 1]))) {
        buffer.write(char);
        continue;
      }

      if (buffer.isNotEmpty) {
        tokens.add(buffer.toString());
        buffer.clear();
      }

      if ('+-*/'.contains(char)) {
        tokens.add(char);
      }
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }

    return tokens;
  }

  List<String> _toPostfix(List<String> tokens) {
    final output = <String>[];
    final operators = <String>[];

    int precedence(String operator) {
      switch (operator) {
        case '*':
        case '/':
          return 2;
        case '+':
        case '-':
          return 1;
        default:
          return 0;
      }
    }

    for (final token in tokens) {
      if (double.tryParse(token) != null) {
        output.add(token);
        continue;
      }

      while (operators.isNotEmpty && precedence(operators.last) >= precedence(token)) {
        output.add(operators.removeLast());
      }
      operators.add(token);
    }

    while (operators.isNotEmpty) {
      output.add(operators.removeLast());
    }

    return output;
  }

  double _evaluatePostfix(List<String> postfix) {
    final stack = <double>[];

    for (final token in postfix) {
      final number = double.tryParse(token);
      if (number != null) {
        stack.add(number);
        continue;
      }

      if (stack.length < 2) {
        return 0;
      }

      final right = stack.removeLast();
      final left = stack.removeLast();

      switch (token) {
        case '+':
          stack.add(left + right);
          break;
        case '-':
          stack.add(left - right);
          break;
        case '*':
          stack.add(left * right);
          break;
        case '/':
          stack.add(right == 0 ? 0 : left / right);
          break;
      }
    }

    return stack.isEmpty ? 0 : stack.last;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(6).replaceFirst(RegExp(r'\.0+$|0+$'), '');
  }

  Widget _buildButton(
    String label, {
    Color? background,
    Color? foreground,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: SizedBox(
          height: 74,
          child: ElevatedButton(
            onPressed: () => _onButtonPressed(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: background ?? const Color(0xFF111A34),
              foregroundColor: foreground ?? Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              elevation: 0,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: label == '=' ? 28 : 23,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF081224), Color(0xFF050816), Color(0xFF02040B)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -55,
                right: -45,
                child: _GlowBlob(color: const Color(0xFF22D3EE).withOpacity(0.18), size: 180),
              ),
              Positioned(
                top: 110,
                left: -60,
                child: _GlowBlob(color: const Color(0xFFF97316).withOpacity(0.18), size: 150),
              ),
              Column(
                children: [
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1730),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.35)),
                          ),
                          child: const Icon(Icons.flash_on_outlined, color: Color(0xFF67E8F9)),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nova Calc',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Neon edition',
                                style: TextStyle(
                                  color: Color(0xFF93A4C3),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1428).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _expression,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Color(0xFF8AA0C8),
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [Color(0xFF67E8F9), Color(0xFFF97316)],
                              ).createShader(bounds);
                            },
                            child: Text(
                              _result,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 58,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1122).withOpacity(0.98),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildButton('C', background: const Color(0xFF231126), foreground: const Color(0xFFF472B6)),
                                _buildButton('DEL', background: const Color(0xFF1B243D), foreground: const Color(0xFFFBBF24)),
                                _buildButton('÷', background: const Color(0xFF0D2833), foreground: const Color(0xFF67E8F9)),
                                _buildButton('×', background: const Color(0xFF0D2833), foreground: const Color(0xFF67E8F9)),
                              ],
                            ),
                            Row(
                              children: [
                                _buildButton('7'),
                                _buildButton('8'),
                                _buildButton('9'),
                                _buildButton('-', background: const Color(0xFF0D2833), foreground: const Color(0xFF67E8F9)),
                              ],
                            ),
                            Row(
                              children: [
                                _buildButton('4'),
                                _buildButton('5'),
                                _buildButton('6'),
                                _buildButton('+', background: const Color(0xFF0D2833), foreground: const Color(0xFF67E8F9)),
                              ],
                            ),
                            Row(
                              children: [
                                _buildButton('1'),
                                _buildButton('2'),
                                _buildButton('3'),
                                _buildButton('=', background: const Color(0xFFF97316), foreground: Colors.white),
                              ],
                            ),
                            Row(
                              children: [
                                _buildButton('0', flex: 2),
                                _buildButton('.'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 40,
            spreadRadius: 12,
          ),
        ],
      ),
    );
  }
}