import 'dart:io';
import 'dart:ui';

import 'package:class_todo_list/logic/examlist_notifier.dart';
import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/page/photo_preview_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class HomeScoreBody extends ConsumerStatefulWidget {
  const HomeScoreBody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScoreBodyState();
}

class _HomeScoreBodyState extends ConsumerState<HomeScoreBody>
    with TickerProviderStateMixin {
  bool _agreeToTerms = false;
  late SharedPreferences pref;
  final String _agreeToScoreTermsKey = 'agreeToScoreTermsV1';

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }

  Future<void> _loadSharedPreferences() async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      _agreeToTerms = pref.getBool(_agreeToScoreTermsKey) ?? false;
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
                              ? const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10)
                              : idx == 0
                                  ? const EdgeInsets.fromLTRB(20, 10, 20, 0)
                                  : idx == examlistState.examItems.length - 1
                                      ? const EdgeInsets.fromLTRB(20, 0, 20, 10)
                                      : const EdgeInsets.symmetric(
                                          horizontal: 20),
                          shape: examlistState.examItems.length == 1
                              ? RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25))
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
                          child: ListTile(
                            leading: Builder(builder: (context) {
                              switch (examData.examStatus) {
                                case ExamStatus.ongoing:
                                  return Blink(
                                      vsync: this,
                                      child: const Icon(Icons.circle,
                                          color: Colors.blue));
                                case ExamStatus.processing:
                                  if (examData.userId == userData?.uid) {
                                    return const Icon(
                                        Icons.watch_later_outlined,
                                        color: Colors.blue);
                                  } else {
                                    return const Icon(
                                        Icons.watch_later_outlined,
                                        color: Colors.orangeAccent);
                                  }
                                case ExamStatus.done:
                                  return const Icon(Icons.check_circle_outline,
                                      color: Colors.green);
                                case ExamStatus.archived:
                                  return const Icon(Icons.archive_outlined,
                                      color: Colors.grey);
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
                                    '上傳截止時間：${DateFormat('yyyy/MM/dd EE HH:mm', 'zh-TW').format(examData.startTime.add(const Duration(hours: 2)))}'),
                              ],
                            ),
                            onTap: examData.examStatus == ExamStatus.ongoing
                                ? () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) {
                                        return SubmitScorePage(examData.examId);
                                      },
                                    ));
                                  }
                                : examData.examStatus ==
                                            ExamStatus.processing &&
                                        examData.userId == userData?.uid
                                    ? () {}
                                    : null,
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
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
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        child: Column(
                          children: [
                            ListTile(
                              minLeadingWidth: 30,
                              leading: const Icon(Icons.add),
                              title: const Text('新增考試'),
                              onTap: () {
                                showDialog<String?>(
                                  context: context,
                                  builder: (context) => const NewExamForm(),
                                ).then((String? name) {
                                  if (name is String) {
                                    ref
                                        .read(examlistProvider.notifier)
                                        .newExam(name);
                                    toastification.show(
                                      type: ToastificationType.info,
                                      style: ToastificationStyle.flatColored,
                                      title: const Text("考試新增中"),
                                      alignment: Alignment.topCenter,
                                      showProgressBar: false,
                                      autoCloseDuration:
                                          const Duration(milliseconds: 1500),
                                    );
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
                ElevatedButton(
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
                        pref.setBool(_agreeToScoreTermsKey, true);
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
                          ..onTap = () =>
                              openUrl('mailto:support@classtodo.ycydev.org')),
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
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.95) {
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
請於登記人開啟登記功能後 2 小時內完成分數登記，逾時將無法使用此功能進行登記。補登記的相關事宜，請聯繫登記人。

3. 分數檢視與確認
登記人可於登記功能開放後的 2 小時至 24 小時內檢視登記內容並確認成績。在確認期間，每份考卷可檢視無限次。然而，由於手動操作或其他因素導致應用程式關閉，將無法再次檢視，包括但不限於切換至其他應用程式或重新啟動裝置。

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
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('新增考試'),
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close))
        ],
      ),
      children: [
        SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  selectionHeightStyle: BoxHeightStyle.strut,
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '請輸入完整，如：英文U1單字',
                    hintStyle: TextStyle(height: 2),
                    labelText: '考試名稱',
                  ),
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              HapticFeedback.lightImpact();
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
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _scale = Tween(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.bounceInOut));
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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SubmitScoreBodyState();
}

class _SubmitScoreBodyState extends ConsumerState<SubmitScoreBody> {
  Uint8List _imageBytes = Uint8List(0);
  bool _isAgree = false;
  final TextEditingController _scoreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                hintText: '請輸入你的分數 (1-100)',
                hintStyle: TextStyle(height: 2),
              ),
              keyboardType: TextInputType.number,
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              }, // auto close keyboard
            ),
            Builder(builder: (context) {
              if (_imageBytes.isNotEmpty) {
                return InkWell(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(_imageBytes),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PreviewPhoto(
                                  imageProvider: MemoryImage(_imageBytes))));
                    });
              } else {
                return const Icon(
                  Icons.photo,
                  size: 200,
                  color: Colors.grey,
                );
              }
            }),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
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
                  setState(() {
                    _imageBytes = result;
                  });
                } catch (e) {
                  toastification.show(
                    type: ToastificationType.error,
                    style: ToastificationStyle.flatColored,
                    title: const Text('發生錯誤'),
                    description: Text(e.toString()),
                    autoCloseDuration: const Duration(seconds: 3),
                    showProgressBar: false,
                  );
                  if (kDebugMode) {
                    print(e);
                  }
                }
              },
              icon: const Icon(Icons.scanner, size: 25),
              label: const Text('掃描考卷'),
            ),
            CheckboxListTile(
              value: _isAgree,
              onChanged: (v) {
                if (v == null) {
                  return;
                }
                setState(() {
                  _isAgree = v;
                });
              },
              title: const Text('我已確認考卷圖片清晰且內容無誤，若考卷無法辨識，後果自負。'),
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_scoreController.text.isEmpty) {
                    toastification.show(
                      type: ToastificationType.info,
                      style: ToastificationStyle.flatColored,
                      title: const Text('未填寫成績'),
                      description: const Text('請輸入正確成績。'),
                      autoCloseDuration: const Duration(seconds: 3),
                      showProgressBar: false,
                    );
                    return;
                  }
                  if (int.tryParse(_scoreController.text) == null) {
                    toastification.show(
                      type: ToastificationType.info,
                      style: ToastificationStyle.flatColored,
                      title: const Text('成績內容有誤'),
                      description: const Text('請輸入正確成績。'),
                      autoCloseDuration: const Duration(seconds: 3),
                      showProgressBar: false,
                    );
                    return;
                  }
                  if (_imageBytes.isEmpty) {
                    toastification.show(
                      type: ToastificationType.info,
                      style: ToastificationStyle.flatColored,
                      title: const Text('尚未掃描考卷'),
                      description: const Text('請先掃描考卷後。'),
                      autoCloseDuration: const Duration(seconds: 3),
                      showProgressBar: false,
                    );
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
                    return;
                  }
                  if (int.parse(_scoreController.text) < 0 ||
                      int.parse(_scoreController.text) > 100) {
                    toastification.show(
                      type: ToastificationType.info,
                      style: ToastificationStyle.flatColored,
                      title: const Text('成績內容有誤'),
                      description: const Text('請輸入正確成績。'),
                      autoCloseDuration: const Duration(seconds: 3),
                      showProgressBar: false,
                    );
                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (contextIn) {
                        return AlertDialog(
                          title: const Text('送出成績'),
                          content: const Text('是否要送出成績，送出後不能修改已送出的內容。'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(contextIn);
                              },
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(contextIn);
                                // showLoadingDialog(context, 'Submitting');
                                // final db = FirebaseFirestore.instance;
                                // db.collection('/test/examscore/examData').add({
                                //   'examid': examid,
                                //   'studentid': _studentIdController.text,
                                //   'score': int.parse(_scoreController.text),
                                //   'timestamp': FieldValue.serverTimestamp(),
                                // }).then((value) async {
                                //   final storage = FirebaseStorage.instance;
                                //   final ref = storage.ref(
                                //       '/test/examscore/$examid/${value.id}.jpg');
                                //   await ref.putData(
                                //       _imageBytes,
                                //       SettableMetadata(
                                //         contentType: "image/jpeg",
                                //       ));
                                //   // Navigator.pop(context);
                                //   if (context.mounted) {
                                //     hideLoadingDialog(context);
                                //   }
                                //   toastification.show(
                                //     type: ToastificationType.success,
                                //     style: ToastificationStyle.flatColored,
                                //     title: const Text('Submitted successfully'),
                                //     description: const Text('Score submitted'),
                                //     autoCloseDuration:
                                //         const Duration(seconds: 5),
                                //     showProgressBar: false,
                                //   );
                                //   if (context.mounted) {
                                //     Navigator.pop(context);
                                //   }
                                // }).catchError((e) {
                                //   if (kDebugMode) {
                                //     print(e);
                                //   }
                                //   if (mounted) {
                                //     // Navigator.pop(context);
                                //     toastification.show(
                                //       type: ToastificationType.error,
                                //       style: ToastificationStyle.flatColored,
                                //       title: const Text('An error occurred'),
                                //       description: Text('$e'),
                                //       autoCloseDuration:
                                //           const Duration(seconds: 5),
                                //       showProgressBar: false,
                                //     );
                                //   }
                                // });
                              },
                              child: const Text('送出成績'),
                            ),
                          ],
                        );
                      });
                },
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                iconAlignment: IconAlignment.end,
                icon: const Icon(
                  Icons.send,
                  size: 25,
                  color: Colors.white,
                ),
                label: const Text('送出成績'),
              ),
            ),
            const Text('一旦提交分數後，將無法更改。如果提交的分數不正確或圖片不清晰，分數將被拒收。您有責任提交正確的分數。'),
          ],
        ),
      ),
    );
  }
}
