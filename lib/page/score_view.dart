import 'dart:io';
import 'dart:ui';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:class_todo_list/adaptive_action.dart';
import 'package:class_todo_list/error_handler.dart';
import 'package:class_todo_list/logic/exam_score_review_notifier.dart';
import 'package:class_todo_list/logic/examlist_notifier.dart';
import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/page/photo_preview_page.dart';
import 'package:class_todo_list/page/setting_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:file_picker/file_picker.dart';

class HomeScoreBody extends ConsumerStatefulWidget {
  const HomeScoreBody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScoreBodyState();
}

class _HomeScoreBodyState extends ConsumerState<HomeScoreBody> with TickerProviderStateMixin {
  bool _agreeToTerms = false;
  final String _agreeToScoreTermsKey = 'agreeToScoreTermsV1.1';

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }

  SharedPreferences get _sharedPreferences => ref.read(sharedPreferencesProvider).requireValue;

  void _loadSharedPreferences() {
    setState(() {
      _agreeToTerms = _sharedPreferences.getBool(_agreeToScoreTermsKey) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> usersData = ref.watch(usersProvider);
    ExamlistState examlistState = ref.watch(examlistProvider);
    User? userData = ref.watch(authProvider).user;
    if (ref.watch(examActivateProvider)) {
      if (_agreeToTerms) {
        return LoadingView(
            loading: examlistState.loading,
            child: Builder(builder: (context) {
              final box = context.findRenderObject() as RenderBox?;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: examlistState.examItems.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, idx) {
                        ExamData examData = examlistState.examItems[idx];
                        return Card(
                          clipBehavior: Clip.hardEdge,
                          margin: examlistState.examItems.length == 1
                              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                              : idx == 0
                                  ? const EdgeInsets.fromLTRB(20, 10, 20, 0)
                                  : idx == examlistState.examItems.length - 1
                                      ? const EdgeInsets.fromLTRB(20, 0, 20, 10)
                                      : const EdgeInsets.symmetric(horizontal: 20),
                          shape: examlistState.examItems.length == 1
                              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                              : idx == 0
                                  ? const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25)))
                                  : idx == examlistState.examItems.length - 1
                                      ? const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(25),
                                              bottomRight: Radius.circular(25)))
                                      : const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero),
                          child: Builder(builder: (context) {
                            return ListTile(
                              leading: Builder(builder: (context) {
                                switch (examData.examStatus) {
                                  case ExamStatus.ongoing:
                                    return Blink(
                                        vsync: this,
                                        child: const Icon(Icons.circle, color: Colors.blue));
                                  case ExamStatus.processing:
                                    if (examData.userId == userData?.uid) {
                                      return const Icon(Icons.watch_later_outlined,
                                          color: Colors.blue);
                                    } else {
                                      return const Icon(Icons.watch_later_outlined,
                                          color: Colors.orangeAccent);
                                    }
                                  case ExamStatus.done:
                                    return const Icon(Icons.check_circle_outline,
                                        color: Colors.green);
                                  case ExamStatus.archived:
                                    return const Icon(Icons.archive_outlined, color: Colors.grey);
                                }
                              }),
                              title: Text(
                                examData.name,
                              ),
                              subtitle: Wrap(
                                spacing: 5,
                                children: [
                                  Text(usersData[examData.userId] ?? '未知使用者'),
                                  Text(
                                      '上傳截止時間：${DateFormat('yyyy/MM/dd EE HH:mm', 'zh-TW').format(examData.startTime.add(const Duration(hours: 3)))}'),
                                ],
                              ),
                              onLongPress: examData.examStatus == ExamStatus.ongoing
                                  ? () {
                                      final box = context.findRenderObject() as RenderBox?;
                                      Share.share(
                                        '請在${DateFormat('MM/dd HH:mm', 'zh-TW').format(examData.startTime.add(const Duration(hours: 3)))}前提交${examData.name}成績：\nhttps://app.classtodo.ycydev.org/exam/${examData.examId}',
                                        sharePositionOrigin:
                                            box!.localToGlobal(Offset.zero) & box.size,
                                      );
                                    }
                                  : null,
                              onTap: examData.examStatus == ExamStatus.processing &&
                                      examData.userId == userData?.uid
                                  ? () {
                                      ref
                                          .read(examScoreReviewProvider.notifier)
                                          .getScoreData(examData.examId);
                                      if (context.mounted) {
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) {
                                            return ScoreCheckPage(examData.examId, examData.name);
                                          },
                                        ));
                                      }
                                    }
                                  : () async {
                                      while (ref.read(selfNumberProvider).isEmpty ||
                                          int.tryParse(ref.read(selfNumberProvider)) == null ||
                                          int.parse(ref.read(selfNumberProvider)) < 1) {
                                        if (context.mounted) {
                                          bool? result = await showAdaptiveDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog.adaptive(
                                                title: Text('請先設定座號'),
                                                content: Text('您的座號無效 '),
                                                actions: [
                                                  AdaptiveAction(
                                                      onPressed: () =>
                                                          Navigator.of(context).pop(false),
                                                      child: Text('取消')),
                                                  AdaptiveAction(
                                                      onPressed: () =>
                                                          Navigator.of(context).pop(true),
                                                      child: Text('前往設定')),
                                                ],
                                              );
                                            },
                                          );
                                          if (result == true) {
                                            if (context.mounted) {
                                              await Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context) => SettingPage(),
                                              ));
                                            }
                                          } else {
                                            return;
                                          }
                                        }
                                      }
                                      ref.read(examScoreDataProvider.notifier).getScoreData(
                                          examData.examId,
                                          examData.userId,
                                          examData.examStatus != ExamStatus.ongoing);
                                      if (context.mounted) {
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) {
                                            return SubmitScorePage(examData.examId);
                                          },
                                        ));
                                      }
                                    },
                            );
                          }),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => const Divider(
                        height: 0,
                        indent: 70,
                        endIndent: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Card(
                        clipBehavior: Clip.hardEdge,
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        child: Column(
                          children: [
                            ListTile(
                              minLeadingWidth: 30,
                              leading: const Icon(Icons.add),
                              title: const Text('新增考試'),
                              onTap: () {
                                showAdaptiveDialog<String?>(
                                  context: context,
                                  builder: (context) => const NewExamForm(),
                                ).then((String? name) {
                                  if (name is String) {
                                    toastification.show(
                                      type: ToastificationType.info,
                                      style: ToastificationStyle.flatColored,
                                      title: const Text("考試新增中"),
                                      alignment: Alignment.topCenter,
                                      showProgressBar: false,
                                      autoCloseDuration: const Duration(milliseconds: 1500),
                                    );
                                    ref.read(examlistProvider.notifier).newExam(name).then((id) {
                                      if (id != null) {
                                        Share.share(
                                            '請在3個小時內提交$name成績：\nhttps://app.classtodo.ycydev.org/exam/$id',
                                            sharePositionOrigin: Rect.fromLTRB(
                                                box!.size.width - 100, 0, box.size.width, 50));
                                      }
                                    });
                                  }
                                });
                              },
                              iconColor: Colors.blue,
                              textColor: Colors.blue,
                            ),
                          ],
                        )),
                  ],
                ),
              );
            }));
      } else {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '請閱讀並同意考試分數登記使用條款，以啟用此功能。',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (BuildContext context) {
                                return const ScoreTermsDialog();
                              }))
                          .then((result) {
                        if (result == true) {
                          setState(() {
                            _agreeToTerms = true;
                          });
                          _sharedPreferences.setBool(_agreeToScoreTermsKey, true);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      '檢視條款',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 50,
                color: Colors.amber,
              ),
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: '您的班級尚未啟用此功能，若您想試用此功能，請透過電子郵件聯絡我們: ',
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'support@classtodo.ycydev.org',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => openUrl('mailto:support@classtodo.ycydev.org')),
                    const TextSpan(text: '。'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class ScoreTermsDialog extends ConsumerStatefulWidget {
  const ScoreTermsDialog({super.key});

  @override
  ConsumerState<ScoreTermsDialog> createState() => _ScoreTermsDialogState();
}

class _ScoreTermsDialogState extends ConsumerState<ScoreTermsDialog> {
  late ScrollController _scrollController;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    Future.delayed(Duration.zero).then((_) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95) {
        setState(() {
          _isButtonEnabled = true;
        });
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95) {
      setState(() {
        _isButtonEnabled = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('考試分數登記使用條款'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  '''
1. 分數不可修改
考試分數經確認後上傳，不得要求進行任何修改。

2. 登記時間限制
請於登記人開啟登記功能後 3 小時內完成分數登記，逾時將無法使用此功能進行登記。補登記的相關事宜，請聯繫登記人。

3. 分數檢視與確認
登記人可於登記功能開放後的 3 小時至 24 小時內檢視登記內容並確認成績。在確認期間，每份考卷可檢視無限次。然而，由於手動操作或其他因素導致應用程式關閉，將無法再次檢視，包括但不限於切換至其他應用程式或重新啟動裝置。

4. 考卷上傳規範
考卷上傳時，系統將自動縮小文件以利傳輸。請確保上傳的掃描檔案清楚呈現「個人識別資料」與「成績」，且考卷邊框完整、無修改痕跡。此外，請確保上傳分數與手動輸入分數一致（四捨五入至整數）。

5. 分數檢查責任
登記人可檢查考卷內容與手動填寫的「個人識別資料」和「成績」是否一致。若有差異，登記人需自行判斷是否進行後補登記。本系統不負責處理非系統明顯錯誤的分數問題。

6. 數據用途同意
本人同意將考卷上傳至本系統，並允許開發團隊將相關數據用於改進系統功能。

7. 條款變更權利
開發團隊保留隨時變更或廢止本條款的權利。

8. 聯絡方式
若有任何問題，請透過電子郵件聯繫我們：support@classtodo.ycydev.org

請確保已閱讀並同意本條款後再進行考試分數登記。
                  ''',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isButtonEnabled
                ? () {
                    Navigator.of(context).pop(true);
                  }
                : null,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: const BeveledRectangleBorder()),
            child: const SafeArea(
              child: Text(
                '同意條款',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewExamForm extends ConsumerStatefulWidget {
  const NewExamForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewExamFormState();
}

class _NewExamFormState extends ConsumerState<NewExamForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      // contentPadding: const EdgeInsets.all(20),
      title: Text('新增考試'),
      content: SizedBox(
        // width: 300,
        // height: 100,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: SizedBox(
              // height: ,
              child: TextFormField(
                selectionHeightStyle: BoxHeightStyle.strut,
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: '考試名稱',
                    hintStyle: TextStyle(height: 2),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 2) {
                    return '請輸入考試名稱';
                  }
                  return null;
                },
                onChanged: (value) {
                  _formKey.currentState!.validate();
                },
              ),
            ),
          ),
        ),
      ),
      actions: [
        AdaptiveAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            '取消',
            style: TextStyle(fontSize: 18),
          ),
        ),
        AdaptiveAction(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_controller.text);
            } else {
              HapticFeedback.heavyImpact();
            }
          },
          child: const Text(
            '新增',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}

