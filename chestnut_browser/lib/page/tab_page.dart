import 'package:chestnut_browser/Util/colors_util.dart';
import 'package:chestnut_browser/component/background.dart';
import 'package:chestnut_browser/page/base_page_state.dart';
import 'package:chestnut_browser/provider/home_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});
  @override
  State<StatefulWidget> createState() => _TabState();
}

class _TabState extends BasePageState {
  @override
  Widget build(BuildContext context) {
    return Background(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [ Flexible(child: _buildCenterView()), _buildFooterView()],
        ),
      ),
    );
  }

  @cwidget
  Widget _buildCenterView() {
    return Consumer<HomeProvider>(
        builder: (context, provider, child) => GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              childAspectRatio: 158 / 204,
              children:
                  List<Widget>.from(provider.items.map((e) => _TabItem(
                        e,
                        select: selected,
                        delete: delete,
                      ))),
            ));
  }

  @swidget
  Widget _buildFooterView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CupertinoButton(
            onPressed: add,
            padding: EdgeInsets.zero,
            child: Image.asset('assets/images/tab_add.png')),
        Row(
          children: [
            const Flexible(child: Center()),
            CupertinoButton(onPressed: goBack, child: const Text('Back'))
          ],
        )
      ],
    );
  }
}

typedef _TabDeleteHandle = void Function(BrowserItem item);
typedef _TabSelectedHandle = void Function(BrowserItem item);

class _TabItem extends StatefulWidget {
  final BrowserItem item;
  final _TabDeleteHandle? delete;
  final _TabSelectedHandle? select;

  const _TabItem(this.item, {this.delete, this.select});

  @override
  State<StatefulWidget> createState() =>
      _TabItemState(item, delete: delete, select: select);
}

class _TabItemState extends State<_TabItem> {
  final BrowserItem item;
  final _TabDeleteHandle? delete;
  final _TabSelectedHandle? select;

  _TabItemState(this.item, {this.delete, this.select});

  String title = "";
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    setTitleState();
  }

  void setTitleState() async {
    final title = await item.controller.currentUrl() ?? "Navigation";
    setState(() {
      this.title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          _buildCenterView(item, select),
          HomeProvider().items.length <= 1
              ? const Center()
              : _buildDeleteButton(item, delete)
        ],
      ),
    );
  }

  @cwidget
  Widget _buildCenterView(BrowserItem item, _TabSelectedHandle? select) {
    return CupertinoButton(
        onPressed: () {
          if (select != null) {
            select(item);
          }
        },
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Container(
              color: item.isSelect ? ColorsUtil("#FE7B00") : Colors.white,
            ),
            Center(
              child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14.0),
                  )),
            )
          ],
        ));
  }

  @cwidget
  Widget _buildDeleteButton(BrowserItem item, _TabSelectedHandle? delete) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Center(),
        Column(
          children: [
            CupertinoButton(
              onPressed: () {
                if (delete != null) {
                  delete(item);
                }
              },
              child: Image.asset("assets/images/tab_delete.png"),
            ),
          ],
        )
      ],
    );
  }
}

extension _TabStateExt on _TabState {
  void goBack() {
    Navigator.pop(context);
  }

  void delete(BrowserItem item) {
    HomeProvider().removeItem(item);
  }

  void selected(BrowserItem item) {
    HomeProvider().selected(item);
    Navigator.pop(context);
  }

  void add() {
    HomeProvider().addItems();
    Navigator.pop(context);
  }
}
