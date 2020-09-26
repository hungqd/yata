import 'package:meta/meta.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yatp/src/actions/index.dart';
import 'package:yatp/src/data/auth_api.dart';
import 'package:yatp/src/data/storage_api.dart';
import 'package:yatp/src/epics/auth_epic.dart';
import 'package:yatp/src/models/index.dart';

class AppEpics {
  const AppEpics({
    @required AuthApi authApi,
    @required StorageApi storageApi,
  })  : assert(authApi != null),
        assert(storageApi != null),
        _storageApi = storageApi,
        _authApi = authApi;

  final AuthApi _authApi;
  final StorageApi _storageApi;

  Epic<AppState> get epics {
    return combineEpics(<Epic<AppState>>[
      AuthEpic(authApi: _authApi).epics,
      TypedEpic<AppState, InitializeApp$>(_initializeApp),
      TypedEpic<AppState, SetWallpaper$>(_setWallpaper),
    ]);
  }

  Stream<AppAction> _initializeApp(Stream<InitializeApp$> actions, EpicStore<AppState> store) {
    return actions //
        .flatMap((InitializeApp$ action) => _authApi
            .currentUser()
            .expand((AppUser user) => <AppAction>[
                  InitializeApp.successful(user),
                  if (user != null) ...<AppAction>[
                    //todo: Fetch for todos in future
                  ]
                ])
            .onErrorReturnWith((dynamic error) => InitializeApp.error(error)));
  }

  Stream<AppAction> _setWallpaper(Stream<SetWallpaper$> actions, EpicStore<AppState> store) {
    return actions //
        .asyncMap((SetWallpaper$ action) => _storageApi.getAndSetWallPaper(action.byteData))
        .map((String result) => SetWallpaper.successful(result))
        .onErrorReturnWith((dynamic error) => SetWallpaper.error(error));
  }
}