class Blink extends StatefulWidget {
  const Blink({required this.child, required this.vsync, super.key});
  final Widget child;
  final TickerProvider vsync;

  @override
  State<Blink> createState() => _BlinkState();
}

class _BlinkState extends State<Blink> {
  late AnimationController _animationController;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: widget.vsync,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });
    _animationController.repeat(reverse: true);
    _fade = Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _scale = Tween(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.bounceInOut));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(opacity: _fade, child: widget.child),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class SubmitScorePage extends StatelessWidget {
  const SubmitScorePage(this.examid, {super.key});
  final String examid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('上傳考試分數'),
      ),
      body: SubmitScoreBody(examid),
    );
  }
}

class SubmitScoreBody extends ConsumerStatefulWidget {
  const SubmitScoreBody(this.examid, {super.key});
  final String examid;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SubmitScoreBodyState();
}

class _SubmitScoreBodyState extends ConsumerState<SubmitScoreBody> {
  bool _isAgree = false;
  bool _showCameraButton = false;
  final TextEditingController _scoreController = TextEditingController();
  Uint8List _imageByte = Uint8List.fromList([]);

  bool listEquals<E>(List<E> list1, List<E> list2) {
    if (identical(list1, list2)) {
      return true;
    }

    if (list1.length != list2.length) {
      return false;
    }

    for (var i = 0; i < list1.length; i += 1) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }

