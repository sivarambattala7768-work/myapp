
// To parse this JSON data, do
//
//     final postsListModel = postsListModelFromJson(jsonString);

import 'dart:convert';

List<PostsListModel> postsListModelFromJson(String str) => List<PostsListModel>.from(json.decode(str).map((x) => PostsListModel.fromJson(x)));

String postsListModelToJson(List<PostsListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PostsListModel {
    int? userId;
    int? id;
    String? title;
    String? body;

    PostsListModel({
        this.userId,
        this.id,
        this.title,
        this.body,
    });

    factory PostsListModel.fromJson(Map<String, dynamic> json) => PostsListModel(
        userId: json["userId"],
        id: json["id"],
        title: json["title"],
        body: json["body"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "id": id,
        "title": title,
        "body": body,
    };
}
