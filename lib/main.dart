import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'parts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'استغفار ۷۰ بند',
      theme: ThemeData(
        primaryColor: Colors.teal,
        fontFamily: 'Vazir',
      ),
      home: MyHomePage(title: 'استغفار ۷۰ بند'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("fa", "IR"),
      ],
      locale: Locale("fa", "IR"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var scrollController = ScrollController();
  var _showTranslation = false;

  @override
  void initState() {
    loadScrollPosition().then((position) {
      scrollController.animateTo(position,
          duration: Duration(milliseconds: 1000), curve: Curves.ease);
    });
    super.initState();
    loadTranslationState().then((state) {
      setState(() {
        _showTranslation = state;
        saveTranslationState(state);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Image(
                image: AssetImage('assets/esteghfar2.jpg'),
                fit: BoxFit.cover,
              ),
              padding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('درباره استغفار 70 بند'),
              onTap: () {
                showDialog(
                  context: context,
                  child: SimpleDialog(
                    title: Text('استغفار 70 بند امیرالمومنین'),
                    contentPadding: EdgeInsets.all(16),
                    children: <Widget>[
                      Text(
                        about,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      SimpleDialogOption(
                        child: Text(
                          'بسیار خب',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('رسم وفا'),
              onTap: () async {
                await launch(
                    'https://eitaa.com/joinchat/1771110431C5744481c4f');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w100,
          ),
        ),
        actions: [
          Center(
            child: Text(
              'ترجمه',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: _showTranslation,
            onChanged: (state) => setState(() {
              _showTranslation = state;
              saveTranslationState(state);
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          scrollController.animateTo(0,
              duration: Duration(milliseconds: 1000), curve: Curves.ease),
        },
        child: Icon(Icons.arrow_upward),
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (ScrollEndNotification scrollInfo) {
              saveScrollPosition(scrollInfo.metrics.pixels);
              return true;
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              controller: scrollController,
              itemCount: parts.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: SvgPicture.asset('assets/besmele.svg'),
                  );
                }
                return Column(
                  children: <Widget>[
                    Text(
                      _farsiNumber(i),
                      style: TextStyle(
                        fontFamily: 'Uthman',
                        fontSize: 36,
                      ),
                    ),
                    SelectableText(
                      parts[i - 1],
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Uthman',
                        fontSize: 28,
                        color: Color(0xFF382e24),
                      ),
                    ),
                    if (_showTranslation) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        child: SelectableText(
                          translations[i - 1],
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ]
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _farsiNumber(int i) {
    final numbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var farsi = i.toString().split('').reversed.join();
    for (i in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) {
      farsi = farsi.replaceAll(i.toString(), numbers[i]);
    }
    return farsi;
  }

  Future<bool> saveScrollPosition(double position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble('apology.scrollPosition', position);
  }

  Future<double> loadScrollPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('apology.scrollPosition');
  }

  Future saveTranslationState(bool state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('apology.translationState', state);
  }

  Future<bool> loadTranslationState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('apology.translationState') ?? false;
  }
}
