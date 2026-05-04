import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/logic/bloC/app_theme_bloc/app_theme_cubit.dart';
import '../../data/models/day.dart';


class ChartScreen extends StatefulWidget {
  final List<Day> days;
  const ChartScreen({super.key, required this.days});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late List<Day> _filteredDays;
  final TextEditingController fDate = TextEditingController();
  final TextEditingController lDate = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredDays = List.from(widget.days);
    if (widget.days.isNotEmpty) {
      fDate.text = widget.days.last.date ?? '';
      lDate.text = widget.days.first.date ?? '';
    }
  }

  (Map<String, double>, List<Color>) _getChartData() {
    if (_filteredDays.isEmpty) return ({'No Data': 1.0}, [Colors.white24]);
    Map<String, double> dataMap = {};
    List<Color> colors = [];
    for (var day in _filteredDays) {
      final mood = day.mood!;
      dataMap[mood.title] = (dataMap[mood.title] ?? 0) + 1;
      if (!colors.any((c) => c.toARGB32() == mood.color.toARGB32())) {
        colors.add(mood.color);
      }
    }
    return (dataMap, colors);
  }

  void _updateFilter() {
    setState(() {
      final start = DateTime.tryParse(fDate.text);
      final end = DateTime.tryParse(lDate.text);
      if (start != null && end != null) {
        _filteredDays = widget.days.where((day) {
          final d = DateTime.tryParse(day.date ?? '');
          return d != null &&
              (d.isAfter(start) || d.isAtSameMomentAs(start)) &&
              (d.isBefore(end) || d.isAtSameMomentAs(end));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppThemeCubit>();
    final chartData = _getChartData();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Mood Analytics",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            child: Image.asset(theme.wallpaper, fit: BoxFit.cover),
          ),
          // Dark overlay for better readability
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha:.4)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  _buildGlassDateFilter(context),
                  const SizedBox(height: 10),
                  // Responsive Solid Chart
                  Center(
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: ModernMoodChart(
                        data: chartData.$1,
                        colors: chartData.$2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPolishedLegend(chartData.$1, chartData.$2),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolishedLegend(Map<String, double> data, List<Color> colors) {
    final totalDays = data.values.fold(0.0, (p, c) => p + c);
    List<String> keys = data.keys.toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha:.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Breakdown",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Icon(
                    Icons.insights_rounded,
                    color: Colors.white.withValues(alpha:.5),
                    size: 20,
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 32),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: keys.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final key = keys[index];
                  final count = data[key]!;
                  final percentage = (count / totalDays * 100).toStringAsFixed(
                    1,
                  );
                  final color = colors[index % colors.length];

                  return Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha:.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${count.toInt()} Days",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$percentage%",
                            style: TextStyle(
                              color: color.withValues(alpha:.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassDateFilter(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha:.12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _dateField(fDate, "START DATE"),
              Container(width: 1, height: 20, color: Colors.white12),
              _dateField(lDate, "END DATE"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(TextEditingController cont, String label) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: Colors.blueAccent),
            ),
            child: child!,
          ),
        );
        if (d != null) {
          cont.text =
              "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
          _updateFilter();
        }
      },
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cont.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ModernMoodChart extends StatelessWidget {
  final Map<String, double> data;
  final List<Color> colors;

  const ModernMoodChart({super.key, required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.fastOutSlowIn,
      builder: (context, value, child) {
        return CustomPaint(
          painter: MoodRingPainter(
            data: data,
            colors: colors,
            animationValue: value,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${data.values.fold(0.0, (p, c) => p + c).toInt()}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  "TOTAL DAYS",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MoodRingPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;
  final double animationValue;

  MoodRingPainter({
    required this.data,
    required this.colors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final total = data.values.fold(0.0, (p, c) => p + c);
    double startAngle = -pi / 2; // البداية من فوق (الساعة 12)
    const double strokeWidth = 28.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt; // التغيير هنا: نهايات حادة مش دائرية

    // رسم مسار خلفي خفيف جداً عشان يحدد شكل الدائرة
    canvas.drawCircle(
      center,
      radius - (strokeWidth / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = Colors.white.withValues(alpha:.03),
    );

    int i = 0;
    data.forEach((key, value) {
      final sweepAngle = (value / total) * 2 * pi * animationValue;
      final color = colors[i % colors.length].withValues(alpha:.7);

      paint.color = color;

      // رسم الشريحة (Arc)
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      final separatorPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 1
        ..color = Colors.black
            .withValues(alpha:.2) 
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        startAngle,
        0.02, // خط رفيع جداً للفصل
        false,
        separatorPaint,
      );

      startAngle += (value / total) * 2 * pi;
      i++;
    });
  }

  @override
  bool shouldRepaint(covariant MoodRingPainter oldDelegate) => true;
}
