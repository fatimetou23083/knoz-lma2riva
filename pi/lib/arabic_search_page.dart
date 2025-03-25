// تصحيح بعض المشاكل في صفحة البحث العربية

import 'package:flutter/material.dart';
import 'search_result.dart';

class ArabicSearchPage extends StatefulWidget {
  final Future<List<String>> Function(String) onSearch;
  final List<String> searchResults;
  final List<SearchResult> searchResultsData;
  final bool isSearching;
  final void Function(BuildContext, SearchResult) onNavigate;

  const ArabicSearchPage({
    Key? key,
    required this.onSearch,
    required this.searchResults,
    required this.searchResultsData,
    required this.isSearching,
    required this.onNavigate,
  }) : super(key: key);

  @override
  _ArabicSearchPageState createState() => _ArabicSearchPageState();
}

class _ArabicSearchPageState extends State<ArabicSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _localIsSearching = false;
  List<String> _localSearchResults = [];
  List<SearchResult> _localSearchResultsData = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // يضبط التركيز على حقل البحث تلقائيًا عند فتح الصفحة
    Future.delayed(Duration(milliseconds: 200), () {
      if (_focusNode.hasListeners) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
    
    // تهيئة البيانات المحلية مع البيانات الأولية
    _localIsSearching = widget.isSearching;
    _localSearchResults = List.from(widget.searchResults);
    _localSearchResultsData = List.from(widget.searchResultsData);
    
    print("حالة البحث الأولية - نتائج: ${_localSearchResults.length}, بيانات: ${_localSearchResultsData.length}");
  }
  
  // دالة محلية للبحث تقوم بتحديث الحالة المحلية
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _localSearchResults = [];
        _localSearchResultsData = [];
        _localIsSearching = false;
        _errorMessage = '';
      });
      return;
    }
    
    setState(() {
      _localIsSearching = true;
      _errorMessage = '';
    });
    
    try {
      print("بدء البحث عن: '$query'");
      
      // استدعاء دالة البحث الخارجية
      final results = await widget.onSearch(query);
      
      // تحديث البيانات المحلية بعد اكتمال البحث
      setState(() {
        _localSearchResults = List.from(results);
        _localSearchResultsData = List.from(widget.searchResultsData);
        _localIsSearching = false;
      });
      
      print("النتائج المستلمة - عدد النتائج: ${results.length}, بيانات: ${widget.searchResultsData.length}");
      print("النتائج المحلية - عدد النتائج: ${_localSearchResults.length}, بيانات: ${_localSearchResultsData.length}");
    } catch (e) {
      print("خطأ في البحث: $e");
      setState(() {
        _localSearchResults = [];
        _localSearchResultsData = [];
        _errorMessage = 'حدث خطأ أثناء البحث: $e';
        _localIsSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF336B87),
          title: Text('البحث'),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Color(0xFF336B87),
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن كتاب أو فيديو...',
                    hintTextDirection: TextDirection.rtl,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    _performSearch(value);
                    setState(() {}); // تحديث الواجهة لإظهار زر المسح عند الحاجة
                  },
                ),
              ),
            ),
            
            // عرض رسالة الخطأ إذا وجدت
            if (_errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            
            // عرض عدد النتائج للتصحيح
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_localSearchResults.isNotEmpty && !_localIsSearching)
                    Text(
                      "تم العثور على ${_localSearchResults.length} نتيجة",
                      style: TextStyle(
                        color: Color(0xFF336B87),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_controller.text.isNotEmpty && !_localIsSearching)
                    Text(
                      "نتائج البحث عن: \"${_controller.text}\"",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            
            Expanded(
              child: _localIsSearching
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF336B87)),
                      ),
                    )
                  : _localSearchResults.isEmpty && _errorMessage.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _controller.text.isEmpty
                                    ? Icons.search
                                    : Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                _controller.text.isEmpty
                                    ? 'ابدأ البحث عن الكتب والفيديوهات'
                                    : 'لا توجد نتائج للبحث',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(16),
                          itemCount: _localSearchResults.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            if (index >= _localSearchResults.length) {
                              return SizedBox.shrink();  // تفادي أخطاء الفهرسة
                            }
                            
                            final result = _localSearchResults[index];
                            final isBook = result.startsWith("كتاب");
                            final isVideo = result.startsWith("فيديو");
                            final isScholar = result.startsWith("عالم");
                            
                            IconData iconData;
                            Color iconColor;
                            
                            if (isBook) {
                              iconData = Icons.book;
                              iconColor = const Color(0xFFA5C882);
                            } else if (isVideo) {
                              iconData = Icons.play_circle_outline;
                              iconColor = const Color(0xFF90AFC5);
                            } else if (isScholar) {
                              iconData = Icons.person;
                              iconColor = const Color(0xFF336B87);
                            } else {
                              iconData = Icons.search;
                              iconColor = Colors.grey;
                            }
                            
                            return ListTile(
                              leading: Icon(
                                iconData,
                                color: iconColor,
                                size: 28,
                              ),
                              title: Text(
                                result,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () {
                                print("النقر على نتيجة البحث: $result");
                                print("الفهرس: $index، إجمالي بيانات النتائج: ${_localSearchResultsData.length}");
                                
                                Navigator.pop(context);
                                if (index < _localSearchResultsData.length) {
                                  widget.onNavigate(context, _localSearchResultsData[index]);
                                } else {
                                  print("خطأ: فهرس خارج النطاق");
                                  // يمكن عرض رسالة خطأ للمستخدم هنا
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}