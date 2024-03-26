import 'package:collevo/models/request.dart';
import 'package:flutter/material.dart';

class RejectedRequestCard extends StatelessWidget {
  final Request request;

  const RejectedRequestCard({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${request.activity} - ${request.activityLevel}'),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.black87,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    request.imageUrl,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rejection Reason:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          (request.optionalRemark == null ||
                                  request.optionalRemark!.isEmpty)
                              ? 'No reason provided'
                              : request.optionalRemark!,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created at:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${request.createdAt.day.toString().padLeft(2, '0')}:${request.createdAt.month.toString().padLeft(2, '0')}:${request.createdAt.year}    ${request.createdAt.hour.toString().padLeft(2, '0')}:${request.createdAt.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Activity Type:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          request.activityType,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Activity:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          request.activity,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Activity Level:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          request.activityLevel,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
