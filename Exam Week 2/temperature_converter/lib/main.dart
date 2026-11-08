import 'package:flutter/material.dart';

void main() => runApp(const TemperatureConverterApp());

enum ConversionType { celsiusToFahrenheit, fahrenheitToCelsius }

class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0796D2);

    return MaterialApp(
      title: 'Temperature Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF171717),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const ConverterPage(),
    );
  }
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _temperatureController = TextEditingController();
  ConversionType _conversionType = ConversionType.fahrenheitToCelsius;
  String? _inputError;
  double? _convertedTemperature;

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  String get _inputUnit => _conversionType == ConversionType.celsiusToFahrenheit
      ? '\u00B0C'
      : '\u00B0F';

  String get _resultUnit =>
      _conversionType == ConversionType.celsiusToFahrenheit
      ? '\u00B0F'
      : '\u00B0C';

  void _calculate() {
    final rawValue = _temperatureController.text.trim();
    final value = double.tryParse(rawValue);

    setState(() {
      if (rawValue.isEmpty) {
        _inputError = 'Please enter a temperature.';
        _convertedTemperature = null;
      } else if (value == null || !value.isFinite) {
        _inputError = 'Enter a valid number.';
        _convertedTemperature = null;
      } else {
        _inputError = null;
        _convertedTemperature = switch (_conversionType) {
          ConversionType.celsiusToFahrenheit => value * 9 / 5 + 32,
          ConversionType.fahrenheitToCelsius => (value - 32) * 5 / 9,
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0796D2);
    const muted = Color(0xFF8A8A8A);

    return Scaffold(
      appBar: AppBar(title: const Text('Temperature converter')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Degree',
                              style: TextStyle(color: muted, fontSize: 13),
                            ),
                            TextField(
                              controller: _temperatureController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              onChanged: (_) {
                                if (_inputError != null) {
                                  setState(() => _inputError = null);
                                }
                              },
                              onSubmitted: (_) => _calculate(),
                              decoration: InputDecoration(
                                hintText: '72',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFBBBBBB),
                                  fontSize: 14,
                                ),
                                suffixText: _inputUnit,
                                errorText: _inputError,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFE5E5E5),
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: blue,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Type',
                              style: TextStyle(color: muted, fontSize: 13),
                            ),
                            DropdownButtonFormField<ConversionType>(
                              initialValue: _conversionType,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFE5E5E5),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: blue,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: ConversionType.celsiusToFahrenheit,
                                  child: Text('Celsius'),
                                ),
                                DropdownMenuItem(
                                  value: ConversionType.fahrenheitToCelsius,
                                  child: Text('Fahrenheit'),
                                ),
                              ],
                              onChanged: (type) {
                                if (type == null) return;
                                setState(() {
                                  _conversionType = type;
                                  _convertedTemperature = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Result',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _convertedTemperature == null
                        ? '\u2014'
                        : '${_convertedTemperature!.toStringAsFixed(2)} $_resultUnit',
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _calculate,
                      style: FilledButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Convert'),
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
