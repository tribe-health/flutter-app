import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/account/account_server.dart';
import 'package:flutter_app/bloc/simple_cubit.dart';
import 'package:flutter_app/constants/resources.dart';
import 'package:flutter_app/db/extension/conversation.dart';
import 'package:flutter_app/db/extension/user.dart';
import 'package:flutter_app/db/mixin_database.dart';
import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/utils/hook.dart';
import 'package:flutter_app/widgets/avatar_view/avatar_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tuple/tuple.dart';

import '../action_button.dart';
import '../brightness_observer.dart';
import '../dialog.dart';
import '../high_light_text.dart';
import 'bloc/conversation_filter_cubit.dart';

String _getConversationName(dynamic item) {
  if (item is ConversationItem) return item.validName;
  if (item is User) return item.fullName ?? '?';
  throw ArgumentError('must be ConversationItem or User');
}

String _getConversationId(dynamic item) {
  if (item is ConversationItem) return item.conversationId;
  if (item is User) return item.userId;
  throw ArgumentError('must be ConversationItem or User');
}

bool _isBot(dynamic item) {
  if (item is ConversationItem) return false;
  if (item is User) return item.isBot;
  throw ArgumentError('must be ConversationItem or User');
}

Widget _getAvatarWidget(dynamic item) {
  if (item is ConversationItem) return item.avatarWidget;
  if (item is User) return item.avatarWidget;
  throw ArgumentError('must be ConversationItem or User');
}

extension _AvatarUser on User {
  Widget get avatarWidget => AvatarWidget(
        size: 50,
        avatarUrl: avatarUrl,
        name: fullName ?? '?',
        userId: userId,
      );
}

extension _AvatarConversationItem on ConversationItem {
  Widget get avatarWidget => ConversationAvatarWidget(
        size: 50,
        conversation: this,
      );
}

Future<List<Tuple2<String, bool>>> showConversationSelector({
  required BuildContext context,
  required bool singleSelect,
  required String title,
  required bool onlyContact,
  List<String> initSelectIds = const [],
}) async {
  return await showMixinDialog<List<Tuple2<String, bool>>>(
        context: context,
        child: _ConversationSelector(
          title: title,
          singleSelect: singleSelect,
          onlyContact: onlyContact,
          initSelectIds: initSelectIds,
        ),
      ) ??
      [];
}

class _ConversationSelector extends HookWidget {
  const _ConversationSelector({
    required this.singleSelect,
    required this.title,
    required this.onlyContact,
    this.initSelectIds = const [],
  });

  final String title;
  final bool singleSelect;
  final bool onlyContact;
  final List<String> initSelectIds;

