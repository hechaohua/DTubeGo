import 'package:dtube_go/bloc/hivesigner/hivesigner_bloc_full.dart';
import 'package:dtube_go/bloc/settings/settings_bloc_full.dart';
import 'package:dtube_go/style/ThemeData.dart';
import 'package:dtube_go/style/dtubeLoading.dart';
import 'package:dtube_go/style/styledCustomWidgets.dart';
import 'package:dtube_go/ui/pages/settings/HiveSignerButton.dart';
import 'package:dtube_go/ui/pages/settings/PinCodeDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dtube_go/utils/SecureStorage.dart' as sec;

class SettingsTabContainer extends StatefulWidget {
  SettingsTabContainer({Key? key}) : super(key: key);

  @override
  _SettingsTabContainerState createState() => _SettingsTabContainerState();
}

class _SettingsTabContainerState extends State<SettingsTabContainer>
    with SingleTickerProviderStateMixin {
  List<String> settingsTypes = ["General", "Avalon", "Cross-Posting"];
  late TabController _tabController;
  late SettingsBloc _settingsBloc;
  late Map<String, String> settings;

  late double _defaultVote;
  late double _defaultVoteComments;
  late double _defaultTip;
  late double _defaultTipComments;
  late String _showHidden;
  late String _showNsfw;
  late String _hiveUsername;
  late String _postTemplateBody;
  late String _postTemplateTitle;
  late String _pinCode;

  late String _imageUploadProvider;

  late TextEditingController _templateTitleController;
  late TextEditingController _templateBodyController;
  late TextEditingController _templateTagController;

  // late Map<String, String> currentSettings;

  @override
  void initState() {
    settings = {"none": "none"};
    _tabController = new TabController(length: 4, vsync: this);

    _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    _settingsBloc.add(FetchSettingsEvent()); // statements;
    _templateBodyController = TextEditingController(text: "");
    _templateTitleController = TextEditingController(text: "");
    _templateTagController = TextEditingController(text: "");

    super.initState();
  }

  List<String> _showHiddentNsfwOptions = ['Show', 'Hide', 'Blur'];

  List<String> _imageUploadProviders = ['imgur', 'ipfs'];
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // Todo abstract this to dtubeSubAppBar
      appBar: AppBar(
          centerTitle: true,
          title: DTubeLogo(
            size: 60,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 16.0, 0),
              child: GestureDetector(
                child: FaIcon(FontAwesomeIcons.save),
                onTap: () async {
                  Map<String, String> newSettings = {
                    sec.settingKey_defaultVotingWeight: _defaultVote.toString(),
                    sec.settingKey_defaultVotingWeightComments:
                        _defaultVoteComments.toString(),
                    sec.settingKey_defaultVotingTip: _defaultTip.toString(),
                    sec.settingKey_defaultVotingTipComments:
                        _defaultTipComments.toString(),
                    sec.settingKey_showHidden: _showHidden,
                    sec.settingKey_showNSFW: _showNsfw,
                    sec.settingKey_templateTitle:
                        _templateTitleController.value.text,
                    sec.settingKey_templateBody:
                        _templateBodyController.value.text,
                    sec.settingKey_templateTag:
                        _templateTagController.value.text,
                    sec.settingKey_imageUploadService: _imageUploadProvider
                  };
                  _settingsBloc.add(PushSettingsEvent(newSettings));
                },
              ),
            ),
          ]),
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
        if (state is SettingsLoadingState || state is SettingsSavingState) {
          return Center(
            child: DTubeLogoPulse(size: MediaQuery.of(context).size.width / 3),
          );
        } else if (state is SettingsLoadedState) {
          if (settings.length == 1) {
            settings = state.settings;

            _showHidden = settings[sec.settingKey_showHidden] != null
                ? settings[sec.settingKey_showHidden]!
                : "Hide";

            _showNsfw = settings[sec.settingKey_showNSFW] != null
                ? settings[sec.settingKey_showNSFW]!
                : "Hide";
            _defaultVote = settings[sec.settingKey_defaultVotingWeight] != null
                ? double.parse(settings[sec.settingKey_defaultVotingWeight]!)
                : 5.0;
            _defaultVoteComments =
                settings[sec.settingKey_defaultVotingWeightComments] != null
                    ? double.parse(
                        settings[sec.settingKey_defaultVotingWeightComments]!)
                    : 5.0;
            _defaultTip = settings[sec.settingKey_defaultVotingTip] != null
                ? double.parse(settings[sec.settingKey_defaultVotingTip]!)
                : 25;
            _defaultTipComments =
                settings[sec.settingKey_defaultVotingTipComments] != null
                    ? double.parse(
                        settings[sec.settingKey_defaultVotingTipComments]!)
                    : 25.0;
            _hiveUsername = settings[sec.settingKey_hiveSignerUsername] != null
                ? settings[sec.settingKey_hiveSignerUsername]!
                : "";

            _templateTitleController = new TextEditingController(
                text: settings[sec.settingKey_templateTitle] != null
                    ? settings[sec.settingKey_templateTitle]!
                    : "");
            _templateBodyController = new TextEditingController(
                text: settings[sec.settingKey_templateBody] != null
                    ? settings[sec.settingKey_templateBody]!
                    : "");
            _templateTagController = new TextEditingController(
                text: settings[sec.settingKey_templateTag] != null
                    ? settings[sec.settingKey_templateTag]!
                    : "");
            _hiveUsername = settings[sec.settingKey_hiveSignerUsername] != null
                ? settings[sec.settingKey_hiveSignerUsername]!
                : "";
            _pinCode = settings[sec.settingKey_pincode] != null
                ? settings[sec.settingKey_pincode]!
                : "";

            _imageUploadProvider =
                settings[sec.settingKey_imageUploadService] != null
                    ? settings[sec.settingKey_imageUploadService]!
                    : "imgur";
          }

          return Column(
            children: [
              TabBar(
                unselectedLabelColor: Colors.grey,
                labelColor: globalAlmostWhite,
                indicatorColor: globalRed,
                tabs: [
                  Tab(
                    text: 'General',
                  ),
                  Tab(
                    text: 'Avalon',
                  ),
                  Tab(
                    text: 'Cross-Posting',
                  ),
                  Tab(
                    text: 'Template',
                  ),
                ],
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            DTubeFormCard(
                              childs: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text("Display",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                ),
                                DropdownButtonFormField(
                                  decoration: InputDecoration(
                                      //filled: true,
                                      //fillColor: Hexcolor('#ecedec'),
                                      labelText: 'negative videos',
                                      labelStyle:
                                          Theme.of(context).textTheme.headline5
                                      //border: new CustomBorderTextFieldSkin().getSkin(),
                                      ),
                                  value: _showHidden,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _showHidden = newValue.toString();
                                      // widget.justSaved = false;
                                    });
                                  },
                                  items: _showHiddentNsfwOptions.map((option) {
                                    return DropdownMenuItem(
                                      child: new Text(option),
                                      value: option,
                                    );
                                  }).toList(),
                                ),
                                DropdownButtonFormField(
                                  decoration: InputDecoration(
                                      //filled: true,
                                      //fillColor: Hexcolor('#ecedec'),
                                      labelText: 'NSFW videos',
                                      labelStyle:
                                          Theme.of(context).textTheme.headline5
                                      //border: new CustomBorderTextFieldSkin().getSkin(),
                                      ),
                                  value: _showNsfw,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _showNsfw = newValue.toString();
                                      // widget.justSaved = false;
                                    });
                                  },
                                  items: _showHiddentNsfwOptions.map((option) {
                                    return DropdownMenuItem(
                                      child: new Text(option),
                                      value: option,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),

                            DTubeFormCard(
                              childs: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text("Security",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 200,
                                      child: Text(
                                          "secure your app with a 5 digit pin",
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  BlocProvider<SettingsBloc>(
                                                      create: (BuildContext
                                                              context) =>
                                                          SettingsBloc(),
                                                      child: PinCodeDialog(
                                                        currentPin: _pinCode,
                                                      )));
                                        },
                                        child: Text(_pinCode != ""
                                            ? "change pin"
                                            : "set pin"))
                                  ],
                                )
                              ],
                            ),
                            // deactivated until we have more providers
                            // Padding(
                            //   padding: const EdgeInsets.only(top: 16.0),
                            //   child: Text("Image upload",
                            //       style: Theme.of(context).textTheme.headline3),
                            // ),

                            // DTubeFormCard(
                            //   childs: [
                            //     DropdownButtonFormField(
                            //       decoration: InputDecoration(
                            //         //filled: true,
                            //         //fillColor: Hexcolor('#ecedec'),
                            //         labelText: 'storage provider',
                            //         //border: new CustomBorderTextFieldSkin().getSkin(),
                            //       ),
                            //       value: _imageUploadProvider,
                            //       onChanged: (newValue) {
                            //         setState(() {
                            //           _imageUploadProvider =
                            //               newValue.toString();
                            //           // widget.justSaved = false;
                            //         });
                            //       },
                            //       items: _imageUploadProviders.map((option) {
                            //         return DropdownMenuItem(
                            //           child: new Text(option),
                            //           value: option,
                            //         );
                            //       }).toList(),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 16),
                            DTubeFormCard(
                              childs: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text("Voting weight",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        "default voting weight (posts):",
                                        style: TextStyle(color: Colors.grey))),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Slider(
                                        min: 1.0,
                                        max: 100.0,
                                        value: _defaultVote,
                                        label: _defaultVote.floor().toString() +
                                            "%",
                                        divisions: 20,
                                        inactiveColor: globalBlue,
                                        activeColor: globalRed,
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            _defaultVote = value;
                                            //  widget.justSaved = false;
                                          });
                                        },
                                      ),
                                    ),
                                    Text(
                                      _defaultVote.floor().toString() + "%",
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        "default voting weight (comments):",
                                        style: TextStyle(color: Colors.grey))),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Slider(
                                        min: 0.0,
                                        max: 100.0,
                                        value: _defaultVoteComments,
                                        label: _defaultVoteComments
                                                .floor()
                                                .toString() +
                                            "%",
                                        divisions: 20,
                                        inactiveColor: globalBlue,
                                        activeColor: globalRed,
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            _defaultVoteComments = value;
                                            //  widget.justSaved = false;
                                          });
                                        },
                                      ),
                                    ),
                                    Text(
                                      _defaultVoteComments.floor().toString() +
                                          "%",
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            DTubeFormCard(
                              childs: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text("Vote tipping",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                ),
                                Text("default voting tip (posts):",
                                    style: TextStyle(color: Colors.grey)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Slider(
                                        min: 0.0,
                                        max: 100.0,
                                        value: _defaultTip,
                                        label: _defaultTip.floor().toString() +
                                            "%",
                                        divisions: 20,
                                        inactiveColor: globalBlue,
                                        activeColor: globalRed,
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            _defaultTip = value;
                                            // widget.justSaved = false;
                                          });
                                        },
                                      ),
                                    ),
                                    Text(
                                      _defaultTip.floor().toString() + "%",
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        "default voting tip (comments):",
                                        style: TextStyle(color: Colors.grey))),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Slider(
                                        min: 0.0,
                                        max: 100.0,
                                        value: _defaultTipComments,
                                        label: _defaultTipComments
                                                .floor()
                                                .toString() +
                                            "%",
                                        divisions: 20,
                                        inactiveColor: globalBlue,
                                        activeColor: globalRed,
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            _defaultTipComments = value;
                                            // widget.justSaved = false;
                                          });
                                        },
                                      ),
                                    ),
                                    Text(
                                      _defaultTipComments.floor().toString() +
                                          "%",
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 16),
                            DTubeFormCard(
                              childs: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0, bottom: 8.0),
                                  child: Text("Hivesigner settings",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: deviceWidth * 0.8,
                                      child: Column(
                                        children: [
                                          Text(
                                              "Cross-posting to the hive blockchain is possible by authorizing the app via hivesigner:",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: BlocProvider<HivesignerBloc>(
                                              create: (BuildContext context) =>
                                                  HivesignerBloc(
                                                      repository:
                                                          HivesignerRepositoryImpl()),
                                              child: HiveSignerButton(
                                                username: _hiveUsername,
                                              ),
                                            ),
                                          ),
                                          Text(
                                              "For security reasons you have to renew the connection every 7 days.",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1),
                                          SizedBox(height: 8),
                                          Text(
                                              "This authorizing does not include voting, commenting or any other functionality of the hive blockchain.",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 16.0, bottom: 8.0),
                              child: Text(
                                  "This template will be preselected for new uploads:",
                                  style: Theme.of(context).textTheme.bodyText1),
                            ),
                            DTubeFormCard(
                              childs: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0, bottom: 16),
                                  child: Text("Title",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.black,
                                ),
                                TextFormField(
                                  controller: _templateTitleController,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ],
                            ),
                            DTubeFormCard(
                              childs: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0, bottom: 16.0),
                                  child: Text("Body",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.black,
                                ),
                                TextFormField(
                                  controller: _templateBodyController,
                                  maxLines: 15,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ],
                            ),
                            DTubeFormCard(
                              childs: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0, bottom: 16.0),
                                  child: Text("Preview",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  width: deviceWidth * 0.9,
                                  height: 200,
                                  child: MarkdownBody(
                                      data: _templateBodyController.value.text),
                                )
                              ],
                            ),
                            DTubeFormCard(
                              childs: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0, bottom: 16.0),
                                  child: Text("Tag",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.black,
                                ),
                                TextFormField(
                                  controller: _templateTagController,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    controller: _tabController,
                  ),
                ),
              ),
            ],
          );
        } else if (state is SettingsErrorState) {
          return buildErrorUi(state.message);
        } else if (state is SettingsSavedState) {
          Navigator.of(context).pop();
          // setState(() {
          //   _justSaved = true;
          // });
        } else {
          return Text("unknown state");
        }
        return Center(
            child: DTubeLogoPulse(size: MediaQuery.of(context).size.width / 3));
      }),
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
}
