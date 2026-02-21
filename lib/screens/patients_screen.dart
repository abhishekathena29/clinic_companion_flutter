import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/patients_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_button.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/mobile_header.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  Future<void> _showAddPatientDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final phoneController = TextEditingController();
    final conditionsController = TextEditingController();
    String gender = 'F';
    String status = 'active';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Add Patient',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.people_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'F', child: Text('Female')),
                        DropdownMenuItem(value: 'M', child: Text('Male')),
                        DropdownMenuItem(value: 'O', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => gender = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.info_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Inactive'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => status = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: conditionsController,
                      decoration: const InputDecoration(
                        labelText: 'Conditions (comma separated)',
                        prefixIcon: Icon(Icons.medical_information_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                AppButton(
                  label: 'Add Patient',
                  onPressed: () {
                    final name = nameController.text.trim();
                    final age = int.tryParse(ageController.text.trim()) ?? 0;
                    final phone = phoneController.text.trim();
                    final conditions = conditionsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    if (name.isEmpty || age <= 0 || phone.isEmpty) {
                      return;
                    }

                    context.read<PatientsProvider>().addPatient(
                      name: name,
                      age: age,
                      gender: gender,
                      phone: phone,
                      conditions: conditions,
                      status: status,
                    );
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final provider = context.watch<PatientsProvider>();
    final filteredPatients = provider.filteredPatients;

    return DashboardLayout(
      routeName: '/patients',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            const MobileHeader(title: 'Patients', showSearch: false),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Directory',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage records, health vaults, and history',
                      style: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const AppButton(
                      label: 'Export CSV',
                      icon: Icons.download_rounded,
                      variant: AppButtonVariant.outline,
                    ),
                    const SizedBox(width: 16),
                    AppButton(
                      label: 'Add Patient',
                      icon: Icons.person_add_rounded,
                      onPressed: () => _showAddPatientDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          if (!isDesktop) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Patients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                AppButton(
                  label: 'Add',
                  icon: Icons.person_add_rounded,
                  size: AppButtonSize.small,
                  onPressed: () => _showAddPatientDialog(context),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Container(
            decoration: AppDecorations.card(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (!isDesktop)
                  TextField(
                    onChanged: provider.updateSearch,
                    decoration: InputDecoration(
                      hintText: 'Search patients...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                if (!isDesktop) const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _FilterPill(
                        label: 'All Patients',
                        isActive: provider.filter == PatientFilter.all,
                        onTap: () => provider.updateFilter(PatientFilter.all),
                      ),
                      const SizedBox(width: 12),
                      _FilterPill(
                        label: 'Chronic Cases',
                        isActive: provider.filter == PatientFilter.chronic,
                        onTap: () =>
                            provider.updateFilter(PatientFilter.chronic),
                      ),
                      const SizedBox(width: 12),
                      _FilterPill(
                        label: 'New Patients',
                        isActive: provider.filter == PatientFilter.newPatient,
                        onTap: () =>
                            provider.updateFilter(PatientFilter.newPatient),
                      ),
                    ],
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: provider.updateSearch,
                    decoration: InputDecoration(
                      hintText:
                          'Search by patient name, ID, or phone number...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!isDesktop)
            Column(
              children: filteredPatients.map((patient) {
                return _MobilePatientCard(patient: patient);
              }).toList(),
            )
          else
            Container(
              decoration: AppDecorations.card(),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.5),
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: const [
                        _TableHeader(width: 240, label: 'PATIENT'),
                        _TableHeader(width: 140, label: 'ID NUMBER'),
                        _TableHeader(width: 140, label: 'CONTACT'),
                        _TableHeader(width: 200, label: 'CONDITIONS'),
                        _TableHeader(width: 120, label: 'LAST VISIT'),
                        _TableHeader(width: 80, label: 'VISITS'),
                        _TableHeader(width: 140, label: ''),
                      ],
                    ),
                  ),
                  Column(
                    children: filteredPatients.map((patient) {
                      return _DesktopPatientRow(patient: patient);
                    }).toList(),
                  ),
                  if (filteredPatients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 48,
                            color: AppColors.mutedForeground,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No patients found matching your criteria',
                            style: TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${filteredPatients.length} of ${provider.patients.length} patients',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: const [
                            AppButton(
                              label: 'Prev',
                              variant: AppButtonVariant.ghost,
                              size: AppButtonSize.small,
                            ),
                            SizedBox(width: 8),
                            AppButton(
                              label: 'Next',
                              variant: AppButtonVariant.outline,
                              size: AppButtonSize.small,
                            ),
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
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Showing ${filteredPatients.length} of ${provider.patients.length} patients',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MobilePatientCard extends StatelessWidget {
  final Patient patient;
  const _MobilePatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final initials = patient.name
        .split(' ')
        .map((part) => part.substring(0, 1))
        .join();
    final conditions = patient.conditions;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                          patient.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${patient.age}y • ${patient.gender == 'M' ? 'Male' : 'Female'} • ${patient.totalVisits} visits",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.mutedForeground,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.qr_code_rounded,
                            size: 12,
                            color: AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            patient.patientId,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (conditions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...conditions.take(2).map((condition) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            condition,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.warningForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                      if (conditions.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            '+${conditions.length - 2} more',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
  }
}

class _DesktopPatientRow extends StatefulWidget {
  final Patient patient;
  const _DesktopPatientRow({required this.patient});
  @override
  State<_DesktopPatientRow> createState() => _DesktopPatientRowState();
}

class _DesktopPatientRowState extends State<_DesktopPatientRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final initials = patient.name
        .split(' ')
        .map((part) => part.substring(0, 1))
        .join();
    final conditions = patient.conditions;
    final lastVisit = DateFormat(
      'd MMM yyyy',
      'en_IN',
    ).format(DateTime.parse(patient.lastVisit));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.muted.withOpacity(0.4)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 240,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${patient.age}y • ${patient.gender == 'M' ? 'Male' : 'Female'}",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      patient.patientId,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.qr_code_rounded,
                    size: 16,
                    color: AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: Text(
                patient.phone,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 200,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: conditions.isNotEmpty
                    ? conditions.map((condition) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            condition,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.warningForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList()
                    : [
                        Text(
                          'None reported',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedForeground,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                lastVisit,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${patient.totalVisits}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.visibility_rounded,
                      size: 20,
                      color: AppColors.mutedForeground,
                    ),
                    tooltip: 'View Vault',
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.edit_rounded,
                      size: 20,
                      color: AppColors.mutedForeground,
                    ),
                    tooltip: 'Edit Profile',
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : AppColors.muted.withOpacity(0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.border,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive
                ? AppColors.primaryForeground
                : AppColors.mutedForeground,
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
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.mutedForeground,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
