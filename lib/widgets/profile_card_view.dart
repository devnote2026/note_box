import 'package:flutter/material.dart';

class ProfileCardView extends StatelessWidget {
  final String name;
  final String? department;
  final String? grade;
  final String? imageUrl;
  final VoidCallback onTap;

  const ProfileCardView({
    super.key,
    required this.name,
    this.department,
    this.grade,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text('${department ?? ''} ${grade ?? ''}'),
              ],
            ),

            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}