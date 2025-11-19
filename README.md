# smartbrowser

A new Flutter project.

## Getting Started

## Project Overview
The Flutter Smart Browser is an intelligent browser that allows users to:
✔️ Extract readable text
From the active webpage (via DOM / JS parsing) or from a selected local document (.txt, .pdf*, .docx*, .pptx, .xlsx).
✔️ Summarize any content
Using an AI summarizer (mock implementation, can be replaced with OpenAI/Mistral/Ollama backend).
✔️ Translate the summary
Into Hindi, Spanish, or French using mocked or external translation APIs.
✔️ Manage downloads & history
Documents downloaded or selected are stored locally with metadata, and summaries are saved for offline reading.
✔️ Multi-tab browsing
Tabs persist across sessions using local JSON storage (via TabManager).
✔️ Offline caching
Snapshots of webpage HTML are saved to disk. Users can re-open them without internet.

## Architecture (Clean Architecture + Riverpod)
┌──────────────────────────────────────────────────────────────┐
│                          PRESENTATION                         │
│  (Widgets, UI Screens, SummaryPanel, DownloadsView, etc.)     │
└────────────▲───────────────────────────────┬──────────────────┘
│                               │
│ uses                           │ watches via providers
│                               │
┌────────────┴───────────────────────────────▼──────────────────┐
│                         APPLICATION LAYER                      │
│  Riverpod Providers + Controllers                              │
│  (TabManager, FileManager, CacheManager, SummaryRepository)    │
└────────────▲───────────────────────────────┬──────────────────┘
│                               │
│ depends on                    │
│                               │
┌────────────┴───────────────────────────────▼──────────────────┐
│                         DOMAIN / SERVICES                      │
│  Business logic & AI Services:                                 │
│    - AiService (summarize + translate)                         │
│    - SummaryRepository (Hive storage)                          │
│    - Text extraction utilities                                 │
└────────────▲───────────────────────────────┬──────────────────┘
│                               │
│ CRUD / IO operations          │
│                               │
┌────────────┴───────────────────────────────▼──────────────────┐
│                             DATA                               │
│  Local file IO (FileManager), Hive storage, path_provider,     │
│  webview JS evaluation, caching snapshots, downloads handling  │
└────────────────────────────────────────────────────────────────┘
## State Management & Reasoning
The project uses Riverpod (ChangeNotifier + Provider) for:
✔ TabManager (ChangeNotifierProvider)
Tracks tabs, active tab ID, URLs
Persists tabs in a local file (tabs.json)
Notifies UI to update InputChip labels / reload WebView
✔ CacheManager
Saves webpage HTML snapshots
Fetches cached content for offline viewing
✔ FileManager
Handles:
Downloads (via dio)
Local file picker
File metadata storage in Hive
Opening files using open_file
✔ SummaryRepository (Hive box: summaries)
Stores summary objects (title, text, language, URL, timestamps)
Supports offline reading
✔ AiService
Mock or real backend integration for:
Text summarization
Multilingual translation
This combination keeps UI reactive, data persistent, and logic scalable.

## Packages Used
| Package                | Purpose                                |
| ---------------------- | -------------------------------------- |
| `flutter_inappwebview` | WebKit/Chromium in-app browser         |
| `flutter_riverpod`     | State management                       |
| `hive`, `hive_flutter` | Local storage for summaries, downloads |
| `dio`                  | Downloads + networking                 |
| `file_picker`          | Pick files for summarization           |
| `open_file`            | Open downloaded docs                   |
| `path_provider`        | Local file paths                       |
| `share_plus`           | Share summary text                     |
| `uuid`                 | Generate unique IDs                    |

## Setup Instructions
   1. Clone the repo
     git clone https://github.com/ajju1587/smart-browser
     cd smart-browser
   2. Install dependencies
     flutter pub get
   3. Android Run
     flutter run -d android
     Ensure Android SDK & emulator/device connected.
   4. Web Run
     flutter run -d chrome
     For WebView: web platform uses <iframe> mode with limited features. Summaries & translation work fine.
   5. Hive Boxes Initialization
      Boxes auto-open in main.dart:
      await Hive.openBox<FileMeta>('downloads');
      await Hive.openBox<String>('history');
      await Hive.openBox<Summary>('summaries');
