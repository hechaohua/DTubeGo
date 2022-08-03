import 'package:dtube_go/bloc/dao/dao_bloc_full.dart';
import 'package:dtube_go/ui/pages/wallet/Pages/Governance/DAO/PieChart.dart';
import 'package:flutter/material.dart';

class ProposalStateChart extends StatefulWidget {
  ProposalStateChart(
      {Key? key,
      required this.daoItem,
      required this.votingThreshold,
      required this.height,
      required this.width,
      required this.outerRadius,
      required this.centerRadius,
      required this.startFromDegree,
      this.showLabels,
      this.raisedLabel,
      required this.onTap,
      required this.phase,
      required this.status})
      : super(key: key);
  DAOItem daoItem;
  final int votingThreshold;
  final double height;
  final double width;
  final double centerRadius;
  final double outerRadius;
  final double startFromDegree;
  bool? showLabels;
  String? raisedLabel;
  VoidCallback onTap;
  String phase;
  String status;

  @override
  State<ProposalStateChart> createState() => _ProposalStateChartState();
}

class _ProposalStateChartState extends State<ProposalStateChart> {
  @override
  void initState() {
    super.initState();
    if (widget.showLabels == null) {
      widget.showLabels = false;
    }
    if (widget.raisedLabel == null) {
      widget.raisedLabel = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // proposal is in voting phase
    return PiChart(
      goalValue: widget.phase == "voting"
          ? widget.votingThreshold
          : widget.daoItem.requested!,
      receivedValue: widget.phase == "voting"
          ? widget.daoItem.approvals!
          : widget.daoItem.raised!,
      centerRadius: widget.centerRadius,
      height: widget.height,
      outerRadius: widget.outerRadius,
      startFromDegree: widget.startFromDegree,
      width: widget.width,
      showLabels: widget.showLabels!,
      raisedLabel: widget.raisedLabel!,
      onTapCallback: widget.onTap,
    );
  }
}
