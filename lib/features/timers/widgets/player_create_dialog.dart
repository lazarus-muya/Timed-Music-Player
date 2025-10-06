import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/core/constants/constatnts.dart';
import 'package:timed_app/data/models/player_timer.dart';
import 'package:timed_app/features/timers/providers/timer_provider.dart';

// ignore: must_be_immutable
class PlayerCreateDialog extends ConsumerWidget {
  PlayerCreateDialog({
    super.key,
    required this.nameController,
    required this.durationController,
    required this.selectedTime,
  });

  TextEditingController nameController;
  TextEditingController durationController;
  TimeOfDay selectedTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StatefulBuilder(
      builder: (context, setState) => Dialog(
        child: Container(
          height: 320,
          width: 400,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create Player Timer',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Timer Name',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text(
                  'Time',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  selectedTime.format(context),
                  style: const TextStyle(color: Colors.deepOrange),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
              TextField(
                controller: durationController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: 'Enter duration in minutes',
                  hintStyle: TextStyle(color: Colors.grey),
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
                        if (nameController.text.isNotEmpty &&
                            durationController.text.isNotEmpty) {
                          final durationMinutes = int.tryParse(
                            durationController.text,
                          );
                          if (durationMinutes != null && durationMinutes > 0) {
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
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid duration (positive number)',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Create',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
