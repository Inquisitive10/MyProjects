import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'LIKLF3lW6Mpbpp7mtZvVtmZptIsnl8KrgePO5kHR';
  final keyClientKey = '0ILnjevbrpoMp99j1tWAI9CmLHGc5ddKCsfRNJwT';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp( new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => new _State();
}

class _State extends State<MyApp>{
  int value = 0;

  List<ParseObject>? tasks;
  List<bool>? tasksSelected;

  bool taskListMenu = true;
  bool isEdit = false;
  bool isDelete = false;
  bool isSubmitEnabled = true;
  bool isDetail = false;
  bool showTitleError = false;
  bool showDescError = false;

  String title = "";
  String description = "";
  String submitButtonText = "Add";

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  //initilaizing the data on loading the app
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  //Call to back4app to fetch records using parse SDK
  void fetchData() async {
    final queryBuilder = QueryBuilder(ParseObject('TaskManager'))
      ..orderByAscending('createdAt');
    try {
      final result = await queryBuilder.query();
      setState(() {
        tasks = result.results?.cast<ParseObject>();
        tasksSelected = List.generate(tasks?.length??0, (index) => false);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  //This function changes the states of variables and also enables and disables edit and delete action buttons based on toggling of checkboxes
  void toggleCheckbox(int index) {
    setState(() {
      tasksSelected![index] = !tasksSelected![index];
      //isEdit = tasksSelected?.where((element) => element == true).length == 1;
      int taskIndex = tasksSelected?.indexWhere((element) => element == true) ?? -1;
      isEdit = taskIndex != -1 && tasksSelected?.lastIndexOf(true) == taskIndex;
      isDelete = tasksSelected?.where((element) => element == true).isNotEmpty??false;
      if(isEdit){
        titleController.text = title = tasks![taskIndex].get('title');
        descriptionController.text = description = tasks![taskIndex].get('description');
        submitButtonText = "Update";
      }
    });
  }

  //This function changes the states of variables when add task action button is clicked
  void onAddTask(bool value){
    setState((){
      taskListMenu = value;
      titleController.text = title = '';
      descriptionController.text = description = '';
      tasksSelected?.fillRange(0, tasksSelected!.length, false);
      isEdit = false;
      isDelete = false;
      isDetail = false;
      submitButtonText = "Add";
    });
  }

  //changing the widget when edit is clicked
  void onEditTask(bool value){
    setState((){
      taskListMenu = value;
    });
  }

  //deleting the entries based on checkboxes selection from back4app using parse SDK
  void onDeleteTask() async{
    final ParseObject myClass = ParseObject('TaskManager');
    for (int i = 0; i < tasksSelected!.length; i++) {
      if(tasksSelected![i]) {
        myClass.objectId = tasks![i].get('objectId');
         try {
          // Delete the Task from the class
          final ParseResponse result = await myClass.delete();

          if (result.success) {
            print('Task deleted successfully!');
          } else {
            print('Error deleting Task: ${result.error?.message}');
          }
        } catch (e) {
          print('Error deleting Task: $e');
        }
      }
    }
    onAddTask(true);
    fetchData();
  }

  //This function is used to add and update rows of back4app class using parse SDK
  void onSubmit() async{
    if(title.isEmpty){
      setState(() {
        showTitleError = true;
      });
    } if(description.isEmpty){
      setState(() {
        showDescError = true;
      });
    }
    if(title.isNotEmpty && description.isNotEmpty){
      setState(() {
        isSubmitEnabled = false;
      });
      final ParseObject myClass = ParseObject('TaskManager');

      if(isEdit){
        int taskIndex = tasksSelected?.indexWhere((element) => element == true)??-1;
        if(taskIndex!=-1)
          myClass.objectId = tasks![taskIndex].get('objectId');
      }

      // Set values for the new Task
      myClass.set<String>('title', title);
      myClass.set<String>('description', description);
      try {
        // Save the new Task to the class
        final ParseResponse result = await myClass.save();

        if (result.success) {
          print('Task added successfully!');
        } else {
          print('Error adding Task: ${result.error?.message}');
        }
      } catch (e) {
        print('Error adding Task: $e');
      }
      setState(() {
        isSubmitEnabled = true;
      });
      fetchData();
      onAddTask(true);
    }
  }

  //main widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Task Manager'),
        backgroundColor: Colors.lightBlue
      ),
      body: isDetail? taskDetailsBody():(taskListMenu?taskListBody():addTaskBody()),
    );
  }

  //body widget to display tasks list
  Widget taskListBody() {
    return new Container(
        padding: new EdgeInsets.all(32.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text('Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children:[
                    new IconButton(onPressed: isEdit ? () => onEditTask(false) : null , icon: new Icon(Icons.edit), tooltip: "Edit selected"),
                    new IconButton(onPressed: isDelete ? () =>onDeleteTask() : null , icon: new Icon(Icons.delete), tooltip: "Delete selected",),
                    new IconButton(onPressed:(()=>{onAddTask(false)}), icon: new Icon(Icons.add), tooltip: "Add task",),
                  ]
                )
              ],
            ),
            SizedBox(height: 16), // Adjust the spacing as needed
            Expanded(
              child: ListView.builder(
                itemCount: tasks?.length ?? 0,
                itemBuilder: (context, index) {
                  final task = tasks![index];
                  return ListTile(
                    title: Text(task.get('title')),
                    subtitle: Text(task.get('description')),
                    onTap: () {
                      setState(() {
                        isDetail = true;
                        title = task.get('title');
                        description = task.get('description');
                      });
                    },
                    leading: Checkbox(
                      value: tasksSelected![index], // Set the initial checkbox state
                      onChanged: (bool? value) {
                        // Handle the checkbox change
                        toggleCheckbox(index);
                      },
                    ),
                  );
                }
              )
            )
          ]
        ),
      );
  }

  //body widget for add task
  Widget addTaskBody() {
    return new Container(
      padding: new EdgeInsets.all(32.0),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              new IconButton(onPressed: (()=>onAddTask(true)), icon: new Icon(Icons.arrow_back), tooltip: "Back",),
              new Text('Add task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 50),
          new TextField(
            controller: titleController,
            decoration: new InputDecoration(
              // labelText: "Title",
              // labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 2.0),
              hintText: "Enter title",
              hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              icon: new Icon(Icons.task),
              errorText: showTitleError? "Please enter the title":"",
            ),
            autocorrect: true,
            autofocus: true,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              showTitleError = false;
              setState(() {
                title = value;
              });
            },
            //onSubmitted: ,
          ),
          SizedBox(height: 30),
          new TextField(
            controller: descriptionController,
            decoration: new InputDecoration(
              // labelText: "Title",
              // labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 2.0),
              hintText: "Enter description",
              hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              icon: new Icon(Icons.description),
              errorText: showDescError? "Please enter the description":"",
            ),
            autocorrect: true,
            autofocus: true,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              showDescError = false;
              setState(() {
                description = value;
              });
            },
            //onSubmitted: ,
          ),
          SizedBox(height: 50),
          new ElevatedButton.icon(onPressed: isSubmitEnabled ? () => onSubmit() : null, icon: Icon(Icons.check), label: Text(submitButtonText))
        ]
      ),
    );
  }

  //body widget for task details
  Widget taskDetailsBody() {
    return new Container(
      padding: new EdgeInsets.all(32.0),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              new IconButton(onPressed: (()=>onAddTask(true)), icon: new Icon(Icons.arrow_back), tooltip: "Back",),
              new Text('Task Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 50),
          new Card(
            child: ListTile(
              leading: Icon(Icons.info), // Icon or image for item
              title: Text('Task title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w200)),
              subtitle: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 30),
          new Card(
            child: ListTile(
              leading: Icon(Icons.info), // Icon or image for item
              title: Text('Task description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w200)),
              subtitle: Text(description, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ]
      )
    );
  }
}
