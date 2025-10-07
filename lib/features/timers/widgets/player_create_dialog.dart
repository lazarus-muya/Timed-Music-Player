import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/commons/widgets/spacer.dart';
import 'package:timed_app/core/constants/colors_constants.dart';
import 'package:timed_app/core/constants/constatnts.dart';
import 'package:timed_app/core/utils/extensions.dart';
import 'package:timed_app/data/models/player_timer.dart';
import 'package:timed_app/features/timers/providers/timer_provider.dart';

// ignore: must_be_immutable
class PlayerCreateDialog extends ConsumerWidget {
  PlayerCreateDialog({
    super.key,
    required this.nameController,
    required this.durationController,
    required this.selectedTime,
    required this.formKey,
  });

  TextEditingController nameController;
  TextEditingController durationController;
  TimeOfDay selectedTime;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StatefulBuilder(
      builder: (context, setState) => Dialog(
        child: Container(
          height: 350,
          width: 400,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create Player Timer'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  validator: (value) =>
                      value!.isEmpty ? 'Name is required' : null,
                  style: TextStyle(color: context.theme.iconTheme.color),
                  decoration: InputDecoration(
                    labelText: 'Timer Name',
                    labelStyle: TextStyle(color: context.theme.iconTheme.color),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.0),
                      borderSide: BorderSide(
                        color: context.theme.iconTheme.color!.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.0),
                      borderSide: BorderSide(color: BORDER_COLOR),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  spacing: 0.0,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                      child: Text('Select Pause Time'),
                    ),
                    Chip(
                      backgroundColor: context.theme.scaffoldBackgroundColor,
                      side: const BorderSide(color: Colors.transparent),
                      label: Text(
                        selectedTime.format(context),
                        style: TextStyle(
                          color: context.theme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                spacer(h: 10.0),
                spacer(h: 10.0),
                TextFormField(
                  controller: durationController,
                  style: TextStyle(color: context.theme.iconTheme.color),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Duration is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Duration (minutes)',
                    // filled: true,
                    // fillColor: context.theme.cardColor,
                    labelStyle: TextStyle(color: context.theme.iconTheme.color),
                    hintText: 'Enter duration in minutes',
                    hintStyle: TextStyle(color: context.theme.iconTheme.color),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.0),
                      borderSide: BorderSide(
                        color: context.theme.iconTheme.color!.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.0),
                      borderSide: BorderSide(color: BORDER_COLOR),
                    ),
                  ),
                  onChanged: (value) {
                    // Validate input - only allow numbers
                    if (value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                      // Remove non-numeric characters
                      durationController.value = durationController.value
                          .copyWith(
                            text: value.replaceAll(RegExp(r'[^\d]'), ''),
                            selection: TextSelection.collapsed(
                              offset: durationController.text.length,
                            ),
                          );
                    }
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 150.0,
                      height: 40.0,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150.0,
                      height: 40.0,
                      child: TextButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final durationMinutes = int.tryParse(
                              durationController.text,
                            );
                            if (durationMinutes != null &&
                                durationMinutes > 0) {
                              final timer = PlayerTimer(
                                id: uid.v4(),
                                name: nameController.text,
                                time: selectedTime,
                                duration: Duration(minutes: durationMinutes),
                                isActive: true,
                              );
                              ref
                                  .read(playerTimerProvider.notifier)
                                  .addPlayerTimer(timer);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          }
                          // if (nameController.text.isNotEmpty &&
                          //     durationController.text.isNotEmpty) {
                          //   final durationMinutes = int.tryParse(
                          //     durationController.text,
                          //   );
                          //   if (durationMinutes != null && durationMinutes > 0) {
                          //     final timer = PlayerTimer(
                          //       id: uid.v4(),
                          //       name: nameController.text,
                          //       time: selectedTime,
                          //       duration: Duration(minutes: durationMinutes),
                          //       isActive: true,
                          //     );
                          //     ref
                          //         .read(playerTimerProvider.notifier)
                          //         .addPlayerTimer(timer);
                          //     if (context.mounted) {
                          //       Navigator.pop(context);
                          //     }
                          //   } else {
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       const SnackBar(
                          //         content: Text(
                          //           'Please enter a valid duration (positive number)',
                          //         ),
                          //         backgroundColor: Colors.red,
                          //       ),
                          //     );
                          //   }
                          // } else {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(
                          //       content: Text('Please fill in all fields'),
                          //       backgroundColor: Colors.red,
                          //     ),
                          //   );
                          // }
                        },
                        child: Text(
                          'Create',
                          style: TextStyle(
                            color: context.theme.iconTheme.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
