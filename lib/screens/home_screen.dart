import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hertzmobile/config/theme.dart';
import 'package:provider/provider.dart';
import 'package:hertzmobile/providers/auth_provider.dart';
import 'package:hertzmobile/providers/switches_provider.dart';
import 'package:hertzmobile/screens/voice_recorder_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SwitchesProvider>().fetchAllSwitches();
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text(
                'Logout',
                style: TextStyle(color: AppColors.errorColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (authProvider.user?.name ?? 'U')[0].toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  authProvider.user?.name ?? 'User',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  authProvider.user?.email ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.mic, color: AppColors.primaryColor),
            title: const Text('Voice Command'),
            subtitle: const Text('Record and send voice commands'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              showDialog(
                context: context,
                builder: (_) => const VoiceRecorderDialog(),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: AppColors.textSecondary),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Navigate to settings
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: AppColors.textSecondary),
            title: const Text('Help & Feedback'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Show help
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.errorColor),
            title: Text(
              'Logout',
              style: TextStyle(color: AppColors.errorColor),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SwitchesProvider>().fetchAllSwitches();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Consumer2<AuthProvider, SwitchesProvider>(
        builder: (context, authProvider, switchesProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          authProvider.user?.name ?? 'User',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          authProvider.user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Switches Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Smart Switches',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (switchesProvider.switches.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${switchesProvider.switches.length} devices',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Loading State
                  if (switchesProvider.isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 60.h),
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  // Error State
                  else if (switchesProvider.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.errorColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error Loading Switches',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.errorColor),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            switchesProvider.errorMessage ?? 'Unknown error',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                switchesProvider.fetchAllSwitches();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorColor,
                              ),
                              child: const Text('Retry'),
                            ),
                          ),
                        ],
                      ),
                    )
                  // Empty State
                  else if (switchesProvider.switches.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(40.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 64.sp,
                            color: AppColors.textLight,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No switches available',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  // Switches Grid
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.95,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemCount: switchesProvider.switches.length,
                      itemBuilder: (context, index) {
                        final switchItem = switchesProvider.switches[index];
                        return _buildSwitchCard(
                          context,
                          switchItem,
                          switchesProvider,
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchCard(
    BuildContext context,
    dynamic switchItem,
    SwitchesProvider switchesProvider,
  ) {
    final switchId = switchItem.id;
    final isOn = switchItem.status;
    final isUpdating = switchesProvider.isUpdating(switchId);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isOn ? AppColors.primaryColor : AppColors.dividerColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOn ? AppColors.primaryColor : Colors.black).withValues(
              alpha: isOn ? 0.15 : 0.05,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUpdating
              ? null
              : () {
                  switchesProvider.updateSwitchStatus(switchId, !isOn);
                },
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Section - Icon and Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isOn
                            ? AppColors.primaryColor.withValues(alpha: 0.15)
                            : AppColors.textLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                        color: isOn
                            ? AppColors.primaryColor
                            : AppColors.textLight,
                        size: 24.sp,
                      ),
                    ),
                    if (isUpdating)
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isOn
                              ? AppColors.successColor.withValues(alpha: 0.2)
                              : AppColors.textLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          isOn ? 'ON' : 'OFF',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isOn
                                    ? AppColors.successColor
                                    : AppColors.textLight,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                  ],
                ),

                // Middle Section - Switch Toggle
                Transform.scale(
                  scale: 1.0,
                  child: Switch(
                    value: isOn,
                    onChanged: isUpdating
                        ? null
                        : (value) {
                            switchesProvider.updateSwitchStatus(
                              switchId,
                              value,
                            );
                          },
                    activeThumbColor: AppColors.primaryColor,
                    activeTrackColor: AppColors.primaryColor.withValues(
                      alpha: 0.3,
                    ),
                    inactiveThumbColor: AppColors.textLight,
                    inactiveTrackColor: AppColors.dividerColor,
                  ),
                ),

                // Bottom Section - Switch ID
                Text(
                  'Switch #$switchId',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
