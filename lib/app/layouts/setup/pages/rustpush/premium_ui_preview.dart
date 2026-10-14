import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Isolated, sample-data-only preview of our custom Material interface.
/// This never touches Apple authentication, hosted subscriptions, or chat services.
class PremiumUiPreview extends StatefulWidget {
  const PremiumUiPreview({super.key});

  @override
  State<PremiumUiPreview> createState() => _PremiumUiPreviewState();
}

class _DemoConversation {
  final String name;
  final String initials;
  final String snippet;
  final String when;
  final Color avatar;
  final bool pinned;
  final bool unread;
  final bool imessage;

  const _DemoConversation({
    required this.name,
    required this.initials,
    required this.snippet,
    required this.when,
    required this.avatar,
    this.pinned = false,
    this.unread = false,
    this.imessage = true,
  });
}

const _demoChats = <_DemoConversation>[
  _DemoConversation(name: 'Alex', initials: 'A', snippet: 'See you tomorrow!', when: 'Now',
      avatar: Color(0xFF426E9A), pinned: true, unread: true),
  _DemoConversation(name: 'Sam', initials: 'S', snippet: 'That sounds good to me.', when: '10:42',
      avatar: Color(0xFF875D83), pinned: true),
  _DemoConversation(name: 'Family', initials: 'F', snippet: 'Photos from the weekend', when: 'Yesterday',
      avatar: Color(0xFF4F8278), pinned: true, unread: true),
  _DemoConversation(name: 'Jordan', initials: 'J', snippet: 'Are we still on for tonight?', when: '9:41',
      avatar: Color(0xFF4681B8), unread: true),
  _DemoConversation(name: 'Taylor', initials: 'T', snippet: 'Thanks, I appreciate it!', when: '8:32',
      avatar: Color(0xFF775B9D)),
  _DemoConversation(name: 'Chris', initials: 'C', snippet: 'I can call you later.', when: 'Yesterday',
      avatar: Color(0xFF426E6C), imessage: false),
  _DemoConversation(name: 'Morgan', initials: 'M', snippet: 'Just checking in.', when: 'Tuesday',
      avatar: Color(0xFFAE735E)),
];

class _PremiumUiPreviewState extends State<PremiumUiPreview> {
  static const navy = Color(0xFF081226);
  static const surface = Color(0xFF15233D);
  static const muted = Color(0xFFA8B6CD);
  static const blue = Color(0xFF0A8BFF);

  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _unreadOnly = false;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openChat(_DemoConversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _PreviewConversationPage(conversation: conversation)),
    );
  }

  Widget _avatar(_DemoConversation chat, double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: chat.avatar,
      child: Text(chat.initials,
        style: TextStyle(color: Colors.white, fontSize: size * 0.38,
          fontWeight: FontWeight.w600)),
    );
  }

  Widget _chip(String text, bool selected, VoidCallback action) {
    return ActionChip(
      onPressed: action,
      shape: const StadiumBorder(),
      side: BorderSide(color: selected ? const Color(0xFF177B99) : Colors.transparent),
      backgroundColor: selected ? const Color(0xFF113D4F) : surface,
      label: Text(text, style: TextStyle(
        color: selected ? const Color(0xFF81E1FC) : muted,
        fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final data = _demoChats.where((c) =>
      (!_unreadOnly || c.unread) &&
      (q.isEmpty || c.name.toLowerCase().contains(q) || c.snippet.toLowerCase().contains(q))).toList();
    final pins = data.where((c) => c.pinned).toList();
    final regular = data.where((c) => !c.pinned).toList();
    final unreadCount = _demoChats.where((c) => c.unread).length;
    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: navy,
        colorScheme: const ColorScheme.dark(primary: blue, surface: navy),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: navy,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: IconButton(
            tooltip: 'Close preview',
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Messages', style: TextStyle(
            fontSize: 29, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          actions: [
            IconButton(
              tooltip: 'Search',
              onPressed: () => _searchFocus.requestFocus(),
              icon: const Icon(Icons.search_rounded)),
            IconButton(
              tooltip: 'Preview only',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preview only — your account and messages are unchanged.'))),
              icon: const Icon(Icons.more_vert_rounded)),
          ],
        ),
        body: SafeArea(
          child: Column(children: [
            Container(
              margin: const EdgeInsets.fromLTRB(17, 4, 17, 10),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF133047),
                borderRadius: BorderRadius.circular(14)),
              child: const Row(children: [
                Icon(Icons.visibility_outlined, color: Color(0xFF6BD7F1), size: 17),
                SizedBox(width: 8),
                Expanded(child: Text('DEMO PREVIEW · No real messages or activation',
                  style: TextStyle(fontSize: 11, color: Color(0xFFD7E9F7)))),
              ]),
            ),
            Expanded(
              child: ListView(children: [
                Container(
                  height: 46,
                  margin: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: surface,
                    borderRadius: BorderRadius.circular(24)),
                  child: Row(children: [
                    const Icon(Icons.search_rounded, color: muted, size: 21),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(
                      focusNode: _searchFocus,
                      controller: _search,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        isDense: true, border: InputBorder.none,
                        hintText: 'Search conversations',
                        hintStyle: TextStyle(color: muted, fontSize: 14)),
                    )),
                    if (_search.text.isNotEmpty) IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () { _search.clear(); setState(() {}); },
                      icon: const Icon(Icons.close_rounded, color: muted, size: 18)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(children: [
                    _chip('All', !_unreadOnly, () => setState(() => _unreadOnly = false)),
                    const SizedBox(width: 10),
                    _chip('Unread ($unreadCount)', _unreadOnly,
                      () => setState(() => _unreadOnly = true)),
                  ]),
                ),
                if (pins.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  SizedBox(height: 122, child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: pins.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 24),
                    itemBuilder: (_, i) {
                      final chat = pins[i];
                      return InkWell(
                        onTap: () => _openChat(chat),
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(width: 76, child: Column(children: [
                          _avatar(chat, 70),
                          const SizedBox(height: 8),
                          Text(chat.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: Colors.white)),
                        ])),
                      );
                    },
                  )),
                ],
                const SizedBox(height: 8),
                for (final chat in regular) ...[
                  ListTile(
                    onTap: () => _openChat(chat),
                    contentPadding: const EdgeInsets.only(left: 20, right: 19),
                    minVerticalPadding: 13,
                    leading: _avatar(chat, 54),
                    title: Text(chat.name,
                      style: TextStyle(fontSize: 16, color: Colors.white,
                        fontWeight: chat.unread ? FontWeight.w700 : FontWeight.w600)),
                    subtitle: Text(chat.snippet, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: muted)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(chat.when, style: const TextStyle(fontSize: 11, color: muted)),
                        const SizedBox(height: 7),
                        if (chat.unread) const CircleAvatar(radius: 4, backgroundColor: blue),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 94, right: 20),
                    child: Divider(height: 1, thickness: 0.7, color: Color(0xFF233149)),
                  ),
                ],
                if (regular.isEmpty && pins.isEmpty)
                  const Padding(padding: EdgeInsets.all(34),
                    child: Text('No matching sample conversations.',
                      style: TextStyle(color: muted))),
              ]),
            ),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preview only — no message was created.'))),
          backgroundColor: blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.edit_rounded, color: Colors.white),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            height: 62,
            decoration: const BoxDecoration(color: Color(0xFF0E192C),
              border: Border(top: BorderSide(color: Color(0xFF25334C), width: 0.6))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _DemoTab(icon: Icons.home_outlined, text: 'Home'),
              _DemoTab(icon: Icons.chat_bubble_rounded, text: 'Messages', active: true),
              _DemoTab(icon: Icons.settings_outlined, text: 'Settings'),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DemoTab extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool active;
  const _DemoTab({required this.icon, required this.text, this.active = false});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 22, color: active ? const Color(0xFF45D5F1) : const Color(0xFF9AABC4)),
      const SizedBox(height: 3),
      Text(text, style: TextStyle(fontSize: 10,
        color: active ? const Color(0xFF45D5F1) : const Color(0xFF9AABC4))),
    ],
  );
}

