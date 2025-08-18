import 'package:flutter/material.dart';
import '../models/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      _getAvatarColor(patient.name),
                      _getAvatarColor(patient.name).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    _getInitials(patient.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            patient.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (patient.loyaltyPoints > 100)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'VIP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${patient.docType}: ${patient.docNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (patient.phone != null) ...[
                      const SizedBox(height: 2),\n                      Row(\n                        children: [\n                          Icon(\n                            Icons.phone,\n                            size: 14,\n                            color: Colors.grey[500],\n                          ),\n                          const SizedBox(width: 4),\n                          Text(\n                            patient.phone!,\n                            style: TextStyle(\n                              fontSize: 13,\n                              color: Colors.grey[500],\n                            ),\n                          ),\n                        ],\n                      ),\n                    ],\n                  ],\n                ),\n              ),\n              \n              const SizedBox(width: 12),\n              \n              // Quick Info Column\n              Column(\n                children: [\n                  // Loyalty Points\n                  Container(\n                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),\n                    decoration: BoxDecoration(\n                      color: Colors.green.withOpacity(0.1),\n                      borderRadius: BorderRadius.circular(12),\n                    ),\n                    child: Row(\n                      mainAxisSize: MainAxisSize.min,\n                      children: [\n                        Icon(\n                          Icons.star,\n                          size: 12,\n                          color: Colors.green[700],\n                        ),\n                        const SizedBox(width: 4),\n                        Text(\n                          patient.loyaltyPoints.toString(),\n                          style: TextStyle(\n                            fontSize: 11,\n                            fontWeight: FontWeight.w600,\n                            color: Colors.green[700],\n                          ),\n                        ),\n                      ],\n                    ),\n                  ),\n                  \n                  const SizedBox(height: 8),\n                  \n                  // Internal Notes Indicator\n                  if (patient.internalNotes.isNotEmpty)\n                    Container(\n                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),\n                      decoration: BoxDecoration(\n                        color: Colors.orange.withOpacity(0.1),\n                        borderRadius: BorderRadius.circular(12),\n                      ),\n                      child: Row(\n                        mainAxisSize: MainAxisSize.min,\n                        children: [\n                          Icon(\n                            Icons.note,\n                            size: 12,\n                            color: Colors.orange[700],\n                          ),\n                          const SizedBox(width: 4),\n                          Text(\n                            patient.internalNotes.length.toString(),\n                            style: TextStyle(\n                              fontSize: 11,\n                              fontWeight: FontWeight.w600,\n                              color: Colors.orange[700],\n                            ),\n                          ),\n                        ],\n                      ),\n                    ),\n                  \n                  // Allergies Indicator\n                  if (patient.allergies.isNotEmpty) ..[\n                    const SizedBox(height: 4),\n                    Container(\n                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),\n                      decoration: BoxDecoration(\n                        color: Colors.red.withOpacity(0.1),\n                        borderRadius: BorderRadius.circular(12),\n                      ),\n                      child: Row(\n                        mainAxisSize: MainAxisSize.min,\n                        children: [\n                          Icon(\n                            Icons.warning,\n                            size: 12,\n                            color: Colors.red[700],\n                          ),\n                          const SizedBox(width: 4),\n                          Text(\n                            'Allergy',\n                            style: TextStyle(\n                              fontSize: 9,\n                              fontWeight: FontWeight.w600,\n                              color: Colors.red[700],\n                            ),\n                          ),\n                        ],\n                      ),\n                    ),\n                  ],\n                ],\n              ),\n              \n              const SizedBox(width: 8),\n              \n              // Arrow Icon\n              Icon(\n                Icons.arrow_forward_ios,\n                size: 16,\n                color: Colors.grey[400],\n              ),\n            ],\n          ),\n        ),\n      ),\n    );\n  }\n\n  String _getInitials(String name) {\n    List<String> parts = name.split(' ');\n    if (parts.length >= 2) {\n      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();\n    }\n    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();\n  }\n\n  Color _getAvatarColor(String name) {\n    final colors = [\n      Colors.blue,\n      Colors.green,\n      Colors.purple,\n      Colors.orange,\n      Colors.teal,\n      Colors.indigo,\n      Colors.pink,\n      Colors.cyan,\n    ];\n    \n    final index = name.hashCode % colors.length;\n    return colors[index.abs()];\n  }\n}