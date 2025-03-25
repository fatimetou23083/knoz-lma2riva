import 'package:flutter/material.dart';


class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _isOptionsVisible = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('من نحن'),
        centerTitle: true,
          automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF336B87),

        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              setState(() {
                _isOptionsVisible = !_isOptionsVisible;
              });
            },
            iconSize: 20,
            color: Colors.white,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/supnum.jpg'),
                  ),
                  SizedBox(height: 20),
                  // Text(
                  //   'من نحن',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //     fontFamily: 'Cairo',
                  //     color: Colors.indigo,
                  //   ),
                  // ),
                  SizedBox(height: 10),
                  Text(
                    'نحن طلاب المعهد العالي للرقمنة، عملنا على ابتكار هذا التطبيق ليكون وسيلة ميسّرة تسهم في نشر العلم وتيسير الوصول إليه للجميع. نسأل الله عز وجل أن يمنّ علينا وعليكم بالتوفيق والسداد فيما يحبه ويرضاه، ونرجو منكم أن تشملونا بدعواتكم الطيبة',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Cairo',
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor:Colors.deepPurple,
                  //   ),
                  //   child: Text('رجوع'),
                  // ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            right: _isOptionsVisible ? 0 : -200,
            top: 0,
            bottom: 0,
            child: Container(
              width: 180,
              
              color: Color(0xFF336B87),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    color: Color(0xFF336B87),
                  ),
                  _buildOption(
                    "الواجهة",
                    Icons.home,
                    onTap: () => Navigator.pushNamed(context, '/'),
                  ),
                  _buildOption(
                    "المكتبة",
                    Icons.library_books,
                    onTap: () => Navigator.pushNamed(context, '/library'),
                  ),
                  // _buildOption(
                  //   "من نحن",
                  //   Icons.info,
                  //   onTap: () => Navigator.pushNamed(context, '/about'),
                  // ),
                  _buildOption("المفضلة", Icons.favorite, onTap:() => Navigator.pushNamed(context, '/favorites')),
                  _buildOption(
                    "العلماء",
                    Icons.people,
                    onTap: () => Navigator.pushNamed(context, '/scholars'),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }





  Widget _buildOption(String title, IconData icon, {VoidCallback? onTap}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
        onTap: onTap ?? () {
          print("تم اختيار: $title");
        },
      ),
    );
  }
}

