import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:project_39_fe/rpc.dart';
import 'package:project_39_fe/src/generated/project_39/v1/project_39.pb.dart';

const height = 298.0;

final scrollController = ScrollController();

class AdoptPage extends StatefulWidget {
  const AdoptPage({super.key, required this.userName});
  final String userName;

  @override
  State<AdoptPage> createState() => _AdoptPageState();
}

class _AdoptPageState extends State<AdoptPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getAdoptDataBatch(),
        builder: (context, AsyncSnapshot<List<AdoptData>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          return Scrollbar(
            controller: scrollController,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              children: snapshot.data!.map((e) {
                return buildCardLayout(context, e.objId, e.title, e.imageUrl,
                    e.description, e.category, e.location, widget.userName);
              }).toList(),
            ),
          );
        });
  }
}

class AdoptData {
  AdoptData(
      {required this.objId,
      required this.title,
      required this.imageUrl,
      required this.description,
      required this.category,
      required this.location});

  final int objId;
  final String title;
  final String imageUrl;
  final String description;
  final String category;
  final String location;
}

Future<List<AdoptData>> getAdoptDataBatch() async {
  final client = newRpcClient();
  final batch =
      await client.getDisplayObjectBatch(GetDisplayObjectBatchRequest(len: 20));
  return batch.objs.map((e) {
    return AdoptData(
        objId: e.objId.toInt(),
        title: e.objName,
        imageUrl: e.objProfilePictureUrl,
        description: e.desc,
        category: e.category,
        location: e.location);
  }).toList();
}

Widget buildCardLayout(
    BuildContext context,
    int objId,
    String title,
    String imageUrl,
    String description,
    String category,
    String location,
    String userName) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(
                height: height,
                width: height * 9 / 6,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Scaffold(
                          appBar: AppBar(
                            leading: BackButton(
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          body: buildDetailPage(context, objId, title, imageUrl,
                              description, category, location, userName),
                        );
                      }));
                    },
                    splashColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.12),
                    highlightColor: Colors.transparent,
                    child: Semantics(
                      label: title,
                      child: buildCard(context, title, imageUrl, description,
                          category, location),
                    ),
                  ),
                ))
          ],
        ),
      ),
    ),
  );
}

Widget buildCard(BuildContext context, String title, String imageUrl,
    String description, String category, String location) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          height: 184 * 0.9,
          child: ClipRect(
            child: Align(
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: 16 / 9, // 16:9 比例
                child: Ink.image(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  child: Container(),
                ),
              ),
            ),
          ),
        ),
      ),

      // Title
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Semantics(
          container: true,
          header: true,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      // Description, category, and location
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: DefaultTextStyle(
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(color: Colors.black54),
              ),
              Text(category),
              Text(location),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget buildDetailPage(
    BuildContext context,
    int objId,
    String title,
    String imageUrl,
    String description,
    String category,
    String location,
    String userName) {
  final card =
      buildCard(context, title, imageUrl, description, category, location);

  return FutureBuilder(
    future: buildDetailPageFuture(context, objId, title, imageUrl, description,
        category, location, card, userName),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const CircularProgressIndicator();
      }

      if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      }

      return snapshot.data!;
    },
  );
}

Future<Widget> buildDetailPageFuture(
    BuildContext context,
    int objId,
    String title,
    String imageUrl,
    String description,
    String category,
    String location,
    Widget card,
    String userName) async {
  final client = newRpcClient();
  final ret = await client.getDisplayObjectStatus(
      GetDisplayObjectStatusRequest(objId: Int64(objId)));

  String status;
  if (ret.obj.ownership.isEmpty) {
    status = "领养";
  } else {
    status = "已经由用户 @${ret.obj.ownership} 领养";
  }

  return Column(
    children: [
      const Spacer(
        flex: 1,
      ),
      card,
      const Spacer(
        flex: 2,
      ),
      Center(
        child: TextButton(
          child: Text(status),
          onPressed: () async {
            if (ret.obj.ownership.isNotEmpty) {
              final obj = ret.obj;
              obj.ownership = userName;
              await client.putDisplayObjectStatus(
                  PutDisplayObjectStatusRequest(obj: obj));
            }

            // ignore: use_build_context_synchronously
            await showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('领养成功'),
                content: Text("带$title回家吧～"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'OK');
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      const Spacer(
        flex: 1,
      ),
    ],
  );
}