  /// Compares two [Uint8List]s by comparing 8 bytes at a time.
  bool memEquals(Uint8List bytes1, Uint8List bytes2) {
    if (identical(bytes1, bytes2)) {
      return true;
    }

    if (bytes1.lengthInBytes != bytes2.lengthInBytes) {
      return false;
    }

    // Treat the original byte lists as lists of 8-byte words.
    var numWords = bytes1.lengthInBytes ~/ 8;
    var words1 = bytes1.buffer.asUint64List(0, numWords);
    var words2 = bytes2.buffer.asUint64List(0, numWords);

    for (var i = 0; i < words1.length; i += 1) {
      if (words1[i] != words2[i]) {
        return false;
      }
    }

    // Compare any remaining bytes.
    for (var i = words1.lengthInBytes; i < bytes1.lengthInBytes; i += 1) {
      if (bytes1[i] != bytes2[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  void initState() {
    _scoreController.text = ref.read(examScoreDataProvider).score;
    if (ref.read(examScoreDataProvider).imagePath != null) {
      _imageByte = File(ref.read(examScoreDataProvider).imagePath!).readAsBytesSync();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(examScoreDataProvider, (prev, next) {
      if (prev?.score != next.score && next.score != _scoreController.text) {
        _scoreController.text = next.score;
      }
      if (!memEquals(_imageByte, File(next.imagePath!).readAsBytesSync())) {
        setState(() {
          _imageByte = File(next.imagePath!).readAsBytesSync();
        });
      }
    });
    final state = ref.watch(examScoreDataProvider);
    return LoadingView(
      loading: state.loading && state.uploadProgress == null,
      child: Builder(builder: (context) {
        if (state.loading && state.uploadProgress != null) {
          return UploadingView(state.uploadProgress!);
        } else {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 20,
                  children: [
                    TextField(
                      autofocus: false,
                      selectionHeightStyle: BoxHeightStyle.strut,
                      controller: _scoreController,
                      decoration: const InputDecoration(
                        labelText: '分數',
                        hintText: '請輸入你的分數 (0~100)',
                        hintStyle: TextStyle(height: 2),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: state.readOnly,
                      onChanged: (value) {
                        ref.read(examScoreDataProvider.notifier).editScore(value);
                      },
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }, // auto close keyboard
                    ),
                    Builder(builder: (context) {
                      if (state.imagePath != null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Center(
                                child: Image.memory(
                                  _imageByte,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.error_outline,
                                      size: 200,
                                      color: Colors.red,
                                    );
                                  },
                                ),
                              ),
                              IconButton.filled(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStateColor.resolveWith(
                                          (_) => Colors.grey.withAlpha(100))),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PreviewPhoto(
                                                imageProvider: FileImage(File(state.imagePath!)))));
                                  },
                                  icon: Icon(Icons.zoom_in)),
                            ],
                          ),
                        );
                      } else {
                        return const Icon(
                          Icons.photo,
                          size: 300,
                          color: Colors.grey,
                        );
                      }
                    }),
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (details.delta.dx > 10) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _showCameraButton = false;
                          });
                        } else if (details.delta.dx < -10) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _showCameraButton = true;
                          });
                        }
                      },
                      child: Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: state.readOnly
                                  ? null
                                  : () async {
                                      try {
                                        List<String>? scanData =
                                            await CunningDocumentScanner.getPictures(noOfPages: 1);
                                        if (scanData == null) {
                                          return;
                                        }
                                        var file = File(scanData[0]);
                                        Uint8List result =
                                            await FlutterImageCompress.compressWithList(
                                                file.readAsBytesSync(),
                                                format: CompressFormat.jpeg,
                                                minHeight: 960,
                                                minWidth: 540,
                                                quality: 70);
                                        final folder = await getApplicationDocumentsDirectory();
                                        final path = '${folder.path}/${state.examId}.jpg';
                                        await File(path).writeAsBytes(result);
                                        ref.read(examScoreDataProvider.notifier).editImage(path);
                                        imageCache.clear();
                                        imageCache.clearLiveImages();
                                      } catch (e) {
                                        ErrorHelper.handleError(e);
                                      }
                                    },
                              icon: const Icon(Icons.scanner, size: 25),
                              label: const Text('掃描考卷'),
                            ),
                          ),
                          if (_showCameraButton)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: state.readOnly
                                  ? null
                                  : () async {
                                      try {
                                        MediaCapture? scanData =
                                            await Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => Camera(),
                                        ));
                                        if (scanData == null) {
                                          return;
                                        }
                                        var file = File(scanData.captureRequest.path!);
                                        Uint8List result =
                                            await FlutterImageCompress.compressWithList(
                                                file.readAsBytesSync(),
                                                format: CompressFormat.jpeg,
                                                minHeight: 960,
                                                minWidth: 540,
                                                quality: 70);
                                        final folder = await getApplicationDocumentsDirectory();
                                        final path = '${folder.path}/${state.examId}.jpg';
                                        await File(path).writeAsBytes(result);
                                        ref.read(examScoreDataProvider.notifier).editImage(path);
                                        setState(() {});
                                      } catch (e) {
                                        ErrorHelper.handleError(e);
                                      }
                                    },
                              child: const Icon(Icons.camera_alt, size: 25),
                            ),
                        ],
                      ),
                    ),
                    CheckboxListTile(
                      value: _isAgree || state.readOnly,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _isAgree = v ?? false;
                        });
                      },
                      title: const Text('我已確認考卷圖片清晰且內容無誤。'),
                    ),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: state.readOnly
                            ? null
                            : () {
                                if (!ref.read(examScoreDataProvider.notifier).precheck()) {
                                  HapticFeedback.mediumImpact();
                                  return;
                                }
                                if (!_isAgree) {
                                  toastification.show(
                                    type: ToastificationType.info,
                                    style: ToastificationStyle.flatColored,
                                    title: const Text('請確認考卷'),
                                    description: const Text('請在確認考卷後勾選。'),
                                    autoCloseDuration: const Duration(seconds: 3),
                                    showProgressBar: false,
                                  );
                                  HapticFeedback.mediumImpact();
                                  return;
                                }
                                HapticFeedback.lightImpact();
                                showAdaptiveDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog.adaptive(
                                        title: const Text('送出成績'),
                                        content: const Text('是否要送出成績，送出後不能修改已送出的內容。請確認分數正確且圖片清晰。'),
                                        actions: [
                                          AdaptiveAction(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: const Text('取消'),
                                          ),
                                          AdaptiveAction(
                                            onPressed: () async {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text('送出成績'),
                                          ),
                                        ],
                                      );
                                    }).then((confirm) async {
                                  if (confirm == true) {
                                    final result = await ref
                                        .read(examScoreDataProvider.notifier)
                                        .submitScore();
                                    if (result && context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                });
                              },
                        style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(
                          Icons.send,
                          size: 25,
                          color: Colors.white,
                        ),
                        label: Text(state.readOnly
                            ? state.score.isEmpty
                                ? '成績逾期未送出'
                                : '成績已於${DateFormat('MM/dd HH:mm:ss', 'zh-TW').format(state.submittedTime ?? DateTime.now())}送出'
                            : '送出成績'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }),
    );
  }
}

