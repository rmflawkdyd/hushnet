import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hushnet_flutter/app/app.dart';
import 'package:hushnet_flutter/resources/strings/app_strings.dart';

void main() {
  testWidgets('홈 화면이 렌더링되고 연결 버튼과 상태 라벨이 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HushnetApp()));
    await tester.pump();

    expect(find.text(AppStrings.appName), findsWidgets);
    expect(find.text(AppStrings.connect), findsOneWidget);
    expect(find.text(AppStrings.statusDisconnected), findsOneWidget);
  });
}
