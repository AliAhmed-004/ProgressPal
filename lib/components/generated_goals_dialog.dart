import 'package:flutter/material.dart';
import 'package:progresspal/providers/track_provider.dart';
import 'package:provider/provider.dart';

class GeneratedGoalsDialog extends StatefulWidget {
  final List<String> goals;

  const GeneratedGoalsDialog({super.key, required this.goals});

  @override
  _GeneratedGoalsDialogState createState() => _GeneratedGoalsDialogState();
}

class _GeneratedGoalsDialogState extends State<GeneratedGoalsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Generated Goals'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            widget.goals.map((g) {
              return Row(
                children: [
                  Expanded(child: Text("• $g")),
                  IconButton(
                    onPressed: () {
                      // Remove goal from the list
                      setState(() {
                        widget.goals.remove(g);
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Add goals to track here

            final trackProvider = Provider.of<TrackProvider>(
              context,
              listen: false,
            );
            for (var g in widget.goals) {
              trackProvider.addGoal(g);
            }
          },
          child: Text("Add to Track"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
      ],
    );
  }
}
