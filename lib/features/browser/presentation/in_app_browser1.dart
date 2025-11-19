import 'package:flutter/material.dart';
import 'address_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/providers.dart';
import '../../browser/data/tab_manager.dart';
import '../../files/data/cache_manager.dart';

class InAppBrowser extends ConsumerStatefulWidget {
  final String initialUrl;
  const InAppBrowser({required this.initialUrl, Key? key}) : super(key: key);

  @override
  ConsumerState<InAppBrowser> createState() => _InAppBrowserState();
}

class _InAppBrowserState extends ConsumerState<InAppBrowser> {
  InAppWebViewController? _controller;
  String? _currentTabId;
  TabManager? _tabManager;
  CacheManager? _cacheManager;
  bool _isOfflineView = false;
  String? _offlineContent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _tabManager = ref.read(tabManagerProvider);
      _cacheManager = ref.read(cacheManagerProvider);
      await _tabManager!.loadFromDisk();
      if (_tabManager!.tabs.isEmpty) {
        await _tabManager!.createTab(widget.initialUrl);
      }
      setState(() {
        _currentTabId = _tabManager!.activeTab!.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ref.watch(tabManagerProvider).tabs;
    final activeTab = ref.watch(tabManagerProvider).activeTab;
    final url = activeTab?.url ?? widget.initialUrl;

    return Column(
      children: [
        // Tabs row
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: tabs.map((t) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(t.url.length > 20 ? t.url.substring(0, 20) + '...' : t.url),
                  selected: t.active,
                  onSelected: (_) async {
                    await ref.read(tabManagerProvider).switchTo(t.id);
                    setState(() {
                      _currentTabId = t.id;
                      _isOfflineView = false;
                    });
                  },

                  /*onDeleted: () async {
                    await ref.read(tabManagerProvider).closeTab(t.id);
                    setState(() {
                      if (ref.read(tabManagerProvider).activeTab != null) {
                        _currentTabId = ref.read(tabManagerProvider).activeTab!.id;
                      }
                    });
                  },*/
                ),
              );
            }).toList()
              ..add(
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ActionChip(
                    label: const Icon(Icons.add),
                    onPressed: () async {
                      final newUrl = 'https://example.com';
                      await ref.read(tabManagerProvider).createTab(newUrl);
                      setState(() {
                        _currentTabId = ref.read(tabManagerProvider).activeTab!.id;
                        _isOfflineView = false;
                      });
                    },
                  ),
                ),
              ),
          ),
        ),
        AddressBar(
          initialUrl: url,
          onNavigate: (navigateUrl) async {
            if (_currentTabId != null) {
              await ref.read(tabManagerProvider).updateUrl(_currentTabId!, navigateUrl);
              setState(() {
                _isOfflineView = false;
              });
              if (_controller != null) {
                await _controller!.loadUrl(urlRequest: URLRequest(url: WebUri.uri(Uri.parse(navigateUrl))));
              }
            }
          },
        ),
        Expanded(
          child: _isOfflineView
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Text(_offlineContent ?? 'No cached content'),
                )
              : InAppWebView(
                  //initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  initialUrlRequest: URLRequest(
                    url: WebUri.uri(Uri.parse(url)),
                  ),
                  onWebViewCreated: (controller) => _controller = controller,
                  onLoadStop: (controller, uri) async {
                    // extract a snapshot (cleaned HTML) and save to cache for offline
                    try {
                      final html = await controller.getHtml(); // convenience method
                      if (html != null && uri != null) {
                        await ref.read(cacheManagerProvider).saveSnapshot(uri.toString(), html);
                      }
                    } catch (_) {}
                  },
                  onDownloadStartRequest: (controller, download) async {
                    final fm = ref.read(fileManagerProvider);
                    final url = download.url.toString();
                    fm.startDownload(url);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download started: $url')));
                  },
                ),
        ),
        // bottom controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text('Save snapshot'),
              onPressed: () async {
                if (_controller == null || activeTab == null) return;
                try {
                  final html = await _controller!.getHtml();
                  if (html != null) {
                    await ref.read(cacheManagerProvider).saveSnapshot(activeTab.url, html);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Snapshot saved'))); 
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: \$e'))); 
                }
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download Document'),
              onPressed: () async {
                final fm = ref.read(fileManager_provider);
                final current = _currentUrl ?? '';
                if (current.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No document URL found')));
                  return;
                }
                if (!fm.isSupportedDocument(current)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL is not a supported document type (PDF/DOCX/PPTX/XLSX)')));
                  return;
                }
                final meta = await fm.startDownload(current);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download queued: \${meta.filename ?? meta.url}')));
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.offline_pin),
              label: const Text('Open cached'),
              onPressed: () async {
                if (activeTab == null) return;
                final html = await ref.read(cacheManagerProvider).loadSnapshot(activeTab.url);
                if (html != null) {
                  setState(() {
                    _isOfflineView = true;
                    _offlineContent = _stripHtml(html);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No cached snapshot'))); 
                }
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
              onPressed: () async {
                setState(() { _isOfflineView = false; });
                if (_controller != null) await _controller!.reload();
              },
            ),
          ],
        )
      ],
    );
  }

  String _stripHtml(String html) {
    // very simple strip, not for production
    return html.replaceAll(RegExp(r'<[^>]*>|\\n|\\r'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
