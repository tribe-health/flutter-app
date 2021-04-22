import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/account/account_server.dart';
import 'package:flutter_app/bloc/paging/load_more_paging.dart';
import 'package:flutter_app/constants/resources.dart';
import 'package:flutter_app/db/mixin_database.dart';
import 'package:flutter_app/enum/media_status.dart';
import 'package:flutter_app/enum/message_category.dart';
import 'package:flutter_app/ui/home/bloc/conversation_cubit.dart';
import 'package:flutter_app/utils/hook.dart';
import 'package:flutter_app/widgets/brightness_observer.dart';
import 'package:flutter_app/widgets/interacter_decorated_box.dart';
import 'package:flutter_app/widgets/status.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:flutter_app/generated/l10n.dart';

class FilePage extends HookWidget {
  const FilePage({
    Key? key,
    required this.maxHeight,
  }) : super(key: key);

  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final size = useMemoized(() => maxHeight / 90 * 2, [maxHeight]).toInt();
    final conversationId =
        useBlocStateConverter<ConversationCubit, ConversationState?, String?>(
      converter: (state) => state?.conversationId,
      when: (conversationId) => conversationId != null,
    )!;

    final messagesDao = context.read<AccountServer>().database.messagesDao;

    final mediaCubit = useBloc(
      () => LoadMorePagingBloc<MessageItem>(
        reloadData: () =>
            messagesDao.fileMessages(conversationId, size, 0).get(),
        loadMoreData: (list) async {
          if (list.isEmpty) return [];
          final last = list.last;
          final rowId =
              await messagesDao.messageRowId(last.messageId).getSingleOrNull();
          if (rowId == null) return [];
          final items = await messagesDao
              .fileMessagesBefore(rowId, conversationId, size)
              .get();
          return [...list, ...items];
        },
        isSameKey: (a, b) => a.messageId == b.messageId,
      ),
      keys: [conversationId],
    );
    useEffect(
      () => messagesDao.insertOrReplaceMessageStream
          .switchMap<MessageItem>((value) async* {
            for (final item in value) yield item;
          })
          .where((event) =>
              event.conversationId == conversationId &&
              [
                MessageCategory.plainData,
                MessageCategory.signalData,
              ].contains(event.type))
          .listen(mediaCubit.insertOrReplace)
          .cancel,
      [conversationId],
    );
    final map = useBlocStateConverter<LoadMorePagingBloc<MessageItem>,
        LoadMorePagingState<MessageItem>, Map<DateTime, List<MessageItem>>>(
      bloc: mediaCubit,
      converter: (state) => groupBy<MessageItem, DateTime>(
        state.list,
        (messageItem) {
          final local = messageItem.createdAt.toLocal();
          return DateTime(local.year, local.month, local.day);
        },
      ),
    );

    if (map.isEmpty)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Resources.assetsImagesEmptyFileSvg,
              color: BrightnessData.themeOf(context).secondaryText,
            ),
            const SizedBox(height: 24),
            Text(
              Localization.of(context).noFile,
              style: TextStyle(
                fontSize: 12,
                color: BrightnessData.themeOf(context).secondaryText,
              ),
            ),
          ],
        ),
      );

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is! ScrollUpdateNotification) return false;
        if (notification.scrollDelta == null) return false;
        if (notification.scrollDelta! < 0) return false;

        final dimension = notification.metrics.viewportDimension / 2;

        if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
            dimension) {
          mediaCubit.loadMore();
        }

        return false;
      },
      child: CustomScrollView(
        slivers: map.entries
            .map(
              (e) => MultiSliver(
                pushPinnedChildren: true,
                children: [
                  SliverPinnedHeader(
                    child: Container(
                      color: BrightnessData.themeOf(context).primary,
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        DateFormat.yMMMd().format(e.key),
                        style: TextStyle(
                          fontSize: 14,
                          color: BrightnessData.themeOf(context).secondaryText,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final message = e.value[index];
                        return _Item(message: message);
                      },
                      childCount: e.value.length,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.message,
  }) : super(key: key);

  final MessageItem message;

  @override
  Widget build(BuildContext context) => InteractableDecoratedBox(
        onTap: () async {
          if (message.mediaStatus == MediaStatus.canceled) {
            if (message.relationship == UserRelationship.me &&
                message.mediaUrl?.isNotEmpty == true) {
              await context.read<AccountServer>().reUploadAttachment(message);
            } else {
              await context.read<AccountServer>().downloadAttachment(message);
            }
          } else if (message.mediaStatus == MediaStatus.done &&
              message.mediaUrl != null) {
            if (message.mediaUrl?.isEmpty ?? true) return;
            final path = await getSavePath(
              confirmButtonText: Localization.of(context).save,
              suggestedName: message.mediaName ?? basename(message.mediaUrl!),
            );
            if (path?.isEmpty ?? true) return;
            await File(message.mediaUrl!).copy(path!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox.fromSize(
                  size: const Size.square(50),
                  child: Builder(builder: (context) {
                    switch (message.mediaStatus) {
                      case MediaStatus.canceled:
                        if (message.relationship == UserRelationship.me &&
                            message.mediaUrl?.isNotEmpty == true)
                          return const StatusUpload();
                        else
                          return const StatusDownload();
                      case MediaStatus.pending:
                        return const StatusPending();
                      case MediaStatus.expired:
                        return const StatusWarning();
                      default:
                        break;
                    }

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: BrightnessData.themeOf(context).listSelected,
                      ),
                      child: Center(
                        child: Builder(builder: (context) {
                          var extension = 'FILE';
                          if (message.mediaName != null) {
                            final _lookupMimeType =
                                lookupMimeType(message.mediaName!);
                            if (_lookupMimeType != null)
                              extension = extensionFromMime(_lookupMimeType)
                                  .toUpperCase();
                          }
                          return Text(
                            extension,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  BrightnessData.themeOf(context).secondaryText,
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.mediaName ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: BrightnessData.themeOf(context).text,
                    ),
                  ),
                  Text(
                    filesize(message.mediaSize),
                    style: TextStyle(
                      fontSize: 14,
                      color: BrightnessData.themeOf(context).secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}