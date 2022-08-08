import 'package:dtube_go/bloc/user/user_bloc_full.dart';
import 'package:dtube_go/style/ThemeData.dart';
import 'package:dtube_go/utils/navigationShortcuts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:dtube_go/bloc/transaction/transaction_bloc_full.dart';
import 'package:dtube_go/ui/widgets/AccountAvatar.dart';
import 'package:dtube_go/ui/pages/post/widgets/ReplyButton.dart';
import 'package:dtube_go/ui/pages/post/widgets/VoteButtons.dart';

import 'package:dtube_go/bloc/postdetails/postdetails_bloc_full.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Create the Widget for the row
class CommentDisplay extends StatelessWidget {
  const CommentDisplay(
      this.entry,
      this.defaultVoteWeight,
      this._currentVT,
      this.parentAuthor,
      this.parentLink,
      this.defaultVoteTip,
      this.parentContext,
      this.blockedUsers,
      this.fixedDownvoteActivated,
      this.fixedDownvoteWeight);
  final Comment entry;
  final double defaultVoteWeight;
  final double defaultVoteTip;

  final bool fixedDownvoteActivated;
  final double fixedDownvoteWeight;

  final String parentAuthor;
  final String parentLink;
  final int _currentVT;
  final BuildContext parentContext;
  final List<String> blockedUsers;

  // This function recursively creates the multi-level list rows.
  Widget _buildTiles(Comment root) {
    if (root.childComments == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !blockedUsers.contains(root.author)
                  ? GestureDetector(
                      onTap: () {
                        navigateToUserDetailPage(
                            parentContext, root.author, () {});
                      },
                      child: AccountAvatarBase(
                        username: root.author,
                        avatarSize: 12.w,
                        showVerified: true,
                        showName: true,
                        width: 65.w,
                        height: 8.h,
                      ),
                    )
                  : AvatarErrorPlaceholder(),
              SizedBox(
                width: 8,
              ),
              Container(
                width: 60.w,
                child: Text(
                  !blockedUsers.contains(root.author)
                      ? root.commentjson.description
                      : "author is blocked",
                  style: !blockedUsers.contains(root.author)
                      ? Theme.of(parentContext).textTheme.bodyText1
                      : Theme.of(parentContext)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: globalRed),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              MultiBlocProvider(
                providers: [
                  BlocProvider<TransactionBloc>(
                      create: (context) => TransactionBloc(
                          repository: TransactionRepositoryImpl())),
                  BlocProvider<PostBloc>(
                      create: (context) =>
                          PostBloc(repository: PostRepositoryImpl())
                            ..add(FetchPostEvent(root.author, root.link))),
                  BlocProvider<UserBloc>(
                      create: (BuildContext context) =>
                          UserBloc(repository: UserRepositoryImpl())),
                ],
                child: VotingButtons(
                  defaultVotingWeight: defaultVoteWeight,
                  defaultVotingTip: defaultVoteTip,
                  scale: 0.5,
                  isPost: false,
                  focusVote: "",
                  iconColor: globalAlmostWhite,
                  fadeInFromLeft: true,
                  fixedDownvoteActivated: fixedDownvoteActivated,
                  fixedDownvoteWeight: fixedDownvoteWeight,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: BlocProvider(
                  create: (context) =>
                      TransactionBloc(repository: TransactionRepositoryImpl()),
                  child: ReplyButton(
                    icon: FaIcon(FontAwesomeIcons.comments),
                    author: root.author,
                    link: root.link,
                    parentAuthor: parentAuthor,
                    parentLink: parentLink,
                    votingWeight: defaultVoteWeight,
                    scale: 0.8,
                    focusOnNewComment: false,
                    isMainPost: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !blockedUsers.contains(root.author)
                    ? GestureDetector(
                        onTap: () {
                          navigateToUserDetailPage(
                              parentContext, root.author, () {});
                        },
                        child: AccountAvatarBase(
                          username: root.author,
                          avatarSize: 12.w,
                          showVerified: true,
                          showName: true,
                          width: 65.w,
                          height: 8.h,
                        ),
                      )
                    : AvatarErrorPlaceholder(),
                Container(
                  width: 80.w,
                  child: Text(
                    !blockedUsers.contains(root.author)
                        ? root.commentjson.description
                        : "author is blocked",
                    style: !blockedUsers.contains(root.author)
                        ? Theme.of(parentContext).textTheme.bodyText1
                        : Theme.of(parentContext)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: globalRed),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                MultiBlocProvider(
                  providers: [
                    BlocProvider<TransactionBloc>(
                        create: (context) => TransactionBloc(
                            repository: TransactionRepositoryImpl())),
                    BlocProvider<PostBloc>(
                        create: (context) =>
                            PostBloc(repository: PostRepositoryImpl())
                              ..add(FetchPostEvent(root.author, root.link))),
                    BlocProvider<UserBloc>(
                        create: (BuildContext context) =>
                            UserBloc(repository: UserRepositoryImpl())),
                  ],
                  child: VotingButtons(
                    defaultVotingWeight: defaultVoteWeight,
                    defaultVotingTip: defaultVoteTip,
                    scale: 0.5,
                    isPost: false,
                    iconColor: globalAlmostWhite,
                    focusVote: "",
                    fadeInFromLeft: true,
                    fixedDownvoteActivated: fixedDownvoteActivated,
                    fixedDownvoteWeight: fixedDownvoteWeight,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: BlocProvider(
                    create: (context) => TransactionBloc(
                        repository: TransactionRepositoryImpl()),
                    child: ReplyButton(
                      icon: FaIcon(FontAwesomeIcons.comments),
                      author: root.author,
                      link: root.link,
                      parentAuthor: parentAuthor,
                      parentLink: parentLink,
                      votingWeight: defaultVoteWeight,
                      scale: 0.8,
                      focusOnNewComment: false,
                      isMainPost: false,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                children: root.childComments!.map<Widget>(_buildTiles).toList(),
              ),
            ),
          ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("comment display");
    return _buildTiles(entry);
  }
}