class _PreviewConversationPage extends StatefulWidget {
  final _DemoConversation conversation;
  const _PreviewConversationPage({required this.conversation});

  @override
  State<_PreviewConversationPage> createState() => _PreviewConversationPageState();
}

class _PreviewConversationPageState extends State<_PreviewConversationPage> {
  final _composer = TextEditingController();
  final List<(String, bool)> _messages = [
    ('Hey! Are you free this afternoon?', false),
    ('Yes, I should be free after 4.', true),
    ('Perfect, see you then!', false),
  ];

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _sendDemo() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add((text, true)));
    _composer.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to this preview only. Nothing was sent.')));
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.conversation;
    final blue = chat.imessage;
    final incoming = blue ? const Color(0xFF1B4B95) : const Color(0xFF28633B);
    final outgoing = blue ? const Color(0xFF078BFF) : const Color(0xFF30B64B);
    const navy = Color(0xFF081226);
    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.dark(primary: outgoing, surface: navy)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: navy,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            onPressed: () => Navigator.of(context).pop()),
          titleSpacing: 0,
          title: Row(children: [
            CircleAvatar(radius: 19, backgroundColor: chat.avatar,
              child: Text(chat.initials, style: const TextStyle(color: Colors.white))),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(chat.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              Text(blue ? 'iMessage · Preview' : 'SMS · Preview',
                style: const TextStyle(color: Color(0xFF9CAFCB), fontSize: 11)),
            ]),
          ]),
        ),
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(9),
              child: Text(blue ? 'iMessage example · blue bubbles' : 'SMS example · green bubbles',
                style: const TextStyle(fontSize: 12, color: Color(0xFF93A9C4)))),
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final m = _messages[index];
                return Align(
                  alignment: m.$2 ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.77),
                    margin: const EdgeInsets.only(bottom: 11),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    decoration: BoxDecoration(
                      color: m.$2 ? outgoing : incoming,
                      borderRadius: BorderRadius.circular(19)),
                    child: Text(m.$1,
                      style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.35)),
                  ),
                );
              },
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 14),
              child: Row(children: [
                Expanded(child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF17253D),
                    borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _composer,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendDemo(),
                    decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Type a sample message',
                      hintStyle: TextStyle(color: Color(0xFF9BAAC2)))),
                )),
                const SizedBox(width: 9),
                IconButton.filled(
                  onPressed: _sendDemo,
                  style: IconButton.styleFrom(backgroundColor: outgoing),
                  icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
