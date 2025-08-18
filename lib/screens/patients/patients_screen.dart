import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/patient.dart';
import '../../widgets/patient_card.dart';
import 'patient_detail_screen.dart';
import 'add_patient_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PatientProvider, SettingsProvider>(
      builder: (context, patientProvider, settings, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(settings.translate('patients')),
            automaticallyImplyLeading: false,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'name',
                    child: Text('Sort by Name'),
                  ),
                  const PopupMenuItem(
                    value: 'recent',
                    child: Text('Sort by Recent'),
                  ),
                  const PopupMenuItem(
                    value: 'loyalty',
                    child: Text('Sort by Loyalty Points'),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                  color: _showFavoritesOnly ? Colors.red : null,
                ),
                onPressed: () {
                  setState(() {
                    _showFavoritesOnly = !_showFavoritesOnly;
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search patients...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              patientProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    patientProvider.setSearchQuery(value);
                  },
                ),
              ),
              
              // Stats Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Patients',
                        patientProvider.patients.length.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Active Today',
                        patientProvider.getPatientsWithRecentActivity().length.toString(),
                        Icons.today,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'VIP Members',
                        patientProvider.getPatientsWithHighLoyaltyPoints().length.toString(),
                        Icons.star,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Patients List
              Expanded(
                child: patientProvider.patients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _getSortedPatients(patientProvider.patients).length,
                        itemBuilder: (context, index) {
                          final patient = _getSortedPatients(patientProvider.patients)[index];
                          return PatientCard(
                            patient: patient,
                            onTap: () => _navigateToPatientDetail(patient),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToAddPatient(),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No patients found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first patient to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddPatient(),
            icon: const Icon(Icons.add),
            label: const Text('Add Patient'),
          ),
        ],
      ),
    );
  }

  List<Patient> _getSortedPatients(List<Patient> patients) {
    List<Patient> sortedPatients = List.from(patients);
    
    if (_showFavoritesOnly) {
      sortedPatients = sortedPatients.where((p) => p.loyaltyPoints > 100).toList();
    }
    
    switch (_sortBy) {
      case 'name':
        sortedPatients.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'recent':
        sortedPatients.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'loyalty':
        sortedPatients.sort((a, b) => b.loyaltyPoints.compareTo(a.loyaltyPoints));
        break;
    }
    
    return sortedPatients;
  }

  void _navigateToPatientDetail(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );
  }

  void _navigateToAddPatient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPatientScreen(),
      ),
    );
  }
}