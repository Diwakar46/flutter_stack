// To parse this JSON data, do
//
//     final apiGitHubResponse = apiGitHubResponseFromJson(jsonString);

import 'dart:convert';

ApiGitHubResponse apiGitHubResponseFromJson(String str) => ApiGitHubResponse.fromJson(json.decode(str));

String apiGitHubResponseToJson(ApiGitHubResponse data) => json.encode(data.toJson());

class ApiGitHubResponse {
    final String? name;
    final String? path;
    final String? sha;
    final int? size;
    final String? url;
    final String? htmlUrl;
    final String? gitUrl;
    final String? downloadUrl;
    final String? type;
    final String? content;
    final String? encoding;
    final Links? links;

    ApiGitHubResponse({
        this.name,
        this.path,
        this.sha,
        this.size,
        this.url,
        this.htmlUrl,
        this.gitUrl,
        this.downloadUrl,
        this.type,
        this.content,
        this.encoding,
        this.links,
    });

    factory ApiGitHubResponse.fromJson(Map<String, dynamic> json) => ApiGitHubResponse(
        name: json["name"],
        path: json["path"],
        sha: json["sha"],
        size: json["size"],
        url: json["url"],
        htmlUrl: json["html_url"],
        gitUrl: json["git_url"],
        downloadUrl: json["download_url"],
        type: json["type"],
        content: json["content"],
        encoding: json["encoding"],
        links: json["_links"] == null ? null : Links.fromJson(json["_links"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "path": path,
        "sha": sha,
        "size": size,
        "url": url,
        "html_url": htmlUrl,
        "git_url": gitUrl,
        "download_url": downloadUrl,
        "type": type,
        "content": content,
        "encoding": encoding,
        "_links": links?.toJson(),
    };
}

class Links {
    final String? self;
    final String? git;
    final String? html;

    Links({
        this.self,
        this.git,
        this.html,
    });

    factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: json["self"],
        git: json["git"],
        html: json["html"],
    );

    Map<String, dynamic> toJson() => {
        "self": self,
        "git": git,
        "html": html,
    };
}
