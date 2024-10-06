import 'rive_model.dart';

class Menu {
  final String title;
  final RiveModel rive;

  Menu({required this.title, required this.rive});
}

List<Menu> sidebarMenus = [
  Menu(
    title: "Home",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "HOME",
        stateMachineName: "HOME_interactivity"),
  ),
  Menu(
    title: "Music",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "PODCASTS",
        stateMachineName: "PODCAST_Interactivity"),
  ),
];
List<Menu> sidebarMenus2 = [
  Menu(
    title: "Completed Tasks",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "TIMER",
        stateMachineName: "TIMER_Interactivity"),
  ),
];
