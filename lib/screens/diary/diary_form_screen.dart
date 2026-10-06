import 'package:flutter/cupertino.dart';
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
                title: Text(isEdit ? 'Edit Memory' : 'New Memory'),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                actions: [
                  CupertinoButton(
                    padding: const EdgeInsets.only(right: 8),
                    onPressed: _saving ? null : _save,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _saving
                            ? CortifyColors.tertiary
                            : CortifyColors.coral,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      GlassPanel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _title,
                              style: const TextStyle(
                                fontFamily: '.SF Pro Text',
                                fontSize: 17,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Title',
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Add a title'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _body,
                              maxLines: 6,
                              style: const TextStyle(
                                fontFamily: '.SF Pro Text',
                                fontSize: 17,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Your memory',
                                alignLabelWithHint: true,
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Write something'
                                      : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 8),
                        child: Text(
                          'MOOD',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 13,
                            color: CortifyColors.muted,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Wrap(
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
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 8),
                        child: Text(
                          'ABOUT MEMBER',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 13,
                            color: CortifyColors.muted,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Wrap(
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
                      ),
                      const SizedBox(height: 16),
                      GlassPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: CupertinoListTile(
                          title: const Text('Concert memory'),
                          subtitle: const Text('Mark special live moments'),
                          trailing: CupertinoSwitch(
                            value: _isConcert,
                            activeTrackColor: CortifyColors.coral,
                            onChanged: (v) => setState(() => _isConcert = v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CupertinoButton.filled(
                        onPressed: _saving ? null : _save,
                        borderRadius: BorderRadius.circular(14),
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
