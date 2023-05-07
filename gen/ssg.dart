import "package:front_matter/front_matter.dart" as frontMatter;
import "package:markdown/markdown.dart";
import "dart:io";
import "package:path/path.dart";

class FileWrapper {
  File file;
  String content;
  var meta;

  FileWrapper(this.file, this.content, this.meta);
}

class MenuEntry {
  String name;
  String html;
  int weight;

  MenuEntry(this.name, this.html, this.weight);
}

void main() async {
  Directory content = Directory("content");
  await content.create();

  Directory out = Directory("out");
  if (await out.exists()) {
    await out.delete(recursive: true);
  }
  await out.create();

  List<FileWrapper> files = [];
  List<MenuEntry> menu = [];

  var list = await content.list(recursive: true).toList();
  for (var entry in list) {
    if (entry is File) {
      print("processing file '${entry.path}'");

      var meta = frontMatter.parse(await entry.readAsString());
      var fileName = basenameWithoutExtension(entry.path);
      var path = relative(entry.path, from: content.path).replaceFirst(extension(entry.path), "");

      var link = "/$path/";
      if (fileName == "index") {
        link = "/${path.replaceFirst("index", "")}";
      }
      var outFile = "${out.path}${link}/index.html";

      if (meta.data["title"] != "") {
        menu.add(MenuEntry(meta.data["title"], '<a href="$link">${meta.data["title"]}</a>', meta.data["weight"] ?? 0));
        files.add(FileWrapper(File(outFile), markdownToHtml(meta.content), meta.data));
      }
    }
  }

  menu.sort((a, b) => b.weight - a.weight);
  for (FileWrapper article in files) {
    await article.file.create(recursive: true);
    await article.file.writeAsString('''
    <html>
      <head>
        <title>${article.meta["title"]} by ${article.meta["author"]}</title>
        <style>
        main {
          display:flex;
        }
        
        aside {
          box-sizing: border-box;
          padding: 1rem;
        }
        
        aside a {
          display:block;
          text-decoration:none;
        }
        
        aside a:hover {
          text-decoration: underline
        }
        </style>
      </head>
      <body>
        <main>
          <aside>${menu.map((e) => e.html).join("\n")}</aside>
          <section>
          ${article.content}
          </section>
        </main>
      </body>
    </html>
    ''');
  }
}