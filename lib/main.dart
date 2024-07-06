import 'package:flutter/material.dart';
import 'dart:collection';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String output = "|";
  String expression = "";
  String removeIcon = 'icons/remove_icon.png';
  String switchIcon = 'icons/switch_icon.png';
  bool isOperator(String c) {
    return (c == '+' ||
        c == '-' ||
        c == '×' ||
        c == '÷' ||
        c == '%' ||
        c == 'C');
  }

  bool isResultOperator(String c) {
    return c == '=';
  }

  bool isIcon(String c) {
    return c.length > 1;
  }

  int precedence(String c) {
    if (c == '+' || c == '-') {
      return 1;
    } else if (c == '×' || c == '÷') {
      return 2;
    }
    return 0;
  }

  List<String> infixToPostfix(String exp) {
    List<String> result = [];
    Queue<String> stack = Queue();
    for (int i = 0; i < exp.length; i++) {
      String c = exp[i];

      if (double.tryParse(c) != null || c == '.') {
        String num = "";
        while (i < exp.length &&
            (double.tryParse(exp[i]) != null || exp[i] == '.')) {
          num += exp[i];
          i++;
        }
        i--;
        result.add(num);
      } else if (c == '(') {
        stack.addFirst(c);
      } else if (c == ')') {
        while (stack.isNotEmpty && stack.first != '(') {
          result.add(stack.removeFirst());
        }
        stack.removeFirst();
      } else if (isOperator(c)) {
        while (stack.isNotEmpty && precedence(stack.first) >= precedence(c)) {
          result.add(stack.removeFirst());
        }
        stack.addFirst(c);
      }
    }

    while (stack.isNotEmpty) {
      result.add(stack.removeFirst());
    }

    return result;
  }

  double evaluatePostfix(List<String> exp) {
    Queue<double> stack = Queue();

    for (int i = 0; i < exp.length; i++) {
      String c = exp[i];

      if (double.tryParse(c) != null) {
        stack.addFirst(double.parse(c));
      } else {
        double val1 = stack.removeFirst();
        double val2 = stack.removeFirst();

        switch (c) {
          case '+':
            stack.addFirst(val2 + val1);
            break;
          case '-':
            stack.addFirst(val2 - val1);
            break;
          case '×':
            stack.addFirst(val2 * val1);
            break;
          case '÷':
            stack.addFirst(val2 / val1);
            break;
        }
      }
    }
    return stack.first;
  }

  buttonPressed(String buttonText) {
    if (isIcon(buttonText)) {
      setState(() {
        expression = expression.substring(0, expression.length - 1);
        output = expression;
      });
    } else if (buttonText == "C") {
      setState(() {
        output = "|";
        expression = "";
      });
    } else if (buttonText == "=") {
      List<String> postfix = infixToPostfix(expression);
      double result = evaluatePostfix(postfix);
      setState(() {
        output = result.toString();
      });
    } else {
      setState(() {
        expression += buttonText;
        output = expression;
      });
    }
  }

  Widget buildButton(String buttonText) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        color: Colors.white,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor:
              isResultOperator(buttonText) ? Colors.blue : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.0),
          ),
        ),
        child: isIcon(buttonText)
            ? Image.asset(
                buttonText,
                color: Colors.blue,
                width: 30,
              )
            : Text(
                buttonText,
                style: TextStyle(
                    fontSize: isOperator(buttonText) ? 35 : 30,
                    color: isResultOperator(buttonText)
                        ? Colors.white
                        : isOperator(buttonText)
                            ? Colors.blue
                            : Colors.black,
                    fontWeight: FontWeight.w300),
              ),
        onPressed: () => buttonPressed(buttonText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      'C',
      '%',
      removeIcon,
      '+',
      '7',
      '8',
      '9',
      '-',
      '4',
      '5',
      '6',
      '×',
      '1',
      '2',
      '3',
      '÷',
      switchIcon,
      '0',
      '.',
      '=',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("RAD"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 6.0,
            ),
            child: Text(
              output,
              style: const TextStyle(fontSize: 60.0, color: Colors.blue),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.2,
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                return buildButton(buttons[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
