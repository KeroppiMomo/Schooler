import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';

ListScreenResources _R = R.listScreen;

class ListScreen<T> extends StatefulWidget {
  /// Title text on the [AppBar].
  final String appBarTitle;

  /// Actions widget on the [AppBar].
  final List<Widget> appBarActions;

  /// Tooltip of the FAB button for adding.
  final String addFABTooltip;

  /// Icon of the FAB button for adding.
  final IconData addFABIcon;

  /// Source of data. This function should perform no processing and should purely act as a getter.
  final List<T> Function() source;

  /// Default sorting of items, with its name as the key and the compare object function as the value.
  final MapEntry<String, Comparable Function(T)> defaultSorting;

  /// Default sorting direction of [defaultSorting]. This is a really useful comment.
  final SortDirection defaultSortDirection;

  /// Name of sorting when no sorting is applied.
  final String noSortText;

  /// Available sortings of items, with their name as the key and the compare object function as the value.
  final Map<String, Comparable Function(T)> sortings;

  /// Search string of an item. The item appears in the search result if the search string contains the search pattern.
  final String Function(T item) searchString;

  /// Value listener for updating the list automatically.
  final ValueListenable<List<T>> listener;

  /// A [Widget] builder to build the separation between two items.
  final Widget Function(BuildContext context, int index) separatorBuilder;

  /// A [Widget} builder to build the item.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Called when the "Add" button is pressed.
  final Function() addPressed;

  /// Called when an item is pressed.
  final Function(T item) itemPressed;

  ListScreen({
    Key key,
    this.appBarTitle,
    this.appBarActions,
    this.addFABTooltip,
    this.addFABIcon,
    this.source,
    this.sortings,
    this.defaultSorting,
    this.defaultSortDirection,
    this.noSortText,
    this.searchString,
    this.addPressed,
    this.listener,
    this.separatorBuilder,
    this.itemBuilder,
    this.itemPressed,
  }) : super(key: key);
  @override
  ListScreenState createState() => ListScreenState<T>();
}

enum SortDirection { ascending, descending }

@visibleForTesting
class ListScreenState<T> extends State<ListScreen<T>> {
  MapEntry<String, Comparable Function(T)> _sorting;
  SortDirection _sortDirection;

  TextEditingController _searchBarController;

  /// Total number of items in Settings last time refreshed.
  /// This variable is to determine whether an item is added
  /// or removed.
  int _totalNoOfItems = 0;

  @override
  void initState() {
    super.initState();
    _sorting = widget.defaultSorting;
    _sortDirection = widget.defaultSortDirection;
    _searchBarController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    _totalNoOfItems = widget.source().length;
    List<T> items =
        _sortItems(_filterSearchItems(widget.source() ?? []));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        actions: widget.appBarActions,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        tooltip: widget.addFABTooltip,
        child: Icon(widget.addFABIcon),
        onPressed: widget.addPressed,
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchBarController,
            decoration: InputDecoration(
              filled: true,
              prefixIcon: Icon(_R.searchBarIcon),
              suffixIcon: IconButton(
                icon: Icon(_R.searchBarClearIcon),
                tooltip: _R.searchBarClearTooltip,
                onPressed: _searchBarCleared,
              ),
              hintText: _R.searchBarHintText,
            ),
            onChanged: _searchBarChanged,
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: widget.listener,
              builder: (context, _, __) {
                if (widget.source().length != _totalNoOfItems) {
                  items = _sortItems(_filterSearchItems(widget.source() ?? []));
                  _totalNoOfItems = widget.source().length;
                }

                return RefreshIndicator(
                  child: ListView.separated(
                    padding: _R.listViewPadding,
                    itemCount: items.length + 1, // +1 is the sort row
                    separatorBuilder: widget.separatorBuilder,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Row(children: <Widget>[
                          Text(_R.sortText),
                          SizedBox(width: _R.sortTextChipsSpacing),
                          Expanded(
                            child: _buildSortRow(),
                          ),
                        ]);
                      }
                      return _buildItem(items[i - 1]);
                    },
                  ),
                  onRefresh: _onRefresh,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortRow() {
    return SizedBox(
      height: _R.sortRowHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var entry in widget.sortings.entries)
            Row(children: [
              FilterChip(
                avatar: (_sorting != null && entry.key == _sorting.key)
                    ? Icon(
                        _sortDirection == SortDirection.ascending
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                      )
                    : null,
                label: Text(entry.key),
                showCheckmark: false,
                selectedColor: _R.getSortChipSelectedColor(context),
                selected: _sorting != null && entry.key == _sorting.key,
                onSelected: (_) => _sortingPressed(entry),
              ),
              SizedBox(width: _R.sortChipsSpacing),
            ]),
          FilterChip(
            // Just follow the order of source (or reversed)
            avatar: _sorting == null
                ? Icon(
                    _sortDirection == SortDirection.ascending
                        ? _R.sortAscendingIcon
                        : _R.sortDescendingIcon,
                  )
                : null,
            label: Text(widget.noSortText),
            showCheckmark: false,
            selectedColor: _R.getSortChipSelectedColor(context),
            selected: _sorting == null,
            onSelected: (_) => _sortingPressed(null),
          ),
          SizedBox(width: _R.sortChipsSpacing),
        ],
      ),
    );
  }

  Widget _buildItem(T item) {
    return InkWell(
      key: ValueKey(item),
      child: widget.itemBuilder(context, item),
      onTap: () => widget.itemPressed(item),
    );
  }

  List<T> _sortItems(List<T> items) {
    if (_sorting == null) {
      if (_sortDirection == SortDirection.ascending)
        return items;
      else
        return items.reversed.toList();
    } else {
      final cloned = items.map((a) => a).toList();
      cloned.sort((a1, a2) {
        final sortValue1 = _sorting.value(a1);
        final sortValue2 = _sorting.value(a2);
        if (_sortDirection == SortDirection.ascending) {
          return Comparable.compare(sortValue1, sortValue2);
        } else {
          return Comparable.compare(sortValue2, sortValue1);
        }
      });
      return cloned;
    }
  }

  List<T> _filterSearchItems(List<T> items) {
    // An item passes the filter if its search string contains every word in the search pattern.
    final patterns = _searchBarController.text.trim().toLowerCase().split(' ');
    return items.where((item) {
      final searchString = widget.searchString(item);
      return patterns
          .every((pattern) => searchString.toLowerCase().contains(pattern));
    }).toList();
  }

  void _searchBarCleared() {
    setState(() {
      _searchBarController.clear();
    });
  }

  void _searchBarChanged(String text) {
    setState(() {});
  }

  /// `sorting` can be null.
  void _sortingPressed(MapEntry<String, Comparable Function(T)> sorting) {
    setState(() {
      if (this._sorting?.key == sorting?.key) {
        if (_sortDirection == SortDirection.ascending)
          _sortDirection = SortDirection.descending;
        else
          _sortDirection = SortDirection.ascending;
      } else {
        this._sorting = sorting;
        _sortDirection = SortDirection.ascending;
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() {});
    await Future.delayed(_R.refreshDelay);
  }
}
