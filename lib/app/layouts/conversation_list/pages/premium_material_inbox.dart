import 'package:bluebubbles/app/components/avatars/contact_avatar_group_widget.dart';
import 'package:bluebubbles/app/layouts/conversation_list/pages/conversation_list.dart';
import 'package:bluebubbles/app/layouts/conversation_list/pages/search/search_view.dart';
import 'package:bluebubbles/app/layouts/conversation_list/widgets/header/header_widgets.dart';
import 'package:bluebubbles/app/layouts/conversation_list/widgets/tile/list_item.dart';
import 'package:bluebubbles/app/layouts/conversation_view/pages/conversation_view.dart';
import 'package:bluebubbles/database/models.dart';
import 'package:bluebubbles/helpers/helpers.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Dark Material presentation. Messages still use existing chat services.
class PremiumMaterialInbox extends StatefulWidget {
  const PremiumMaterialInbox({super.key, required this.parentController});
  final ConversationListController parentController;

  @override
  State<PremiumMaterialInbox> createState() => _PremiumMaterialInboxState();
}

class _PremiumMaterialInboxState extends State<PremiumMaterialInbox> {
  bool _unreadOnly = false;
  static const _navy = Color(0xFF081226);
  static const _card = Color(0xFF15223C);
  static const _blue = Color(0xFF078EFF);
  static const _muted = Color(0xFF9FAEC9);

  void _openChat(Chat chat) {
    ns.pushAndRemoveUntil(context, ConversationView(chat: chat), (route) => route.isFirst);
  }

  void _unpin(Chat chat) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _card,
      builder: (sheetContext) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.push_pin_outlined, color: Colors.white),
          title: const Text('Unpin conversation', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(sheetContext);
            chat.togglePin(false);
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _pinned(Chat chat) {
    return Padding(
      padding: const EdgeInsets.only(right: 23),
      child: InkWell(
        onTap: () => _openChat(chat),
        onLongPress: () => _unpin(chat),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 92,
          child: Column(children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // No outer ring or decorative border on contact pictures.
                ContactAvatarGroupWidget(chat: chat, size: 76, editable: false),
                Positioned(
                  bottom: 0, left: 0,
                  child: Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(color: Color(0xFF00C4DF), shape: BoxShape.circle),
                    child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ss.settings.redactedMode.value && ss.settings.hideContactInfo.value
                  ? (chat.participants.length > 1 ? 'Group Chat'
                      : chat.participants.isNotEmpty ? chat.participants.first.fakeName : 'Contact')
                  : chat.getTitle(),
              overflow: TextOverflow.ellipsis, maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }

  Widget _top(List<Chat> pinned, int unreadCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 5, 18, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        InkWell(
          onTap: () => ns.pushLeft(context, SearchView()),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 46, padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF223453), width: 0.7)),
            child: const Row(children: [
              Icon(Icons.search_rounded, color: _muted, size: 21),
              SizedBox(width: 11),
              Text('Search conversations', style: TextStyle(color: _muted, fontSize: 14)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(spacing: 10, children: [
          _filterChip('All', !_unreadOnly, () => setState(() => _unreadOnly = false)),
          _filterChip('Unread ($unreadCount)', _unreadOnly, () => setState(() => _unreadOnly = true)),
        ]),
        if (pinned.isNotEmpty) ...[
          const SizedBox(height: 22),
          SizedBox(height: 126,
            child: ListView(scrollDirection: Axis.horizontal, children: pinned.map(_pinned).toList())),
          const SizedBox(height: 6),
        ],
      ]),
    );
  }

  Widget _filterChip(String title, bool active, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      label: Text(title, style: TextStyle(
        color: active ? const Color(0xFF7BE6FF) : const Color(0xFFABB9D2),
        fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
      backgroundColor: active ? const Color(0xFF08394B) : _card,
      side: BorderSide(color: active ? const Color(0xFF0C789F) : Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _navy,
      child: Obx(() {
        final all = chats.chats.archivedHelper(false).unknownSendersHelper(false);
        final pinned = all.where((c) => c.isPinned == true &&
            (!_unreadOnly || GlobalChatService.unreadState(c.guid).value)).toList();
        final regular = all.where((c) => c.isPinned != true &&
            (!_unreadOnly || GlobalChatService.unreadState(c.guid).value)).toList();
        final unreadCount = all.where((c) => GlobalChatService.unreadState(c.guid).value).length;
        if (!chats.loadedChatBatch.value) {
          return const Center(child: CircularProgressIndicator(color: _blue));
        }
        return ListView.builder(
          controller: widget.parentController.materialScrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: regular.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _top(pinned, unreadCount);
            final chat = regular[index - 1];
            return Column(children: [
              ListItem(
                chat: chat, controller: widget.parentController,
                showDeleted: false, autofocus: index == 1,
                update: () => setState(() {}),
              ),
              const Padding(padding: EdgeInsets.only(left: 87, right: 18),
                child: Divider(color: Color(0xFF1B2B44), height: 1, thickness: 0.7)),
            ]);
          },
        );
      }),
    );
  }
}

class PremiumMaterialBottomBar extends StatelessWidget {
  const PremiumMaterialBottomBar({super.key, required this.controller});
  final ConversationListController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 66,
        decoration: const BoxDecoration(color: Color(0xFF0D172C),
          border: Border(top: BorderSide(color: Color(0xFF1D2C46), width: 0.7))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _action(Icons.home_outlined, 'Top', () {
            if (controller.materialScrollController.hasClients) {
              controller.materialScrollController.animateTo(0,
                duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
            }
          }),
          _action(Icons.chat_bubble_rounded, 'Messages', () {
            if (controller.materialScrollController.hasClients) {
              controller.materialScrollController.animateTo(0,
                duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
            }
          }, selected: true),
          _action(Icons.settings_outlined, 'Settings', () => goToSettings(context)),
        ]),
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap, {bool selected = false}) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(15),
      child: SizedBox(width: 100,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: selected ? const Color(0xFF02C8E6) : const Color(0xFF9BAAC5), size: 23),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(
            color: selected ? const Color(0xFF02C8E6) : const Color(0xFFB0BED3), fontSize: 11)),
        ]),
      ),
    );
  }
}
