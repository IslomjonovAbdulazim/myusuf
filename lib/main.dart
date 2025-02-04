import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ismingizni kiriting'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ismingiz',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text;
                  if (name.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(name: name),
                      ),
                    );
                  }
                },
                child: const Text('Kirish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String name;

  const HomePage({super.key, required this.name});

  @override
  _HomePageState createState() => _HomePageState();
}class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> newsList = [
    {
      "title": "Toshkentda 29 -30 va 31 yanvar kunlari qor yog'ishi kutilmoqda",
      "image":
      "https://yuz.uz/imageproxy/1200x/https://yuz.uz/file/news/c567a3161d05a6177e9b920c7c77bdf8.jpg",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "2 soat oldin",
      "url": "https://yuz.uz/news/toshkentda-qor-yogishi"
    },
    {
      "title": "Ilon musk telefon ishlab chiqarmoqchi",
      "image":
      "https://miro.medium.com/v2/resize:fit:1148/0*JgLoF5wzbkXvOZnH.jpg",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "3 soat oldin",
      "url": "https://medium.com/elon-musk-telefon"
    },
    {
      "title": "Tik tok endi rostaniga AQSh da yopildi !",
      "image":
      "https://images.theconversation.com/files/582275/original/file-20240315-26-rjm6wo.jpg?ixlib=rb-4.1.0&rect=0%2C287%2C5333%2C2666&q=45&auto=format&w=1356&h=668&fit=crop",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "4 soat oldin",
      "url": "https://theconversation.com/tiktok-yopildi"
    },
    {
      "title": "Qaysi IT sohada ko'proq pul ishlaydi ?",
      "image":
      "https://fsa2-assets.imgix.net/assets/New-blog/computer-ready-for-coding.jpg?auto=compress%2Cformat&crop=focalpoint&domain=fsa2-assets.imgix.net&fit=crop&fp-x=0.5&fp-y=0.5&h=798&ixlib=php-3.3.1&w=1200",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "5 soat oldin",
      "url":
      "https://it-park.uz/uz/itpark/news/qanday-qilib-19-yoshda-oyiga-1000-dan-ko-p-daromad-topish-mumkin-ergashov-lazizbekning-hikoyasi"
    },
    {
      "title": "Maktablarda yana jaket kiyish qaytadimi ?",
      "image":
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCbRVoNs7W5b1riyksXwB8a8f_DqkG3q0VkA&s",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "6 soat oldin",
      "url": "https://uz.wikipedia.org/wiki/Maktab_formasi"
    },
    {
      "title": "Abdukodir Xusanov Manchester cityda !!",
      "image":
      "https://cdn-uz.kursiv.media/wp-content/uploads/2025/01/image-357-edited.png",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "7 soat oldin",
      "url":
      "https://metaratings.by/news/oficialno-zashitnik-abdukodir-khusanov-igrok-manchester-siti-442701/"
    },
  ];

  List<Map<String, dynamic>> filteredNewsList = [];
  Timer? _timer;
  String profileImage =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
  List<String> questions = [];
  List<String> quizResponses = [];

  @override
  void initState() {
    super.initState();
    filteredNewsList = newsList;
    _startTimer();
    _loadProfileImage();
    _loadQuestions();
    _loadQuizResponses();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(hours: 2), (timer) {
      _updateNewsList();
    });
  }

  void _updateNewsList() {
    setState(() {
      newsList.shuffle();
      filteredNewsList = newsList;
    });
  }  void updateReaction(int index, bool isLike) {
    setState(() {
      if (isLike && !filteredNewsList[index]["liked"]) {
        filteredNewsList[index]["liked"] = true;
        filteredNewsList[index]["likes"]++;
        if (filteredNewsList[index]["disliked"]) {
          filteredNewsList[index]["disliked"] = false;
          filteredNewsList[index]["dislikes"]--;
        }
      } else if (!isLike && !filteredNewsList[index]["disliked"]) {
        filteredNewsList[index]["disliked"] = true;
        filteredNewsList[index]["dislikes"]++;
        if (filteredNewsList[index]["liked"]) {
          filteredNewsList[index]["liked"] = false;
          filteredNewsList[index]["likes"]--;
        }
      }
    });
  }

  void filterNews(String query) {
    setState(() {
      filteredNewsList = newsList
          .where((news) =>
          news["title"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void addComment(int index) {
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fikr qo\'shish'),
          content: TextField(
            controller: commentController,
            decoration:
            const InputDecoration(hintText: 'Fikringizni yozing...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Bekor qilish'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  filteredNewsList[index]["comments"]
                      .add(commentController.text);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Qo\'shish'),
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _loadProfileImage() async {
    final response = await http.get(Uri.parse(
        "https://avatars.mds.yandex.net/i?id=9f49556a787aface1e0687b3bc1a381db206b3df-10105725-images-thumbs&n=13"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        profileImage = data[0]['url'];
      });
    } else {
      throw Exception('Profil rasmini yuklab bo\'lmadi');
    }
  }

  Future<void> _loadQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      questions = prefs.getStringList('questions') ?? [];
    });
  }

  Future<void> _saveQuestion(String question) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      questions.add(question);
      prefs.setStringList('questions', questions);
    });
  }

  Future<void> _loadQuizResponses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      quizResponses = prefs.getStringList('quizResponses') ?? [];
    });
  }

  Future<void> _saveQuizResponse(String response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      quizResponses.add(response);
      prefs.setStringList('quizResponses', quizResponses);
    });
  }

  void _showUnderConstructionMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Qurilishda'),
          content: const Text('Bu funksiya hozirda mavjud emas.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }  void _showQuiz() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Viktorina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nimani qo\'shamiz? Keyingi Yangilashlarda'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _saveQuizResponse('Kategoriyalar');
                  Navigator.of(context).pop();
                  _showResponseAccepted();
                },
                child: const Text('Kategoriyalar'),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveQuizResponse('Global odamlarni ko\'rish');
                  Navigator.of(context).pop();
                  _showResponseAccepted();
                },
                child: const Text('Global odamlarni ko\'rish'),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveQuizResponse('O\'yin katalog');
                  Navigator.of(context).pop();
                  _showResponseAccepted();
                },
                child: const Text('O\'yin katalog'),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveQuizResponse('button');
                  Navigator.of(context).pop();
                  _showResponseAccepted();
                },
                child: const Text(
                    'o\'yinlar o\'ynab adminlik serverini ytib olish'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResponseAccepted() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Javob qabul qilindi'),
          content: const Text('Sizning javobingiz qabul qilindi.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showQuizResponses() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Viktorina javoblari'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: quizResponses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(quizResponses[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Yopish'),
            ),
          ],
        );
      },
    );
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60.0,
          // AppBarni kattalashtirish
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          centerTitle: true,
          title: SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Izlash...',
                hintStyle: TextStyle(color: Colors.black),
                border: InputBorder.none,
              ),
              maxLines: 1,
              onChanged: (value) {
                filterNews(value);
              },
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.quiz, color: Colors.black),
              onPressed: () {
                // Viktorina oynasiga o'tish uchun funksiya
                _showQuiz();
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.black, Colors.black],
                ),
              ),
              child: SafeArea(
                child: Column(
                    children: [
                    if (profileImage.isNotEmpty)
                CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(profileImage),
                radius: 90,
              ),
              const SizedBox(height: 10),
              Text(
                widget.name,
                style: const TextStyle(
                    fontSize: 20, // Ism kattaligi
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              if (widget.name == 'MuhammadY2011')
          const Text(
          "Prezident",
          style: TextStyle(
            fontSize: 18,
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.name == 'Admin2' ||
    widget.name == 'admin000aspirine' ||
    widget.name == 'admin1112011' ||
    widget.name == 'admin525252')
    const Text(
      "Admin",
      style: TextStyle(
        fontSize: 18,
        color: Colors.yellow,
        fontWeight: FontWeight.bold,
      ),
    ),
    const Divider(color: Colors.white),
    ListTile(
    leading: const Icon(Icons.home, color: Colors.white),
    title:
    const Text("Home", style: TextStyle(color: Colors.white)),
    onTap: _showUnderConstructionMessage,
    ),
    ListTile(
    leading: const Icon(Icons.settings, color: Colors.white),
    title: const Text("Settings",
    style: TextStyle(color: Colors.white)),
    onTap: _showUnderConstructionMessage,
    ),
    ListTile(
    leading: const Icon(Icons.logout, color: Colors.white),
    title: const Text("Logout",
    style: TextStyle(color: Colors.white)),
    onTap: _showUnderConstructionMessage,
    ),
    const Divider(color: Colors.white),
    ListTile(
    leading: const Icon(Icons.telegram, color: Colors.white),
    title: const Text("Telegram Channel",
    style: TextStyle(color: Colors.white)),
    onTap: () {
    _launchURL("https://t.me/nownewsuz");
    },
    ),    const Divider(color: Colors.white),
    if (widget.name != 'MuhammadY2011' &&
    widget.name != 'Admin2' &&
    widget.name != 'admin000aspirine' &&
    widget.name != 'admin1112011' &&
    widget.name != 'admin525252')
    ListTile(
    leading: const Icon(Icons.help, color: Colors.white),
    title: const Text("Helper",
    style: TextStyle(color: Colors.white)),
    onTap: () {
    showDialog(
    context: context,
    builder: (context) {
    TextEditingController helpController =
    TextEditingController();
    return AlertDialog(
    title: const Text('Yordam'),
    content: TextField(
    controller: helpController,
    decoration: const InputDecoration(
    hintText: 'Savolingizni yozing...'),
    ),
    actions: [
    TextButton(
    onPressed: () {
    Navigator.of(context).pop();
    },
    child: const Text('Bekor qilish'),
    ),
    TextButton(
    onPressed: () {
    String helpQuery = helpController.text;
    _saveQuestion(helpQuery);
    Navigator.of(context).pop();
    },
    child: const Text('Yuborish'),
    ),
    ],
    );
    });
    },
    ),
    const Divider(color: Colors.white),
    if (widget.name == 'MuhammadY2011' ||
    widget.name == 'Admin2' ||
    widget.name == 'admin000aspirine' ||
    widget.name == 'admin1112011' ||
    widget.name == 'admin525252')
    ListTile(
    leading: const Icon(Icons.question_answer, color: Colors.white),
    title: const Text("Viktorina javoblari",
    style: TextStyle(color: Colors.white)),
    onTap: () {
    _showQuizResponses();
    },
    ),
    ],
    ),
    ),
    ),
    ),
    body: Container(
    decoration: const BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.grey, Colors.grey],
    ),
    ),
    child: LayoutBuilder(
    builder: (context, constraints) {
    int crossAxisCount = constraints.maxWidth < 500 ? 1 : 2;
    return GridView.builder(
    padding: const EdgeInsets.all(8),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 0.94,
    ),
    itemCount: filteredNewsList.length,
    itemBuilder: (context, index) {
    return Card(
    color: Colors.white,
    elevation: 3.0,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
    children: [
    Image.network(
    filteredNewsList[index]["image"],
    height: 300,
    fit: BoxFit.cover,
    ),
    Padding(
    padding: const EdgeInsets.all(5.0),
    child: Text(
    filteredNewsList[index]["title"],
    style: const TextStyle(
    fontSize: 20, fontWeight: FontWeight.bold),
    textAlign: TextAlign.center,
    ),
    ),
    Text(
    filteredNewsList[index]["time"],
    style: const TextStyle(color: Colors.grey, fontSize: 9),
    ),
    TextButton(
    onPressed: () =>
    _launchURL(filteredNewsList[index]["url"]),
    child: const Text('Batafsil',                            style: TextStyle(fontSize: 15)),
    ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon:
            const Icon(Icons.thumb_up, color: Colors.green),
            onPressed: () => updateReaction(index, true),
            iconSize: 30,
          ),
          Text(
            "${filteredNewsList[index]["likes"]} Likes",
            style: const TextStyle(fontSize: 12),
          ),
          IconButton(
            icon:
            const Icon(Icons.thumb_down, color: Colors.red),
            onPressed: () => updateReaction(index, false),
            iconSize: 30,
          ),
          Text(
            "${filteredNewsList[index]["dislikes"]} Dislikes",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      TextButton(
        onPressed: () => addComment(index),
        child: const Text('Fikr qo\'shish',
            style: TextStyle(fontSize: 15)),
      ),
      Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredNewsList[index]["comments"].length,
          itemBuilder: (context, commentIndex) {
            return ListTile(
              title: Text(filteredNewsList[index]["comments"]
              [commentIndex]),
            );
          },
        ),
      ),
    ],
    ),
    );
    },
    );
    },
    ),
    ),
    );
  }
}

class NewsSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> newsList;

  NewsSearchDelegate(this.newsList);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = newsList
        .where(
            (news) => news["title"].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]["title"]),
          leading: Image.network(
            results[index]["image"],
            width: 50,
            fit: BoxFit.cover,
          ),
          subtitle: Text(results[index]["time"]),
          onTap: () {
            _launchURL(results[index]["url"]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = newsList
        .where(
            (news) => news["title"].toLowerCase().contains(query.toLowerCase()))
        .toList();    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]["title"]),
          leading: Image.network(
            suggestions[index]["image"],
            width: 50,
            fit: BoxFit.cover,
          ),
          subtitle: Text(suggestions[index]["time"]),
          onTap: () {
            query = suggestions[index]["title"];
            showResults(context);
          },
        );
      },
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}