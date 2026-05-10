import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/api_service.dart';

class EditChapterScreen extends StatefulWidget {
  const EditChapterScreen({
    super.key,
    required this.apiService,
    required this.storyId,
    this.chapterTitle = 'Chapter 1',
    this.initialContent = '',
  });

  final ApiService apiService;
  final int storyId;
  final String chapterTitle;
  final String initialContent;

  @override
  State<EditChapterScreen> createState() => _EditChapterScreenState();
}

class _EditChapterScreenState extends State<EditChapterScreen> {
  late TextEditingController _titleController;
  late TextEditingController _textController;

  bool _isBold = false;
  bool _isItalic = false;
  bool _isLoading = true;
  bool _isSaving = false;

  int? _chapterId;
  int _chapterNumber = 1;

  int get _wordCount {
    final text = _textController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.chapterTitle);
    _textController = TextEditingController(text: widget.initialContent);
    _textController.addListener(() => setState(() {}));
    _loadChapter();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadChapter() async {
    setState(() => _isLoading = true);
    try {
      final chapters = await widget.apiService.fetchStoryChapters(widget.storyId);
      if (chapters.isNotEmpty) {
        final chapter = chapters.first;
        _chapterId = chapter['id'] as int?;
        _chapterNumber = (chapter['chapter_number'] as int?) ?? 1;
        _titleController.text =
            chapter['title']?.toString().trim().isNotEmpty == true
            ? chapter['title'].toString()
            : widget.chapterTitle;
        _textController.text = chapter['content']?.toString() ?? '';
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load chapter. You can still write and save.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChapter() async {
    final title = _titleController.text.trim();
    final content = _textController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter chapter title')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final payload = {
        'title': title,
        'content': content,
        'chapter_number': _chapterNumber,
      };

      if (_chapterId == null) {
        _chapterId = await widget.apiService.createStoryChapter(
          widget.storyId,
          payload,
        );
      } else {
        await widget.apiService.updateStoryChapter(_chapterId!, payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chapter saved to database')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save chapter')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteChapter() async {
    if (_chapterId == null) {
      Navigator.pop(context);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chapter'),
        content: const Text('Delete this chapter from database?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.apiService.deleteStoryChapter(_chapterId!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete chapter')),
        );
      }
    }
  }

  Future<bool?> _onWillPop() async {
    if (_textController.text.trim().isEmpty) return true;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your unsaved changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_rounded),
              title: const Text('Save Chapter'),
              onTap: () async {
                Navigator.pop(context);
                await _saveChapter();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text(
                'Delete Chapter',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteChapter();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop == true && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text('Edit Chapter'),
          actions: [
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded, color: AppTheme.brand),
              tooltip: 'Save',
              onPressed: _isSaving ? null : _saveChapter,
            ),
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: _showOptionsMenu,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppTheme.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Text(
                            'TITLE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.muted,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.ink,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Text(
                            'TEXT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.muted,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            keyboardType: TextInputType.multiline,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                              fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                              color: AppTheme.ink,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                              border: InputBorder.none,
                              hintText: 'Start writing your story here...',
                              hintStyle: TextStyle(color: AppTheme.muted),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'word count: $_wordCount',
                      style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppTheme.border)),
                      color: Color(0xFFFAFAFA),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          _ToolbarButton(icon: Icons.undo_rounded, onPressed: () {}),
                          _ToolbarButton(icon: Icons.redo_rounded, onPressed: () {}),
                          _ToolbarButton(
                            icon: Icons.format_bold_rounded,
                            onPressed: () => setState(() => _isBold = !_isBold),
                            isActive: _isBold,
                          ),
                          _ToolbarButton(
                            icon: Icons.format_italic_rounded,
                            onPressed: () => setState(() => _isItalic = !_isItalic),
                            isActive: _isItalic,
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: AppTheme.border,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          _ToolbarButton(
                            icon: Icons.delete_outline_rounded,
                            onPressed: _deleteChapter,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 22,
        color: isActive ? AppTheme.brand : AppTheme.muted,
      ),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }
}
