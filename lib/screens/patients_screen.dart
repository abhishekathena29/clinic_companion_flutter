import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_button.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/mobile_header.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _patients = [
    {
      'id': '1',
      'patientId': 'SV-2024-001',
      'name': 'Priya Sharma',
      'age': 45,
      'gender': 'F',
      'phone': '+91 98765 43210',
      'lastVisit': '2024-01-15',
      'totalVisits': 12,
      'conditions': ['Diabetes Type 2', 'Hypertension'],
      'status': 'active',
    },
    {
      'id': '2',
      'patientId': 'SV-2024-042',
      'name': 'Amit Patel',
      'age': 32,
      'gender': 'M',
      'phone': '+91 87654 32109',
      'lastVisit': '2024-01-14',
      'totalVisits': 5,
      'conditions': ['Asthma'],
      'status': 'active',
    },
    {
      'id': '3',
      'patientId': 'SV-2024-089',
      'name': 'Sunita Devi',
      'age': 58,
      'gender': 'F',
      'phone': '+91 76543 21098',
      'lastVisit': '2024-01-12',
      'totalVisits': 28,
      'conditions': ['Hypertension', 'Arthritis', 'Thyroid'],
      'status': 'active',
    },
    {
      'id': '4',
      'patientId': 'SV-2024-156',
      'name': 'Rahul Singh',
      'age': 28,
      'gender': 'M',
      'phone': '+91 65432 10987',
      'lastVisit': '2024-01-10',
      'totalVisits': 2,
      'conditions': <String>[],
      'status': 'active',
    },
    {
      'id': '5',
      'patientId': 'SV-2024-203',
      'name': 'Meera Joshi',
      'age': 52,
      'gender': 'F',
      'phone': '+91 54321 09876',
      'lastVisit': '2024-01-08',
      'totalVisits': 15,
      'conditions': ['Diabetes Type 2'],
      'status': 'active',
    },
    {
      'id': '6',
      'patientId': 'SV-2024-267',
      'name': 'Vikram Rao',
      'age': 41,
      'gender': 'M',
      'phone': '+91 43210 98765',
      'lastVisit': '2023-12-20',
      'totalVisits': 8,
      'conditions': ['High Cholesterol'],
      'status': 'inactive',
    },
  ];

  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  List<Map<String, dynamic>> get _filteredPatients {
    return _patients.where((patient) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = (patient['name'] as String).toLowerCase().contains(query) ||
          (patient['patientId'] as String).toLowerCase().contains(query) ||
          (patient['phone'] as String).contains(query);

      if (_selectedFilter == 'chronic') {
        return matchesSearch && (patient['conditions'] as List).isNotEmpty;
      }
      if (_selectedFilter == 'new') {
        return matchesSearch && (patient['totalVisits'] as int) <= 2;
      }
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final filteredPatients = _filteredPatients;

    return DashboardLayout(
      routeName: '/patients',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop) const MobileHeader(title: 'Patients', showSearch: false),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Patients', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      'Manage patient records and health vaults',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    AppButton(label: 'Export', icon: Icons.download, variant: AppButtonVariant.outline),
                    SizedBox(width: 12),
                    AppButton(label: 'Add Patient', icon: Icons.add),
                  ],
                ),
              ],
            ),
          if (!isDesktop) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('All Patients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                AppButton(label: 'Add', icon: Icons.add, size: AppButtonSize.small),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Container(
            decoration: AppDecorations.card(),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (!isDesktop)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(AppColors.borderRadius),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search patients...',
                        hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                        prefixIcon: Icon(Icons.search, size: 18, color: AppColors.mutedForeground),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                if (!isDesktop) const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterPill(
                        label: 'All',
                        isActive: _selectedFilter == 'all',
                        onTap: () => setState(() => _selectedFilter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Chronic',
                        isActive: _selectedFilter == 'chronic',
                        onTap: () => setState(() => _selectedFilter = 'chronic'),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'New',
                        isActive: _selectedFilter == 'new',
                        onTap: () => setState(() => _selectedFilter = 'new'),
                      ),
                    ],
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppColors.borderRadius),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search by name, patient ID, or phone...',
                        hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                        prefixIcon: Icon(Icons.search, size: 18, color: AppColors.mutedForeground),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!isDesktop)
            Column(
              children: filteredPatients.map((patient) {
                final initials = (patient['name'] as String)
                    .split(' ')
                    .map((part) => part.substring(0, 1))
                    .join();
                final conditions = patient['conditions'] as List<String>;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: AppDecorations.card(),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      patient['name'] as String,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${patient['age']}y - ${patient['gender'] == 'M' ? 'Male' : 'Female'} - ${patient['totalVisits']} visits",
                                      style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right, color: AppColors.mutedForeground),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.muted,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    patient['patientId'] as String,
                                    style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.qr_code, size: 16, color: AppColors.mutedForeground),
                              ],
                            ),
                            if (conditions.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: [
                                  ...conditions.take(2).map((condition) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        condition,
                                        style: TextStyle(fontSize: 11, color: AppColors.warning),
                                      ),
                                    );
                                  }),
                                  if (conditions.length > 2)
                                    Text(
                                      '+${conditions.length - 2}',
                                      style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Container(
              decoration: AppDecorations.card(),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.5),
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: const [
                        _TableHeader(width: 220, label: 'Patient'),
                        _TableHeader(width: 140, label: 'Patient ID'),
                        _TableHeader(width: 140, label: 'Contact'),
                        _TableHeader(width: 200, label: 'Conditions'),
                        _TableHeader(width: 120, label: 'Last Visit'),
                        _TableHeader(width: 80, label: 'Visits'),
                        _TableHeader(width: 120, label: 'Actions'),
                      ],
                    ),
                  ),
                  Column(
                    children: filteredPatients.map((patient) {
                      final initials = (patient['name'] as String)
                          .split(' ')
                          .map((part) => part.substring(0, 1))
                          .join();
                      final conditions = patient['conditions'] as List<String>;
                      final lastVisit = DateFormat('d MMM yyyy', 'en_IN')
                          .format(DateTime.parse(patient['lastVisit'] as String));

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.7))),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 220,
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      initials,
                                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(patient['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(
                                        "${patient['age']}y - ${patient['gender'] == 'M' ? 'Male' : 'Female'}",
                                        style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.muted,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      patient['patientId'] as String,
                                      style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.qr_code, size: 16, color: AppColors.mutedForeground),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Text(patient['phone'] as String, style: const TextStyle(fontSize: 12)),
                            ),
                            SizedBox(
                              width: 200,
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: conditions.isNotEmpty
                                    ? conditions.map((condition) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            condition,
                                            style: TextStyle(fontSize: 11, color: AppColors.warning),
                                          ),
                                        );
                                      }).toList()
                                    : [
                                        Text('None', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                      ],
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(lastVisit, style: const TextStyle(fontSize: 12)),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                '${patient['totalVisits']}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.visibility, size: 18, color: AppColors.mutedForeground),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.edit, size: 18, color: AppColors.mutedForeground),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.calendar_today, size: 18, color: AppColors.mutedForeground),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (filteredPatients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No patients found matching your criteria',
                        style: TextStyle(color: AppColors.mutedForeground),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${filteredPatients.length} of ${_patients.length} patients',
                          style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                        ),
                        Row(
                          children: const [
                            AppButton(label: 'Previous', variant: AppButtonVariant.outline, size: AppButtonSize.small),
                            SizedBox(width: 8),
                            AppButton(label: 'Next', variant: AppButtonVariant.outline, size: AppButtonSize.small),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (!isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Showing ${filteredPatients.length} of ${_patients.length} patients',
                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primaryForeground : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.width, required this.label});

  final double width;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground),
      ),
    );
  }
}