class Camera extends ConsumerWidget {
  const Camera({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        enablePhysicalButton: true,
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          aspectRatio: CameraAspectRatios.ratio_16_9,
        ),
        saveConfig: SaveConfig.photo(exifPreferences: ExifPreferences(saveGPSLocation: false)),
        onMediaCaptureEvent: (mediaCapture) {
          if (mediaCapture.status == MediaCaptureStatus.success) {
            Navigator.of(context).pop(mediaCapture);
          }
        },
        topActionsBuilder: (state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(builder: (context) {
                  final theme = AwesomeThemeProvider.of(context).theme;
                  return theme.buttonTheme.buttonBuilder(
                    AwesomeCircleWidget.icon(
                      icon: Icons.arrow_back,
                      theme: theme,
                    ),
                    () => Navigator.of(context).pop(),
                  );
                }),
                AwesomeFlashButton(state: state),
              ],
            ),
          );
        },
        middleContentBuilder: (state) => SizedBox.shrink(),
        bottomActionsBuilder: (state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Center(
              child: AwesomeCaptureButton(
                state: state,
              ),
            ),
          );
        },
      ),
    );
  }
}

class UploadingView extends ConsumerWidget {
  const UploadingView(this.value, {super.key});
  final double value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 10,
        children: [
          Expanded(
            flex: 1,
            child: SizedBox.shrink(),
          ),
          Icon(
            Icons.cloud_upload_rounded,
            size: 200,
            color: Colors.blue,
          ),
          LinearProgressIndicator(
            color: Colors.blue,
            value: value,
            minHeight: 20,
            stopIndicatorRadius: 25,
            borderRadius: BorderRadius.circular(15),
          ),
          Text(
            '已上傳${(value * 100).toStringAsFixed(1)}%，請耐心等待',
            style: TextStyle(fontSize: 20),
          ),
          Expanded(
            flex: 2,
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class ScoreCheckPage extends ConsumerWidget {
  const ScoreCheckPage(this.examId, this.examName, {super.key});
  final String examId;
  final String examName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examScoreReviewProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '登記$examName分數  (${state.reviewed.length}/${state.toReview.length + state.reviewed.length})'),
      ),
      body: ScoreCheckBody(examId, examName),
    );
  }
}

