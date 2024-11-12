import 'package:flutter/material.dart';
import 'package:mushu_pos/branches/branches_screen.dart';
import 'package:mushu_pos/brands/brands_screen.dart';
import 'package:mushu_pos/categories/categories_screen.dart';
import 'package:mushu_pos/clients/clients_screen.dart';
import 'package:mushu_pos/dashboard/dashboard_screen.dart';
import 'package:mushu_pos/historic_prices/historic_prices_screen.dart';
import 'package:mushu_pos/login/login_screen.dart';
import 'package:mushu_pos/products/products_screen.dart';
import 'package:mushu_pos/providers/providers_screen.dart';
import 'package:mushu_pos/purchases/purchases_screen.dart';
import 'package:mushu_pos/roles/roles_screen.dart';
import 'package:mushu_pos/sales/sales_screen.dart';
import 'package:mushu_pos/users/users_screen.dart';

class HomeBody extends StatefulWidget {
  // final String userName;

  const HomeBody({
    Key? key,
    // required this.userName,
  }) : super(key: key);

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  Widget _currentContent = const Center(
    child: Text(
      'Select an option from the menu',
      style: TextStyle(fontSize: 18),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side menu
          Container(
            width: 250,
            color: Colors.blue[900],
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'images/point-of-sale.png',
                      height: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const DashboardScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.category,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const CategoriesScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.maps_home_work_outlined,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Brands',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const BrandsScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.paste_rounded,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Products',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const ProductsScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.price_change,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Historic Prices',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const HistoricPricesScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.business_center,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Providers',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const ProvidersScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.people,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Clients',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const ClientsScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.add_card,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Purchases',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const PurchasesScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Sales',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const SalesScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.add_business,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Branches',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const BranchesScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.people,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Users',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const UsersScreen(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.manage_accounts,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Roles',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => setState(
                    () => _currentContent = const RolesScreen(),
                  ),
                ),
              ],
            ),
          ),
          // Right side content
          Expanded(
            child: Column(
              children: [
                // Top navigation bar
                Container(
                  height: 60,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Welcome, ',
                          // 'Welcome, ${widget.userName}',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.logout, color: Colors.blue[900]),
                          onPressed: () => null
                          // _logout(context),
                          ),
                    ],
                  ),
                ),
                // Content area
                Expanded(child: _currentContent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}
