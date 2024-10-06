import '../../models/menu.dart';

class UpdateNavigationIndexAction {
  int navigationIndex;
  UpdateNavigationIndexAction(this.navigationIndex);
}

class UpdateCurrentSongIndexAction {
  int currentSongIndex;
  UpdateCurrentSongIndexAction(this.currentSongIndex);
}

class UpdateSelectedTabAction {
  Menu selectedTab;
  bool isClosed;
  UpdateSelectedTabAction(this.selectedTab, this.isClosed);
}
