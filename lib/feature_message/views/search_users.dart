import 'package:appwrite/models.dart';
import 'package:farmshield/feature_message/constants/colors.dart';
import 'package:farmshield/feature_message/controllers/appwrite_controllers.dart';
import 'package:farmshield/feature_message/models/user_data.dart';
import 'package:farmshield/feature_message/providers/user_data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  final TextEditingController _searchController = TextEditingController();
  late DocumentList searchedUsers = DocumentList(total: -1, documents: []);

// handle the search
  void _handleSearch() {
    searchUsers(
            searchItem: _searchController.text,
            userId:
                Provider.of<UserDataProvider>(context, listen: false).getUserId)
        .then((value) {
      if (value != null) {
        setState(() {
          searchedUsers = value;
        });
      } else {
        setState(() {
          searchedUsers = DocumentList(total: 0, documents: []);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Users",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
              decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(6)),
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) => _handleSearch(),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter phone number"),
                  )),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _handleSearch();
                    },
                  )
                ],
              ),
            )),
      ),
      body: searchedUsers.total == -1
          ? Center(
              child: Text("Use the search box to search users."),
            )
          : searchedUsers.total == 0
              ? Center(
                  child: Text("No users found"),
                )
              : ListView.builder(
                  itemCount: searchedUsers.documents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, "/chat",
                            arguments: UserData.toMap(
                                searchedUsers.documents[index].data));
                      },
                      leading: CircleAvatar(
                        backgroundImage: searchedUsers
                                        .documents[index].data["profile_pic"] !=
                                    null &&
                                searchedUsers
                                        .documents[index].data["profile_pic"] !=
                                    ""
                            ? NetworkImage(
                                "https://cloud.appwrite.io/v1/storage/buckets/66ed4154003a4065ef76/files/${searchedUsers.documents[index].data["profile_pic"]}/view?project=66ed2752001a89f99303&mode=admin")
                            : Image(image: AssetImage("assets/user.png")).image,
                      ),
                      title: Text(searchedUsers.documents[index].data["name"]),
                      subtitle:
                          Text(searchedUsers.documents[index].data["phone_no"]),
                    );
                  },
                ),
    );
  }
}