class ScoreCheckBody extends ConsumerStatefulWidget {
  const ScoreCheckBody(this.examId, this.examName, {super.key});
  final String examId;
  final String examName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScoreCheckBodyState();
}

class _ScoreCheckBodyState extends ConsumerState<ScoreCheckBody> {
  bool loading = true;
  File? result;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examScoreReviewProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog.adaptive(
                title: const Text('放棄檢查'),
                content: const Text('你確定要放棄檢查成績嗎?'),
                actions: [
                  AdaptiveAction(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    danger: true,
                    child: const Text('返回'),
                  ),
                  AdaptiveAction(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('繼續審查'),
                  )
                ],
              );
            }).then((close) {
          if (close == true && context.mounted) {
            Navigator.of(context).pop();
          }
        });
      },
      child: LoadingView(
        loading: state.loading,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SafeArea(
            child: Builder(builder: (context) {
              if (state.toReview.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 150,
                        color: Colors.green,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('已檢查所有分數，請確保在關閉頁面前儲存檔案', style: TextStyle(fontSize: 18)),
                      ),
                      ElevatedButton.icon(
                        onPressed: result == null
                            ? null
                            : () async {
                                HapticFeedback.lightImpact();
                                String downloadDir = (await getDownloadsDirectory())!.path;
                                String? output = await FilePicker.platform.saveFile(
                                    dialogTitle: '請選擇儲存成績的位置:',
                                    fileName: '${widget.examName}成績.xlsx',
                                    initialDirectory: downloadDir,
                                    allowedExtensions: ['xlsx'],
                                    type: FileType.custom,
                                    bytes: result?.readAsBytesSync());
                                if (output != null) {
                                  toastification.show(
                                    type: ToastificationType.success,
                                    style: ToastificationStyle.flatColored,
                                    title: Text('匯出成功'),
                                    autoCloseDuration: const Duration(seconds: 5),
                                    showProgressBar: false,
                                  );
                                  ref.read(examScoreReviewProvider.notifier).done();
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                        icon: Icon(
                          Icons.download,
                          size: 20,
                        ),
                        label: Text(result == null ? '處理中' : '存檔'),
                        style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(fontSize: 20),
                            iconColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                      // Builder(builder: (context) {
                      //   return ElevatedButton.icon(
                      //     onPressed: () async {
                      //       final box = context.findRenderObject() as RenderBox?;
                      //       List<List<dynamic>> listData = [
                      //         ['Student ID', 'Score']
                      //       ];
                      //       for (var score in scores) {
                      //         listData
                      //             .add([score.studentId, score.approved ? score.score : '-']);
                      //       }
                      //       Excel excel = Excel.createExcel();
                      //       excel.rename('Sheet1', 'Exam Score ${widget.examName}');
                      //       Sheet sheet = excel['Exam Score ${widget.examName}'];
                      //       sheet.appendRow(
                      //           [TextCellValue('Student ID'), TextCellValue('Score')]);
                      //       for (var score in scores) {
                      //         sheet.appendRow([
                      //           TextCellValue(score.studentId),
                      //           if (score.approved)
                      //             IntCellValue(score.score)
                      //           else
                      //             TextCellValue('-')
                      //         ]);
                      //       }
                      //       // String csv =
                      //       //     ListToCsvConverter().convert(listData);
                      //       //csv file
                      //       var fileBytes = excel.save();
                      //       String dir = (await getApplicationDocumentsDirectory()).path;
                      //       if (fileBytes == null) {
                      //         toastification.show(
                      //           type: ToastificationType.error,
                      //           style: ToastificationStyle.flatColored,
                      //           title: Text('An error occurred'),
                      //           description:
                      //               Text('An error occurred while exporting the file'),
                      //           autoCloseDuration: const Duration(seconds: 5),
                      //           showProgressBar: false,
                      //         );
                      //         return;
                      //       }
                      //       File xslxFile = File('$dir/exam score ${widget.examName}.xlsx');
                      //       xslxFile.createSync(recursive: true);
                      //       await xslxFile.writeAsBytes(fileBytes);
                      //       ShareResult result = await Share.shareXFiles(
                      //         [
                      //           XFile(xslxFile.path, name: 'exam_score_${widget.examId}.xlsx')
                      //         ],
                      //         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                      //       );
                      //       await xslxFile.delete();
                      //       if (result.status == ShareResultStatus.success) {
                      //         toastification.show(
                      //           type: ToastificationType.success,
                      //           style: ToastificationStyle.flatColored,
                      //           title: Text('Share successfully'),
                      //           autoCloseDuration: const Duration(seconds: 5),
                      //           showProgressBar: false,
                      //         );
                      //         if (context.mounted) {
                      //           Navigator.pop(context);
                      //         }
                      //       }
                      //     },
                      //     icon: Icon(
                      //       Icons.share,
                      //       size: 20,
                      //     ),
                      //     label: Text('Share File'),
                      //     style: ElevatedButton.styleFrom(
                      //         textStyle: TextStyle(fontSize: 20),
                      //         shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10))),
                      //   );
                      // }),
                    ],
                  ),
                );
              }
              ScoreDataReview scoreDataReview = state.toReview.last;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Expanded(child: SizedBox.shrink()),
                  Row(
                    spacing: 15,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(scoreDataReview.student, style: TextStyle(fontSize: 25)),
                      Icon(Icons.arrow_forward),
                      Text('${scoreDataReview.score}分', style: TextStyle(fontSize: 30)),
                    ],
                  ),
                  Builder(builder: (context) {
                    if (scoreDataReview.image == null) {
                      return Icon(
                        Icons.photo,
                        size: 200,
                        color: Colors.grey,
                      );
                    }
                    return InkWell(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(scoreDataReview.image!),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PreviewPhoto(
                                      imageProvider: FileImage(scoreDataReview.image!))));
                        });
                  }),
                  Expanded(child: SizedBox.shrink()),
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 45,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            ref.read(examScoreReviewProvider.notifier).review(false);
                            if (ref.read(examScoreReviewProvider).toReview.isEmpty) {
                              ref.read(examScoreReviewProvider.notifier).getResult().then((file) {
                                setState(() {
                                  result = file;
                                });
                              });
                            }
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ), //cross
                          label: Text('拒絕'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 45,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            ref.read(examScoreReviewProvider.notifier).review(true);
                            if (ref.read(examScoreReviewProvider).toReview.isEmpty) {
                              ref.read(examScoreReviewProvider.notifier).getResult().then((file) {
                                setState(() {
                                  result = file;
                                });
                              });
                            }
                          },
                          icon: Icon(
                            Icons.check,
                            color: Colors.white,
                          ), //check
                          label: Text('接受'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
