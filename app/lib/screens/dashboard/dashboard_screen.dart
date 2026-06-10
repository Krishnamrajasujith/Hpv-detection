import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_button.dart';
import '../../widgets/risk_badge.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _State();
}

class _State extends ConsumerState<DashboardScreen> {
  bool _trained = false;
  bool _training = false;
  bool _predicting = false;
  Map<String, dynamic>? _result;

  PlatformFile? _trainFile;
  PlatformFile? _predictFile;

  final _patientName = TextEditingController();
  final _age = TextEditingController();
  final _sampleId = TextEditingController();
  final _testDate = TextEditingController();
  final _notes = TextEditingController();
  final _nextVisitDate = TextEditingController();
  final _dailyFoodIntake = TextEditingController();
  String _gender = 'Female';

  @override
  void initState() {
    super.initState();
    _checkModel();
  }

  Future<void> _checkModel() async {
    try {
      final res = await ApiService().dio.get('/predictions/model-status');
      setState(() => _trained = res.data['trained'] == true);
    } catch (_) {}
  }

  Future<void> _pickFile(bool forTrain) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null) setState(() => forTrain ? _trainFile = result.files.first : _predictFile = result.files.first);
  }

  Future<void> _train() async {
    if (_trainFile == null) { _snack('Select a CSV file'); return; }
    setState(() => _training = true);
    try {
      final form = FormData.fromMap({'file': MultipartFile.fromBytes(_trainFile!.bytes!, filename: _trainFile!.name)});
      final res = await ApiService().dio.post('/predictions/train', data: form);
      _snack('Model trained! Accuracy: ${res.data['accuracy']}%');
      setState(() => _trained = true);
    } catch (e) {
      _snack('Training failed');
    } finally {
      setState(() => _training = false);
    }
  }

  Future<void> _predict() async {
    if (_predictFile == null) { _snack('Select a CSV file'); return; }
    setState(() { _predicting = true; _result = null; });
    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(_predictFile!.bytes!, filename: _predictFile!.name),
        'patient_name': _patientName.text,
        'age': _age.text,
        'gender': _gender,
        'sample_id': _sampleId.text,
        'test_date': _testDate.text,
        'notes': _notes.text,
        'next_visit_date': _nextVisitDate.text,
        'daily_food_intake': _dailyFoodIntake.text,
      });
      final res = await ApiService().dio.post('/predictions/predict', data: form);
      setState(() => _result = res.data);
    } catch (_) {
      _snack('Prediction failed');
    } finally {
      setState(() => _predicting = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (_trained ? const Color(0xFF0ee7b0) : const Color(0xFFffb340)).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _trained ? '● Model Ready' : '○ Model Not Trained',
                style: TextStyle(
                  color: _trained ? const Color(0xFF0ee7b0) : const Color(0xFFffb340),
                  fontSize: 12, fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Train card
            _card('Train Model', [
              const Text('Upload a labelled CSV with HPV_Status and gene columns.', style: TextStyle(color: Color(0xFF5a7a9a), fontSize: 13)),
              const SizedBox(height: 12),
              _filePicker(_trainFile?.name, () => _pickFile(true), 'training CSV'),
              const SizedBox(height: 12),
              AppButton(label: 'Train Model', onPressed: _train, loading: _training, variant: AppButtonVariant.teal),
            ]),
            const SizedBox(height: 16),

            // Predict card
            _card('New Prediction', [
              _field('Patient Name', _patientName),
              _field('Age', _age, type: TextInputType.number),
              _field('Sample ID', _sampleId),
              _field('Test Date', _testDate, hint: 'YYYY-MM-DD'),
              _dropdownGender(),
              _field('Clinical Notes (optional)', _notes, maxLines: 2),
              _field('Next Visit Date', _nextVisitDate, hint: 'YYYY-MM-DD'),
              _field('Daily Food Intake', _dailyFoodIntake, maxLines: 3, hint: 'e.g. Rice, Fruits, Milk (one per line)'),
              const SizedBox(height: 4),
              _filePicker(_predictFile?.name, () => _pickFile(false), 'gene expression CSV'),
              const SizedBox(height: 12),
              AppButton(
                label: _trained ? 'Run Prediction' : 'Train model first',
                onPressed: _trained ? _predict : null,
                loading: _predicting,
              ),
            ]),

            // Result
            if (_result != null) ...[
              const SizedBox(height: 16),
              _card('Result', [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [const Text('Prediction', style: TextStyle(color: Color(0xFF5a7a9a), fontSize: 12)), const SizedBox(height: 4), ResultBadge(label: _result!['result'])]),
                    Column(children: [const Text('Confidence', style: TextStyle(color: Color(0xFF5a7a9a), fontSize: 12)), const SizedBox(height: 4), Text('${(_result!['confidence'] as num).toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF3d7fff), fontWeight: FontWeight.bold, fontSize: 20))]),
                    Column(children: [const Text('Risk', style: TextStyle(color: Color(0xFF5a7a9a), fontSize: 12)), const SizedBox(height: 4), RiskBadge(label: _result!['risk'])]),
                  ],
                ),
                const SizedBox(height: 16),
                if (_result!['heatmap_url'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(_result!['heatmap_url'], errorBuilder: (_, __, ___) => const SizedBox()),
                  ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF0d1a2e), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1e3a5f))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Color(0xFFb0c4de), fontWeight: FontWeight.w600, fontSize: 16)),
      const SizedBox(height: 12),
      ...children,
    ]),
  );

  Widget _field(String label, TextEditingController ctrl, {TextInputType? type, int maxLines = 1, String? hint}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
    ),
  );

  Widget _dropdownGender() => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: DropdownButtonFormField<String>(
      value: _gender,
      dropdownColor: const Color(0xFF0d1a2e),
      decoration: const InputDecoration(labelText: 'Gender'),
      items: ['Female', 'Male', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (v) => setState(() => _gender = v!),
    ),
  );

  Widget _filePicker(String? name, VoidCallback onTap, String label) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: name != null ? const Color(0xFF0ee7b0) : const Color(0xFF1e3a5f), style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF070d1a),
      ),
      child: Row(children: [
        Icon(name != null ? Icons.check_circle_outline : Icons.upload_file, color: name != null ? const Color(0xFF0ee7b0) : const Color(0xFF5a7a9a)),
        const SizedBox(width: 10),
        Expanded(child: Text(name ?? 'Upload $label', style: TextStyle(color: name != null ? const Color(0xFF0ee7b0) : const Color(0xFF5a7a9a), fontSize: 13))),
      ]),
    ),
  );
}
