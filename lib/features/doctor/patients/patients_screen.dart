import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/communication_sheet.dart';
import '../../../widgets/mobile_header.dart';
import '../../../widgets/responsive_page_header.dart';
import '../../../shared/appointments_repository.dart';
import 'patients_provider.dart';

String _patientGenderLabel(String gender) {
  switch (gender.toUpperCase()) {
    case 'M':
      return 'Male';
    case 'F':
      return 'Female';
    default:
      return 'Other';
  }
}

String _formatPatientLastVisit(String rawValue) {
  if (rawValue.trim().isEmpty) return 'No visits yet';
  final parsed = DateTime.tryParse(rawValue);
  if (parsed == null) return rawValue;
  return DateFormat('d MMM yyyy', 'en_IN').format(parsed);
}

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  Future<void> _showAddPatientDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final emergencyNameController = TextEditingController();
    final emergencyPhoneController = TextEditingController();
    final customConditionController = TextEditingController();
    final allergiesController = TextEditingController();

    String gender = 'M';
    String bloodGroup = 'O+';
    String status = 'active';
    final selectedConditions = <String>{};
    String? validationError;
    final formKey = GlobalKey<FormState>();

    const commonConditions = [
      'Diabetes',
      'Hypertension',
      'Asthma',
      'Arthritis',
      'Thyroid',
      'Heart Disease',
      'Migraine',
      'Allergies',
    ];

    const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 36,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modal Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(28, 24, 20, 20),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradientHero,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Register New Patient',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Enter clinical and contact information for records & communication.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: AppColors.mutedForeground,
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Form Content
                    Flexible(
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (validationError != null) ...[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.destructive.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.destructive.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        size: 18,
                                        color: AppColors.destructive,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          validationError!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.destructive,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // SECTION 1: Personal Details
                              _FormSectionTitle(
                                icon: Icons.badge_rounded,
                                title: 'Personal Details',
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: nameController,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter patient full name';
                                  }
                                  if (val.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Full Name *',
                                  hintText: 'e.g. Ramesh Chandra Sharma',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: phoneController,
                                      keyboardType: TextInputType.phone,
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Phone number is required';
                                        }
                                        final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                                        if (digits.length < 10) {
                                          return 'Enter 10-digit mobile number';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Phone Number *',
                                        hintText: '10-digit mobile',
                                        prefixIcon: Icon(Icons.phone_rounded),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: ageController,
                                      keyboardType: TextInputType.number,
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Age is required';
                                        }
                                        final n = int.tryParse(val.trim());
                                        if (n == null || n <= 0 || n > 125) {
                                          return 'Age (1-125)';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Age *',
                                        hintText: 'Years',
                                        prefixIcon: Icon(Icons.cake_outlined),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                            // Gender Selector Pills
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Gender:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ...['M', 'F', 'O'].map((g) {
                                  final isSelected = gender == g;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(
                                        g == 'M' ? 'Male' : g == 'F' ? 'Female' : 'Other',
                                      ),
                                      selected: isSelected,
                                      selectedColor: AppColors.primary,
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : AppColors.foreground,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      onSelected: (val) {
                                        if (val) setState(() => gender = g);
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Blood Group Selector
                            Row(
                              children: [
                                Text(
                                  'Blood Group:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: bloodGroups.map((bg) {
                                        final isSelected = bloodGroup == bg;
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 6),
                                          child: ChoiceChip(
                                            label: Text(bg),
                                            selected: isSelected,
                                            selectedColor: AppColors.accent,
                                            labelStyle: TextStyle(
                                              color: isSelected ? Colors.white : AppColors.foreground,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                            onSelected: (val) {
                                              if (val) setState(() => bloodGroup = bg);
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // SECTION 2: Contact & Address
                            _FormSectionTitle(
                              icon: Icons.location_on_outlined,
                              title: 'Contact & Location',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val != null && val.trim().isNotEmpty) {
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                                    return 'Enter a valid email address';
                                  }
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Email (Optional)',
                                hintText: 'patient@example.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: addressController,
                              validator: (val) {
                                if (val != null && val.trim().isNotEmpty && val.trim().length < 3) {
                                  return 'Address must be at least 3 characters';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Residential Address / City',
                                hintText: 'e.g. 42 MG Road, Bangalore',
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: emergencyNameController,
                                    validator: (val) {
                                      if (val != null && val.trim().isNotEmpty && val.trim().length < 2) {
                                        return 'Name must be at least 2 characters';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Emergency Contact Person',
                                      hintText: 'Name & relation',
                                      prefixIcon: Icon(Icons.contact_emergency_outlined),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: emergencyPhoneController,
                                    keyboardType: TextInputType.phone,
                                    validator: (val) {
                                      if (val != null && val.trim().isNotEmpty) {
                                        final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                                        if (digits.length < 10) {
                                          return '10-digit number';
                                        }
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Emergency Phone',
                                      hintText: 'Contact number',
                                      prefixIcon: Icon(Icons.phone_in_talk_outlined),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // SECTION 3: Clinical & Medical History
                            _FormSectionTitle(
                              icon: Icons.medical_information_outlined,
                              title: 'Medical History & Conditions',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select any existing chronic conditions or known ailments:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: commonConditions.map((condition) {
                                final isSelected = selectedConditions.contains(condition);
                                return FilterChip(
                                  label: Text(condition),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryLight.withOpacity(0.6),
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.primary : AppColors.foreground,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  onSelected: (val) {
                                    setState(() {
                                      if (val) {
                                        selectedConditions.add(condition);
                                      } else {
                                        selectedConditions.remove(condition);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: customConditionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Other medical condition',
                                      hintText: 'Type and add',
                                      prefixIcon: Icon(Icons.add_circle_outline_rounded),
                                    ),
                                    onSubmitted: (val) {
                                      if (val.trim().isNotEmpty) {
                                        setState(() {
                                          selectedConditions.add(val.trim());
                                          customConditionController.clear();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  onPressed: () {
                                    final val = customConditionController.text.trim();
                                    if (val.isNotEmpty) {
                                      setState(() {
                                        selectedConditions.add(val);
                                        customConditionController.clear();
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: allergiesController,
                              decoration: const InputDecoration(
                                labelText: 'Known Allergies (comma separated)',
                                hintText: 'e.g. Penicillin, Peanuts, Latex',
                                prefixIcon: Icon(Icons.warning_amber_rounded),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Text(
                                  'Patient Status:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ChoiceChip(
                                  label: const Text('Active'),
                                  selected: status == 'active',
                                  selectedColor: AppColors.success.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: status == 'active' ? AppColors.success : AppColors.foreground,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  onSelected: (val) {
                                    if (val) setState(() => status = 'active');
                                  },
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Inactive'),
                                  selected: status == 'inactive',
                                  selectedColor: AppColors.muted,
                                  labelStyle: TextStyle(
                                    color: status == 'inactive' ? AppColors.mutedForeground : AppColors.foreground,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  onSelected: (val) {
                                    if (val) setState(() => status = 'inactive');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                    // Modal Action Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          AppButton(
                            label: 'Register Patient',
                            icon: Icons.check_circle_rounded,
                            onPressed: () {
                              if (!formKey.currentState!.validate()) {
                                setState(() => validationError = 'Please fix the errors in the highlighted fields.');
                                return;
                              }

                              final name = nameController.text.trim();
                              final age = int.tryParse(ageController.text.trim()) ?? 0;
                              final phone = phoneController.text.trim();

                              final allergies = allergiesController.text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();

                              context.read<PatientsProvider>().addPatient(
                                name: name,
                                age: age,
                                gender: gender,
                                phone: phone,
                                email: emailController.text.trim(),
                                bloodGroup: bloodGroup,
                                address: addressController.text.trim(),
                                emergencyContactName: emergencyNameController.text.trim(),
                                emergencyContactPhone: emergencyPhoneController.text.trim(),
                                conditions: selectedConditions.toList(),
                                allergies: allergies,
                                status: status,
                              );

                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            const MobileHeader(title: 'Patients', showSearch: false),
          if (isDesktop)
            ResponsivePageHeader(
              title: 'Patient Directory',
              subtitle: 'Manage records, health vaults, and history',
              actions: [
                const AppButton(
                  label: 'Export CSV',
                  icon: Icons.download_rounded,
                  variant: AppButtonVariant.outline,
                ),
                AppButton(
                  label: 'Add Patient',
                  icon: Icons.person_add_rounded,
                  onPressed: () => _showAddPatientDialog(context),
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
                      color: AppColors.muted.withValues(alpha: 0.5),
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        _TableHeader(flex: 3, label: 'PATIENT'),
                        _TableHeader(flex: 2, label: 'ID NUMBER'),
                        _TableHeader(flex: 2, label: 'CONTACT'),
                        _TableHeader(flex: 2, label: 'CONDITIONS'),
                        _TableHeader(flex: 2, label: 'LAST VISIT'),
                        _TableHeader(flex: 1, label: 'VISITS'),
                        _TableHeader(flex: 3, label: 'ACTIONS'),
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
                      children: [
                        Expanded(
                          child: Text(
                          'Showing ${filteredPatients.length} of ${provider.patients.length} patients',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            CommunicationSheet.show(
              context,
              recipientName: patient.name,
              recipientRole: 'Patient',
              phone: patient.phone,
              isScheduled: true,
              statusText: 'Patient Code: ${patient.patientId}',
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
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
                  children: [
                    Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patient.age}y • ${_patientGenderLabel(patient.gender)} • ${patient.totalVisits} visits',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      ),
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
                            Icons.badge_rounded,
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
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        CommunicationSheet.show(
                          context,
                          recipientName: patient.name,
                          recipientRole: 'Patient',
                          phone: patient.phone,
                          isScheduled: true,
                          statusText: 'Patient Code: ${patient.patientId}',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF25D366).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.phone_in_talk_rounded,
                              size: 12,
                              color: Color(0xFF25D366),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Call / Chat',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF25D366),
                              ),
                            ),
                          ],
                        ),
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
                            color: AppColors.warning.withValues(alpha: 0.15),
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
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _showPatientPrescriptionDialog(context, patient),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.medication_rounded, size: 14, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text(
                              'Add Rx / Prescription',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _completeConsultationForPatient(context, patient),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.task_alt_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Complete Consultation',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
          ),
        ),
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
    final lastVisit = _formatPatientLastVisit(patient.lastVisit);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            CommunicationSheet.show(
              context,
              recipientName: patient.name,
              recipientRole: 'Patient',
              phone: patient.phone,
              isScheduled: true,
              statusText: 'Patient Code: ${patient.patientId}',
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.muted.withValues(alpha: 0.4)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${patient.age}y • ${_patientGenderLabel(patient.gender)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        patient.patientId,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.qr_code_rounded,
                    size: 14,
                    color: AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                patient.phone,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: conditions.isNotEmpty
                    ? conditions.take(2).map((condition) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            condition,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warningForeground,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList()
                    : [
                        Text(
                          'None reported',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                lastVisit,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
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
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _showPatientPrescriptionDialog(context, patient),
                    icon: const Icon(
                      Icons.medication_rounded,
                      size: 17,
                      color: Color(0xFF10B981),
                    ),
                    tooltip: 'Add Rx / Prescription',
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _completeConsultationForPatient(context, patient),
                    icon: Icon(
                      Icons.task_alt_rounded,
                      size: 17,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Complete Consultation',
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      CommunicationSheet.show(
                        context,
                        recipientName: patient.name,
                        recipientRole: 'Patient',
                        phone: patient.phone,
                        isScheduled: true,
                        statusText: 'Patient Code: ${patient.patientId}',
                      );
                    },
                    icon: const Icon(
                      Icons.phone_in_talk_rounded,
                      size: 17,
                      color: Color(0xFF25D366),
                    ),
                    tooltip: 'WhatsApp / Call Patient',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              : AppColors.muted.withValues(alpha:0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.border,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha:0.3),
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
  const _TableHeader({required this.flex, required this.label});

  final int flex;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
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

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

Future<void> _showPatientPrescriptionDialog(
  BuildContext context,
  Patient patient,
) async {
  final repo = context.read<AppointmentsRepository>();
  // Find latest appointment for this patient
  final patientAppts = repo.all.where(
    (a) => a.patientId == patient.id || a.patientId == patient.userId,
  ).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  final latestAppt = patientAppts.isNotEmpty ? patientAppts.first : null;
  final prescriptionController =
      TextEditingController(text: latestAppt?.prescription ?? '');
  final notesController =
      TextEditingController(text: latestAppt?.doctorNotes ?? '');
  bool markCompleted = true;
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: 540,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.90,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.medication_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add Prescription & Notes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Patient: ${patient.name} (${patient.patientId})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Medications & Dosage *',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: prescriptionController,
                              maxLines: 4,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter medicine, dosage or prescription details';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText:
                                    'e.g. 1. Paracetamol 650mg - 1 tab after food TID x 3 days\n2. Azithromycin 500mg OD x 3 days',
                                hintStyle: TextStyle(
                                  color: AppColors.mutedForeground
                                      .withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: AppColors.muted.withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Clinical Advice / Doctor Notes',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: notesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    'e.g. Keep hydration high. Review in clinic if symptoms persist after 3 days.',
                                hintStyle: TextStyle(
                                  color: AppColors.mutedForeground
                                      .withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: AppColors.muted.withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.accent.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: markCompleted,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => setState(
                                      () => markCompleted = val ?? false,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Mark Patient Consultation as Completed',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withValues(alpha: 0.4),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.publish_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Publish Prescription',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            String apptId = latestAppt?.id ?? '';
                            if (apptId.isEmpty) {
                              // Create or register consultation appointment
                              await repo.addAppointment(
                                patientId: patient.id,
                                patient: patient.name,
                                doctor: 'Doctor',
                                doctorId: '',
                                specialty: 'General Medicine',
                                clinic: 'MentiFit Clinic',
                                date: DateTime.now(),
                                time: DateFormat('hh:mm a').format(DateTime.now()),
                                type: 'General Consultation',
                                duration: '20 min',
                                status: markCompleted ? 'Completed' : 'Confirmed',
                              );
                              final updated = repo.all.where(
                                (a) => a.patientId == patient.id,
                              ).toList();
                              if (updated.isNotEmpty) {
                                apptId = updated.last.id;
                              }
                            }
                            if (apptId.isNotEmpty) {
                              await repo.saveAppointmentPrescription(
                                appointmentId: apptId,
                                prescription: prescriptionController.text.trim(),
                                doctorNotes: notesController.text.trim(),
                                markCompleted: markCompleted,
                              );
                            }
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Prescription published for ${patient.name}! Patient can view it on their portal.',
                                  ),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _completeConsultationForPatient(
  BuildContext context,
  Patient patient,
) async {
  final repo = context.read<AppointmentsRepository>();
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.task_alt_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Complete Consultation'),
        ],
      ),
      content: Text(
        'Mark consultation for "${patient.name}" as completed?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogCtx).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );

  if (confirm == true && context.mounted) {
    // Find active appointments for this patient and complete them
    final patientAppts = repo.all.where(
      (a) => (a.patientId == patient.id || a.patientId == patient.userId) &&
          a.status != 'Completed',
    ).toList();

    for (final appt in patientAppts) {
      await repo.updateAppointmentStatus(appt.id, 'Completed');
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consultation with ${patient.name} marked as completed!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}
