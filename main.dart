import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';  // Import AdMob package
import 'VpnManager.dart';  // Import your VPN manager

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();  // Initialize Google Mobile Ads SDK
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VpnHomePage(),
    );
  }
}

class VpnHomePage extends StatefulWidget {
  @override
  _VpnHomePageState createState() => _VpnHomePageState();
}

class _VpnHomePageState extends State<VpnHomePage> {
  final VpnManager _vpnManager = VpnManager();
  bool _isVpnConnected = false;

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkVpnStatus();
    _loadBannerAd();
  }

  // Check VPN connection status
  void _checkVpnStatus() async {
    bool status = await _vpnManager.isVpnConnected();
    setState(() {
      _isVpnConnected = status;
    });
  }

  // Toggle VPN connection
  void _toggleVpn() async {
    if (_isVpnConnected) {
      await _vpnManager.disconnectVpn();
    } else {
      await _vpnManager.connectToJioVpn();
    }
    _checkVpnStatus();
  }

  // Load AdMob Banner Ad
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'your_banner_ad_unit_id',  // Replace with your actual Ad Unit ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();  // Dispose the banner ad when the widget is disposed
  }

  // Prevent app upgrade
  Future<void> _checkAppVersion() async {
    // Check app version logic, you could also integrate with Firebase Remote Config
    // or check version on a remote server to prevent upgrades.

    // For this example, we’ll check the app version with an arbitrary condition.
    const currentVersion = "1.0.0";  // Replace with your current app version
    const latestVersion = "1.0.0";  // Replace with the latest app version

    if (currentVersion != latestVersion) {
      _showUpgradeDialog();
    }
  }

  // Show upgrade prevention dialog
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("App Upgrade Not Allowed"),
          content: Text("This app version is no longer supported. Please update to the latest version."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the app or perform actions to prevent use
                Navigator.of(context).pop();
                // Optionally, close the app forcefully or block usage
                // SystemNavigator.pop(); // Uncomment to exit the app
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Call version check during app load
    _checkAppVersion();

    return Scaffold(
      appBar: AppBar(
        title: Text('Jio Tunnel VPN'),
        backgroundColor: Colors.transparent,  // Transparent app bar for a full hacker look
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          // Background Image (hacker theme)
          Positioned.fill(
            child: Image.asset(
              'assets/images/hacker_bg.jpg',  // Replace with your hacker-themed background image
              fit: BoxFit.cover,
            ),
          ),
          
          // Centered logo
          Positioned(
            top: 100,  // Adjust the positioning of your logo
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',  // Replace with your logo image path
                width: 150,  // Adjust logo size
                height: 150,
              ),
            ),
          ),

          // Main content (VPN button and AdMob banner)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // VPN toggle button
              ElevatedButton(
                onPressed: _toggleVpn,
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,  // Green button for the hacker theme
                ),
                child: Text(
                  _isVpnConnected ? 'Disconnect VPN' : 'Connect VPN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),

              // Display the banner ad
              if (_isBannerAdLoaded)
                Container(
                  alignment: Alignment.center,
                  child: AdWidget(ad: _bannerAd!),
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
