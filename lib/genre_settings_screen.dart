import 'package:flutter/material.dart';
import 'brand_data.dart'; // SearchGenre と getGenreDisplayName を使用するため

class GenreSettingsScreen extends StatefulWidget {
  final List<SearchGenre> currentGenreOrder;
  final Map<SearchGenre, bool> currentGenreVisibility;

  const GenreSettingsScreen({
    super.key,
    required this.currentGenreOrder,
    required this.currentGenreVisibility,
  });

  @override
  State<GenreSettingsScreen> createState() => _GenreSettingsScreenState();
}

class _GenreSettingsScreenState extends State<GenreSettingsScreen> {
  late List<SearchGenre> _editableGenreOrder;
  late Map<SearchGenre, bool> _editableGenreVisibility;

  @override
  void initState() {
    super.initState();
    _editableGenreOrder = List.from(widget.currentGenreOrder);
    _editableGenreVisibility = Map.from(widget.currentGenreVisibility);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('検索ジャンル設定'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'order': _editableGenreOrder,
                'visibility': _editableGenreVisibility,
              });
            },
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: _editableGenreOrder.length,
        itemBuilder: (context, index) {
          final genre = _editableGenreOrder[index];
          return SwitchListTile(
            key: ValueKey(genre),
            title: Text(BrandData.getGenreDisplayName(genre)),
            value: _editableGenreVisibility[genre] ?? true,
            onChanged: (bool value) {
              setState(() {
                _editableGenreVisibility[genre] = value;
              });
            },
            secondary: const Icon(Icons.drag_handle),
          );
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final SearchGenre item = _editableGenreOrder.removeAt(oldIndex);
            _editableGenreOrder.insert(newIndex, item);
          });
        },
      ),
    );
  }
}