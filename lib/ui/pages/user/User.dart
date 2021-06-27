import 'package:dtube_togo/bloc/auth/auth_bloc.dart';
import 'package:dtube_togo/bloc/auth/auth_bloc_full.dart';
import 'package:dtube_togo/bloc/feed/feed_bloc_full.dart';
import 'package:dtube_togo/ui/pages/wallet/transferDialog.dart';
import 'package:dtube_togo/ui/widgets/customSnackbar.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:dtube_togo/bloc/transaction/transaction_bloc_full.dart';
import 'package:dtube_togo/bloc/user/user_bloc_full.dart';
import 'package:dtube_togo/style/ThemeData.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../feeds/FeedList.dart';

class UserPage extends StatefulWidget {
  String? username;
  bool ownUserpage;
  @override
  _UserState createState() => _UserState();

  UserPage({Key? key, this.username, required this.ownUserpage})
      : super(key: key);
}

class _UserState extends State<UserPage> {
  late ScrollController scrollController;
  bool dialVisible = true;
  late UserBloc userBloc;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });
    userBloc = BlocProvider.of<UserBloc>(context);
    if (widget.ownUserpage) {
      userBloc.add(FetchMyAccountDataEvent());
    } else {
      userBloc.add(FetchAccountDataEvent(widget.username!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.ownUserpage
          ? null
          : AppBar(
              backgroundColor: globalAlmostBlack,
              elevation: 0,
              toolbarHeight: 28,
            ),
      body: Container(
        child: BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          child: BlocListener<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state is TransactionError) {
                showCustomFlushbarOnError(state, context);
              }
              if (state is TransactionSent) {
                showCustomFlushbarOnSuccess(state, context);
              }
            },
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserInitialState) {
                  return buildLoading();
                } else if (state is UserLoadingState) {
                  return buildLoading();
                } else if (state is UserLoadedState) {
                  return buildUserPage(state.user, widget.ownUserpage);
                } else if (state is UserErrorState) {
                  return buildErrorUi(state.message);
                } else {
                  return buildErrorUi('test');
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildErrorUi(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          message,
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget buildUserPage(User user, bool ownUsername) {
    return Stack(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
                child: Column(children: [
              SizedBox(height: ownUsername ? 90 : 0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  user.json_string?.profile?.avatar != null
                      ? CachedNetworkImage(
                          imageUrl: user.json_string!.profile!.avatar!,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 80.0,
                            height: 80.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) =>
                              new CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              new Icon(Icons.error),
                        )
                      : Icon(Icons.error),
                  SizedBox(width: 10),
                  Container(
                    width: (MediaQuery.of(context).size.width - 50) / 3 * 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24.0,
                            //color: Colors.black54,
                          ),
                        ),
                        user.json_string?.profile?.location != null
                            ? Text(user.json_string!.profile!.location!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  //color: Colors.black54,
                                ))
                            : SizedBox(
                                height: 0,
                              ),
                        user.json_string?.profile?.about != null
                            ? Text(
                                user.json_string!.profile!.about!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  //color: Colors.black54,
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              ),
                        user.json_string?.profile?.website != null
                            ? Text(user.json_string!.profile!.website!)
                            : SizedBox(
                                height: 0,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              BlocProvider<FeedBloc>(
                  create: (context) =>
                      FeedBloc(repository: FeedRepositoryImpl()),
                  child: FeedList(
                    feedType: 'UserFeed',
                    username: user.name,
                    showAuthor: false,
                    bigThumbnail: false,
                  ))
            ]))),
        buildSpeedDial(ownUsername, user.alreadyFollowing, user.name),
      ],
    );
  }

  Widget buildSpeedDial(bool ownUser, bool alreadyFollowing, String username) {
    // TextEditingController _amountController = new TextEditingController();
    // TextEditingController _memoController = new TextEditingController();
    UserBloc _userBloc = BlocProvider.of<UserBloc>(context);
    AuthBloc _authBloc = BlocProvider.of<AuthBloc>(context);
    TransactionBloc _txBloc = BlocProvider.of<TransactionBloc>(context);

    List<SpeedDialChild> othersPageOptions = [
      SpeedDialChild(
          child: Icon(Icons.wallet_giftcard),
          foregroundColor: globalAlmostWhite,
          backgroundColor: globalBlue,
          label: 'transfer',
          labelStyle: TextStyle(fontSize: 18.0),
          labelBackgroundColor: globalBlue,
          onTap: () {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) => TransferDialog(
                      receiver: username,
                      txBloc: _txBloc,
                    ));
          }),
      SpeedDialChild(
        child: Icon(Icons.follow_the_signs),
        foregroundColor: globalAlmostWhite,
        backgroundColor: globalBlue,
        label: alreadyFollowing ? 'Unfollow' : 'Follow',
        labelStyle: TextStyle(fontSize: 18.0),
        labelBackgroundColor: globalBlue,
        onTap: () async {
          TxData txdata = TxData(
            target: username,
          );
          Transaction newTx =
              Transaction(type: alreadyFollowing ? 8 : 7, data: txdata);
          _txBloc.add(SignAndSendTransactionEvent(newTx));
          _userBloc.add(FetchAccountDataEvent(widget.username!));
        },
        //onLongPress: () => print('SECOND CHILD LONG PRESS'),
      ),
    ];

    List<SpeedDialChild> myPageOptions = [
      SpeedDialChild(
          child: Icon(Icons.account_balance_wallet_outlined),
          foregroundColor: globalAlmostWhite,
          backgroundColor: globalBlue,
          label: 'Wallet',
          labelStyle: TextStyle(fontSize: 14.0),
          labelBackgroundColor: globalBlue,
          onTap: () {
            // navigate to new wallet page
          }),
      SpeedDialChild(
          child: Icon(Icons.cake),
          foregroundColor: globalAlmostWhite,
          backgroundColor: globalBlue,
          label: 'Rewards',
          labelStyle: TextStyle(fontSize: 14.0),
          labelBackgroundColor: globalBlue,
          onTap: () {
            // navigate to new rewards page
          }),
      SpeedDialChild(
          child: Icon(Icons.history),
          foregroundColor: globalAlmostWhite,
          backgroundColor: globalBlue,
          label: 'History',
          labelStyle: TextStyle(fontSize: 14.0),
          labelBackgroundColor: globalBlue,
          onTap: () {
            // navigate to new history page
          }),
      SpeedDialChild(
          child: Icon(Icons.logout),
          foregroundColor: globalAlmostWhite,
          backgroundColor: globalBlue,
          label: 'Logout',
          labelStyle: TextStyle(fontSize: 14.0),
          labelBackgroundColor: globalBlue,
          onTap: () {
            _authBloc.add(SignOutEvent());
            // navigate to new wallet page
          }),
    ];

    return SpeedDial(

        /// both default to 16
        marginEnd: 25,
        marginBottom: 50,
        // animatedIcon: AnimatedIcons.menu_close,
        // animatedIconTheme: IconThemeData(size: 22.0),
        /// This is ignored if animatedIcon is non null
        icon: FontAwesomeIcons.bars,
        activeIcon: FontAwesomeIcons.chevronLeft,
        // iconTheme: IconThemeData(color: Colors.grey[50], size: 30),

        /// The label of the main button.
        // label: Text("Open Speed Dial"),
        /// The active label of the main button, Defaults to label if not specified.
        // activeLabel: Text("Close Speed Dial"),
        /// Transition Builder between label and activeLabel, defaults to FadeTransition.
        // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
        /// The below button size defaults to 56 itself, its the FAB size + It also affects relative padding and other elements
        buttonSize: 56.0,
        visible: true,

        /// If true user is forced to close dial manually
        /// by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: globalAlmostWhite,
        overlayOpacity: 0,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: globalBlue,
        foregroundColor: globalAlmostWhite,
        elevation: 8.0,
        shape: CircleBorder(),

        // orientation: SpeedDialOrientation.Up,
        // childMarginBottom: 2,
        // childMarginTop: 2,

        gradientBoxShape: BoxShape.circle,
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [Colors.black, Colors.white],
        // ),
        children: ownUser ? myPageOptions : othersPageOptions);
  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }
}
