import 'dart:math';

import 'package:firebase_auth/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final googleSignIn = GoogleSignIn();

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

String generateUniqueUsername(String name) {
  // Remove spaces and convert to lowercase
  String username = name.replaceAll(' ', '').toLowerCase();

  // Generate a random number
  Random random = Random();
  int randomNumber = random.nextInt(9999);

  // Get the current timestamp
  DateTime now = DateTime.now();
  String timestamp = now.millisecondsSinceEpoch.toString();

  // Combine username, timestamp, and random number
  String uniqueUsername = '$username$timestamp$randomNumber';

  return uniqueUsername;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class UserInfo {
  final String username;
  final String firstName;
  final String lastName;

  UserInfo(this.username, this.firstName, this.lastName);

  UserInfo.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        firstName = json['first_name'],
        lastName = json['last_name'];

  Map<String, dynamic> toJson() => {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
      };
}

class UserToken {
  final String accessToken;
  final String idToken;

  UserToken(this.accessToken, this.idToken);

  // Map<String, dynamic> toJson() => {
  //       'username': username,
  //       'first_name': firstName,
  //       'last_name': lastName,
  //     };
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _idToken = '';

// TODO: Login With Google
  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Use the access token and ID token from googleAuth to authenticate the user with your backend or perform other operations
        final String accessToken = googleAuth.accessToken ?? '';
        final String idToken = googleAuth.idToken ?? '';
        List<String> nameParts = googleUser.displayName!.split(' ');

        // ...

        print('Access Token: $accessToken');
        print('Id Token: $googleUser');
        // setState(() {
        //   // Redirect to home
        //   _idToken = googleAuth.idToken.toString();
        // });
        registerAndLink(
            UserInfo(generateUniqueUsername(googleUser.displayName!),
                nameParts[0], nameParts[nameParts.length - 1]),
            UserToken(accessToken, idToken));
      }
    } catch (error) {
      // Handle any errors that occur during the login process
      print('Error: $error');
    }
  }

  // TODO: Register and Link user with Google Acccount
  Future<void> registerAndLink(UserInfo user, UserToken token) async {
    final url = Uri.parse(
        "https://listartest.dreamhosters.com/wp-json/nextend-social-login/v1/google/get_user?access_token={ 'access_token': ${token.accessToken}, 'expires_in': 3599, 'token_type': 'Bearer', 'id_token': ${token.idToken}}");

    final response = await http.post(
      url,
      body: user.toJson(),
    );

    // TODO: Store token in Local DB and then redirect user to home
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText(_idToken),
            ElevatedButton.icon(
              onPressed: () {
                // Handle Facebook login button pressed
                // Call your login function for Facebook
              },
              icon: const Icon(Icons.facebook),
              label: const Text('Login with Facebook'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Handle Google login button pressed
                // Call your login function for Google
                loginWithGoogle();
              },
              icon: const Icon(Icons.login),
              label: const Text('Login with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
