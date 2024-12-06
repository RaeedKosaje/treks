import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLocked = false; // لتحديد ما إذا كانت الصفوف القديمة مثبتة
  List<Map<String, dynamic>> rowsData = []; // جميع الصفوف (قديمة وجديدة)

  // دالة لإضافة صف جديد
  void addNewRow() {
    setState(() {
      rowsData.add({
        'playerName': TextEditingController(), // اسم اللاعب
        'b': 0, // قيمة "بنات"
        'k': 0, // قيمة "اختيار"
        'd': 0, // قيمة "دينار"
        't': 0, // قيمة "تركست"
        'l': 0, // قيمة "لطوش"
        'm': 0, // المجموع
        'locked': false, // حالة القفل
      });
    });
  }

  // دالة لتثبيت الصفوف
  void lockRows() {
    setState(() {
      for (var row in rowsData) {
        row['locked'] = true; // قفل الصفوف
      }
    });
  }

  // دالة لحساب المجموع لكل صف
  void calculateRowTotal(Map<String, dynamic> rowData) {
    setState(() {
      rowData['m'] = (rowData['b'] + rowData['k'] + rowData['d'] + rowData['t'] + rowData['l']).toInt();
    });
  }

  // دالة لحساب المجموع الكلي لجميع الصفوف
  int calculateTotalSum() {
    int totalSum = 0;
    for (var row in rowsData) {
      totalSum += (row['m'] as int);
    }
    return totalSum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text("هون ما فيك تغش"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // عرض جميع الصفوف
                    if (rowsData.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rowsData.map((rowData) => buildRow(rowData)).toList(),
                      ),
                  ],
                ),
              ),
            ),
            // زر لتثبيت الصفوف وإضافة صفوف جديدة مع مربع عرض المجموع الكلي
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (rowsData.any((row) => row['locked'] == false)) {
                          // تثبيت الصفوف غير المثبتة
                          lockRows();
                        } else {
                          // إضافة صفوف جديدة
                          addNewRow();
                        }
                      },
                      child: Text(rowsData.any((row) => row['locked'] == false)
                          ? "تثبيت الصفوف"
                          : "إضافة صفوف جديدة"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // مربع عرض المجموع الكلي
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      "المجموع الكلي: ${calculateTotalSum()}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء الصف
  Widget buildRow(Map<String, dynamic> rowData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: rowData['playerName'], // اسم اللاعب
            decoration: const InputDecoration(
              labelText: "اسم اللاعب",
              border: OutlineInputBorder(),
              hintText: "أدخل اسم اللاعب",
            ),
            enabled: !rowData['locked'], // تعطيل الحقل إذا كان الصف مثبتًا
          ),
        ),
        buildInputRow("بنات", rowData['b'], (value) {
          if (value.isNotEmpty) {
            rowData['b'] = (int.parse(value) * -25).toInt();
            calculateRowTotal(rowData); // حساب المجموع
          }
        }, rowData['locked']),
        buildInputRow("اختيار", rowData['k'], (value) {
          if (value.isNotEmpty) {
            rowData['k'] = (int.parse(value) * -75).toInt();
            calculateRowTotal(rowData); // حساب المجموع
          }
        }, rowData['locked']),
        buildInputRow("دينار", rowData['d'], (value) {
          if (value.isNotEmpty) {
            rowData['d'] = (int.parse(value) * -10).toInt();
            calculateRowTotal(rowData); // حساب المجموع
          }
        }, rowData['locked']),
        buildInputRow("لطوش", rowData['l'], (value) {
          if (value.isNotEmpty) {
            rowData['l'] = (int.parse(value) * -15).toInt();
            calculateRowTotal(rowData); // حساب المجموع
          }
        }, rowData['locked']),
        buildInputRow("تركست", rowData['t'], (value) {
          if (value.isNotEmpty) {
            rowData['t'] = int.parse(value).toInt();
            calculateRowTotal(rowData); // حساب المجموع
          }
        }, rowData['locked'], maxDigits: 3),
        // المجموع
        Row(
          children: [
            const Text("المجموع:", style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              "${rowData['m']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  // دالة لإنشاء مربعات الإدخال المتشابهة
  Widget buildInputRow(
      String label, int result, Function(String) onChanged, bool isLocked,
      {int maxDigits = 2}) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.favorite),
              SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'بدون زوغلة سجل',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(maxDigits),
                    ],
                    onChanged: isLocked ? null : onChanged,
                    enabled: !isLocked,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "النتيجة: $result",
                      enabled: false,
                      disabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                      ),
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
