import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/fan_diary.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../../widgets/common_widgets.dart';

class DiaryFormScreen extends StatefulWidget {
  const DiaryFormScreen({super.key, this.entry});

  final FanDiary? entry;

  @override
  State<DiaryFormScreen> createState() => _DiaryFormScreenState();
}

class _DiaryFormScreenState extends State<DiaryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _body;
  String _mood = 'Joy';
  String _bias = 'Ren';
  bool _isConcert = false;
  bool _saving = false;

  static const _moods = ['Joy', 'Nostalgia', 'Excited', 'Grateful'];
  static const _members = ['Ren', 'Kai', 'Leo', 'Jun'];

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _title = TextEditingController(text: e?.title ?? '');
    _body = TextEditingController(text: e?.body ?? '');
    _mood = e?.mood ?? 'Joy';
    _bias = e?.biasMember ?? 'Ren';
    _isConcert = e?.isConcertMemory ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final entry = FanDiary(
      id: widget.entry?.id,
      title: _title.text.trim(),
      body: _body.text.trim(),
      mood: _mood,
      biasMember: _bias,
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
      isConcertMemory: _isConcert,
    );
    final db = DatabaseHelper.instance;
    if (widget.entry == null) {
      await db.insertDiary(entry);
    } else {
      await db.updateDiary(entry);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entry != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackdrop(),
          Column(
            children: [
              GlassAppBar(
                title: Text(isEdit ? 'Edit memory' : 'New memory'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  TextButton(
                    onPressed: _saving ? null : _save,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: CortifyColors.coral,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      GlassPanel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _title,
                              decoration:
                                  const InputDecoration(labelText: 'Title'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Add a title'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _body,
                              maxLines: 6,
                              decoration: const InputDecoration(
                                labelText: 'Your memory',
                                alignLabelWithHint: true,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Write something'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Mood',
                        style: TextStyle(
                          color: CortifyColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        children: _moods
                            .map(
                              (m) => SoftChip(
                                label: m,
                                selected: _mood == m,
                                onTap: () => setState(() => _mood = m),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'About member',
                        style: TextStyle(
                          color: CortifyColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        children: _members
                            .map(
                              (m) => SoftChip(
                                label: m,
                                selected: _bias == m,
                                onTap: () => setState(() => _bias = m),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      GlassPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Concert memory'),
                          subtitle: const Text('Mark special live moments'),
                          value: _isConcert,
                          activeThumbColor: CortifyColors.coral,
                          onChanged: (v) => setState(() => _isConcert = v),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? 'Saving…' : 'Save memory'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
