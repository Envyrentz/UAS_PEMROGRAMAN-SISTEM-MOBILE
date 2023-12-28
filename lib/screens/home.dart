import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/prompt_model.dart';
import '../widgets/prompt_card.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Prompt> prompts = [];
  List<Prompt> filteredPrompts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPrompts();
  }

  Future<void> _fetchPrompts() async {
    final Uri apiUrl = Uri.parse('https://auspicious-life-401200.et.r.appspot.com/prompts');
    final http.Response response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List<dynamic> promptData = jsonDecode(response.body);
      final List<Prompt> fetchedPrompts =
          promptData.map((data) => Prompt.fromJson(data)).toList();

      setState(() {
        prompts = fetchedPrompts;
        filteredPrompts = fetchedPrompts; // Initialize filteredPrompts with all prompts
      });
    } else {
      print('Failed to fetch prompts: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUserLoggedIn = Provider.of<UserProvider>(context).isLoggedIn;
    final token = Provider.of<UserProvider>(context).token;
    final authorId = Provider.of<UserProvider>(context).authorId;
    final authorName = Provider.of<UserProvider>(context).authorName;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/landing');
          },
        ),
       actions: [
  if (isUserLoggedIn)
    Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilledButton(
        onPressed: () {
          // Show create post dialog
          _showCreatePostDialog(context, token, authorId, authorName);
        },
        child: const Text('Create Post'),
      ),
    ),
  if (isUserLoggedIn)
    Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Logout logic
          Provider.of<UserProvider>(context, listen: false).logout();

          _logoutApiCall();
        },
        child: const Text('Logout'),
      ),
    ),
  if (!isUserLoggedIn)
    FilledButton(
      onPressed: () {
        // Navigate to the login page
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: const Text('Login'),
    ),

     Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
           Navigator.pushReplacementNamed(context, '/about');
        
        },
        child: const Text('About us'),
      ),
    ),
],

      ),
         body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child:CupertinoSearchTextField(
            controller: searchController,
            placeholder: 'Search',
             onChanged: (value) {
                _filterPrompts(value);
              },
          ),
          ),
        ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPrompts.length,
              itemBuilder: (context, index) {
                final String promptId = filteredPrompts[index].id;

                return PromptCard(
                  prompt: filteredPrompts[index],
                  onDelete: () async {
                    // Implement delete logic if needed
                    await _deletePrompt(promptId, token);
                    // Refresh the page
                    _fetchPrompts();
                  },
                  onEdit: (title, content) async {
                    // Implement edit logic if needed
                    await _editPrompt(promptId, token, title, content);
                    // Refresh the page
                    _fetchPrompts();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
void _filterPrompts(String searchTerm) {
  setState(() {
    filteredPrompts = prompts.where((prompt) {
      final String lowerCaseSearchTerm = searchTerm.toLowerCase();

      return prompt.title.toLowerCase().contains(lowerCaseSearchTerm) ||
          prompt.tags.any((tag) => tag.toLowerCase().contains(lowerCaseSearchTerm));
    }).toList();
  });
}
void _showCreatePostDialog(BuildContext context,String token,String authorId, String authorName) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    TextEditingController tagsController = TextEditingController();
    // final token = Provider.of<UserProvider>(context).token;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Post'),
          content: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: contentController,
                maxLines: null, // Allow multiple lines for content
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(labelText: 'Tags'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Create the post
                final post = {
                  'title': titleController.text,
                  'content': contentController.text,
                  'tags': tagsController.text,
                  'authorId' : authorId,
                  'authorName':authorName,
                };

                // Call the API to create the post
                await _createPost(post,token);

                // Refresh the page
                _fetchPrompts();

                Navigator.pop(context);
              },
              child: const Text('Create Post'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editPrompt(String postId, String token, String newTitle, String newContent) async {
  final Uri apiUrl = Uri.parse('https://auspicious-life-401200.et.r.appspot.com/prompts/$postId');

  try {
    final http.Response response = await http.patch(
      apiUrl,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      body: {
        'title': newTitle,
        'content': newContent,
      },
    );

    print("edit post id: $postId");

    if (response.statusCode == 200) {
      // Post edited successfully
      print('Post edited successfully');
      _fetchPrompts();
    } else {
      // Handle edit failure
      print('Post edit failed: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  } catch (error) {
    // Handle network or other errors
    print('Error editing post: $error');
  }
}


  Future<void> _deletePrompt(String postId,String token) async {
  final Uri apiUrl = Uri.parse('https://auspicious-life-401200.et.r.appspot.com/prompts/$postId');

  try {
    final http.Response response = await http.delete(
      apiUrl,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
        // Add any other headers you might need, such as authorization headers
      },
    
      
    );
    
    print("delete post id:"+postId);

    if (response.statusCode == 200) {
      // Post deleted successfully
      print('Post deleted successfully');
      _fetchPrompts();
    } else {
      // Handle delete failure
      print('Post deletion failed: ${response.statusCode}');
    }
  } catch (error) {
    // Handle network or other errors
    print('Error deleting post: $error');
  }
}

 Future<void> _createPost(Map<String, dynamic> post,String token) async {
  try {
    final Uri apiUrl = Uri.parse('https://auspicious-life-401200.et.r.appspot.com/prompts');
    
    // Access the UserProvider instance using Provider
    // final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Get the session cookie from UserProvider
    // final String sessionCookie = token;

    final http.Response response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      body: post,
      
    );

    print('Received Headers:'+ response.headers.toString());

    if (response.statusCode == 201) {
      // Successfully created the post
      print('Post created successfully');
      _fetchPrompts();
    } else {
      // Handle post creation failure
      print('Post creation failed: ${response.statusCode}');
    }
  } catch (error) {
    // Handle any exceptions that may occur during the API call
    print('Post creation error: $error');
  }
}


  void _logoutApiCall() async {
    try {
      final Uri apiUrl = Uri.parse('https://auspicious-life-401200.et.r.appspot.com/logout');
      final http.Response response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Successfully logged out from the server
        print('Logout successful');
        _fetchPrompts();
      } else {
        // Handle logout failure
        print('Logout failed: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any exceptions that may occur during the API call
      print('Logout error: $error');
    }
  }
}
