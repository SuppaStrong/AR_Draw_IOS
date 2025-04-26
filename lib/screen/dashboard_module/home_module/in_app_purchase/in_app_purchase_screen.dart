import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class InAppPurchaseScreen extends StatefulWidget {
  const InAppPurchaseScreen({super.key});

  @override
  State<InAppPurchaseScreen> createState() => _InAppPurchaseScreenState();
}

class _InAppPurchaseScreenState extends State<InAppPurchaseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;
  bool _isNotifyEnabled = false;
  int _selectedPlanIndex = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFloatingPremiumIcon(),
                      const SizedBox(height: 30),
                      _buildTitleSection(),
                      const SizedBox(height: 30),
                      _buildPricingPlans(),
                      const SizedBox(height: 24),
                      _buildFeatureList(),
                      const SizedBox(height: 20),
                      _buildNotifyMe(),
                      const SizedBox(height: 24),
                      _buildButtons(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              const Text(
                "Premium",
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: Color(0xFF1A1A1A),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingPremiumIcon() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, sin(_floatAnimation.value * 2 * 3.14159) * 10),
          child: child,
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF9C27B0),
              Color(0xFF673AB7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C27B0).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.sparkles,
            color: Colors.white,
            size: 46,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "Coming Soon",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Premium Features",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "We're working on amazing premium features to enhance your AR drawing experience",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingPlans() {
    final plans = [
      {"title": "Monthly", "price": "\$4.99", "period": "per month"},
      {
        "title": "Yearly",
        "price": "\$34.99",
        "period": "per year",
        "save": "Save 42%"
      },
      {
        "title": "Lifetime",
        "price": "\$69.99",
        "period": "one-time",
        "best": true
      },
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        itemCount: plans.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final plan = plans[index];
          final isSelected = index == _selectedPlanIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlanIndex = index;
              });
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF9C27B0).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  if (plan.containsKey('best'))
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "BEST DEAL",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          plan["title"] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plan["price"] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              plan["period"] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.black.withOpacity(0.6),
                                fontSize: 13,
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
          );
        },
      ),
    );
  }

  Widget _buildFeatureList() {
    List<Map<String, dynamic>> features = [
      {
        'icon': CupertinoIcons.add,
        'title': 'Ad-Free Experience',
        'description': 'Enjoy drawing without interruptions',
      },
      {
        'icon': CupertinoIcons.square_favorites_alt,
        'title': 'Exclusive Filters',
        'description': 'Access to premium drawing filters',
      },
      {
        'icon': CupertinoIcons.cloud_upload,
        'title': 'Cloud Storage',
        'description': 'Save and access your art anywhere',
      },
      {
        'icon': CupertinoIcons.wand_rays,
        'title': 'Advanced Effects',
        'description': 'Create stunning AR visuals with ease',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature['icon'],
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'],
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature['description'],
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotifyMe() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isNotifyEnabled = !_isNotifyEnabled;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CupertinoSwitch(
              value: _isNotifyEnabled,
              activeColor: const Color(0xFF673AB7),
              onChanged: (value) {
                setState(() {
                  _isNotifyEnabled = value;
                });
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notify me when it's ready",
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Get notified when we launch premium features",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 13,
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

  Widget _buildButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9C27B0),
                Color(0xFF673AB7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF673AB7).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isNotifyEnabled
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'We\'ll notify you when premium is available!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  : () {
                      Navigator.of(context).pop();
                    },
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  _isNotifyEnabled ? "Notify Me" : "Stay Tuned",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            "Continue with free version",
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