  @override
  Widget build(BuildContext context) {
    final selector = useBloc(() => SimpleCubit<List<dynamic>>(const []));
    final selectItem = (dynamic item) {
      final list = [...selector.state];
      if (list.contains(item))
        list.remove(item);
      else
        list.add(item);
      selector.emit(list);
    };

    final conversationFilterCubit = useBloc(() => ConversationFilterCubit(
            useContext().read<AccountServer>(), onlyContact, (state) {
          state.recentConversations.forEach((element) {
            if (!initSelectIds.contains(element.conversationId)) return;
            selectItem(element);
          });
          state.friends.forEach((element) {
            if (!initSelectIds.contains(element.userId)) return;
            selectItem(element);
          });
          state.bots.forEach((element) {
            if (!initSelectIds.contains(element.userId)) return;
            selectItem(element);
          });
        }));
    final conversationFilterState =
        useBlocState<ConversationFilterCubit, ConversationFilterState>(
      bloc: conversationFilterCubit,
    );

    useEffect(
      () => selector.listen((event) {
        if (event.isNotEmpty && singleSelect) {
          final item = event.first;
          Navigator.pop(
              context, [Tuple2(_getConversationId(item), _isBot(item))]);
        }
      }).cancel,
    );
    final selected =
        useBlocState<SimpleCubit<List<dynamic>>, List<dynamic>>(bloc: selector);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 480,
        height: 600,
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ActionButton(
                        name: Resources.assetsImagesIcCloseSvg,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: BrightnessData.themeOf(context).text,
                              fontSize: 16,
                            ),
                          ),
                          if (!singleSelect)
                            Text(
                              '${selected.length} / ${conversationFilterState.recentConversations.length + conversationFilterState.friends.length + conversationFilterState.bots.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: BrightnessData.themeOf(context)
                                    .secondaryText,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: singleSelect || selected.isEmpty
                          ? const SizedBox()
                          : MixinButton(
                              backgroundTransparent: true,
                              padding: const EdgeInsets.all(8),
                              onTap: () => Navigator.pop(
                                context,
                                selected
                                    .map(
                                      (item) => Tuple2(
                                        _getConversationId(item),
                                        _isBot(item),
                                      ),
                                    )
                                    .toList(),
                              ),
                              child: Text(
                                Localization.of(context).next,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(top: 8, right: 24, left: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: TextField(
                onChanged: (string) => conversationFilterCubit.keyword = string,
                style: const TextStyle(
                  color: Colors.white,
                ),
                scrollPadding: EdgeInsets.zero,
                decoration: InputDecoration(
                  icon: SvgPicture.asset(
                    Resources.assetsImagesIcSearchSvg,
                    width: 20,
                  ),
                  contentPadding: const EdgeInsets.all(0),
                  isDense: true,
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.08)),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              vsync: useSingleTickerProvider(keys: [singleSelect]),
              child: singleSelect || selected.isEmpty
                  ? const SizedBox(height: 8)
                  : SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        itemBuilder: (context, index) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  _getAvatarWidget(selected[index]),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => selectItem(selected[index]),
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: BrightnessData.dynamicColor(
                                            context,
                                            const Color.fromRGBO(
                                                255, 255, 255, 1),
                                            darkColor: const Color.fromRGBO(
                                                62, 65, 72, 1),
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Container(
                                            height: 16,
                                            width: 16,
                                            decoration: BoxDecoration(
                                              color: BrightnessData.themeOf(
                                                      context)
                                                  .secondaryText,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                Resources
                                                    .assetsImagesSmallCloseSvg,
                                                color: BrightnessData.themeOf(
                                                        context)
                                                    .text,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _getConversationName(selected[index]),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: BrightnessData.themeOf(context).text,
                                ),
                              ),
                            ],
                          ),
                        ),
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(width: 16),
                        itemCount: selected.length,
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomScrollView(
                  slivers: [
                    if (conversationFilterState.recentConversations.isNotEmpty)
                      _Section(
                        title: Localization.of(context).recentConversations,
                        count:
                            conversationFilterState.recentConversations.length,
                        builder: (BuildContext context, int index) {
                          final item = conversationFilterState
                              .recentConversations[index];
                          return GestureDetector(
                            onTap: () => selectItem(item),
                            behavior: HitTestBehavior.opaque,
                            child: _BaseItem(
                              keyword: conversationFilterState.keyword,
                              avatar: item.avatarWidget,
                              title: item.validName,
                              selected: selected.any((element) =>
                                  _getConversationId(element) ==
                                  item.conversationId),
                              showSelector: !singleSelect,
                            ),
                          );
                        },
                      ),
                    if (conversationFilterState.friends.isNotEmpty)
                      _Section(
                        title: Localization.of(context).contact,
                        count: conversationFilterState.friends.length,
                        builder: (BuildContext context, int index) {
                          final item = conversationFilterState.friends[index];
                          return GestureDetector(
                            onTap: () => selectItem(item),
                            behavior: HitTestBehavior.opaque,
                            child: _BaseItem(
                              keyword: conversationFilterState.keyword,
                              avatar: item.avatarWidget,
                              title: item.fullName ?? '',
                              showSelector: !singleSelect,
                              selected: selected.any((element) =>
                                  _getConversationId(element) == item.userId),
                            ),
                          );
                        },
                      ),
                    if (conversationFilterState.bots.isNotEmpty)
                      _Section(
                        title: Localization.of(context).bots,
                        count: conversationFilterState.bots.length,
                        builder: (BuildContext context, int index) {
                          final item = conversationFilterState.bots[index];
                          return GestureDetector(
                            onTap: () => selectItem(item),
                            behavior: HitTestBehavior.opaque,
                            child: _BaseItem(
                              keyword: conversationFilterState.keyword,
                              avatar: item.avatarWidget,
                              title: item.fullName!,
                              showSelector: !singleSelect,
                              selected: selected.any((element) =>
                                  _getConversationId(element) == item.userId),
                            ),
                          );
                        },
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

class _Section extends StatelessWidget {
  const _Section({
    required this.builder,
    required this.title,
    required this.count,
    Key? key,
  }) : super(key: key);

  final IndexedWidgetBuilder builder;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => MultiSliver(
        pushPinnedChildren: true,
        children: [
          SliverPinnedHeader(
            child: Container(
              color: BrightnessData.dynamicColor(
                context,
                const Color.fromRGBO(255, 255, 255, 1),
                darkColor: const Color.fromRGBO(62, 65, 72, 1),
              ),
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 14),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: BrightnessData.themeOf(context).text,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              builder,
              childCount: count,
            ),
          ),
        ],
      );
}

class _BaseItem extends StatelessWidget {
  const _BaseItem({
    Key? key,
    required this.keyword,
    required this.title,
    required this.avatar,
    this.showSelector = false,
    this.selected = false,
  }) : super(key: key);

  final String title;
  final Widget avatar;
  final String? keyword;
  final bool showSelector;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
        height: 70,
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 14, right: 10),
        child: Row(
          children: [
            if (showSelector)
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ClipOval(
                  child: Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      color: selected
                          ? BrightnessData.themeOf(context).accent
                          : BrightnessData.themeOf(context).secondaryText,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(Resources.assetsImagesSelectedSvg),
                  ),
                ),
              ),
            avatar,
            const SizedBox(width: 16),
            HighlightText(
              title,
              highlightTextSpans: [
                if (keyword != null)
                  HighlightTextSpan(
                    keyword!,
                    style: TextStyle(
                        color: BrightnessData.themeOf(context).accent),
                  )
              ],
              style: TextStyle(
                fontSize: 14,
                color: BrightnessData.themeOf(context).text,
              ),
            ),
          ],
        ),
      );
}