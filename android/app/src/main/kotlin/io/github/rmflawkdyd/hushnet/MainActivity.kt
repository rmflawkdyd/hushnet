package io.github.rmflawkdyd.hushnet

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// wireguard_flutter_plus 1.0.6 의 checkVpnPermission 은 동의 인텐트에
// FLAG_ACTIVITY_NEW_TASK 를 붙여 startActivityForResult 를 호출한다. 그러면
// 안드로이드가 "launching as a new task, so cancelling activity result" 로
// 결과를 즉시 취소해 동의창이 뜨자마자 닫히고, 결과도 Dart 로 돌아오지 않는다.
// 권한 게이트는 이 앱 소유의 채널로 올바르게(NEW_TASK 없이) 요청·수신한다.
class MainActivity : FlutterActivity() {
    private val vpnPermissionChannelName = "hushnet/vpn_permission"
    private val vpnPermissionRequestCode = 0xA1
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            vpnPermissionChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasVpnPermission" -> result.success(VpnService.prepare(this) == null)
                "requestVpnPermission" -> requestVpnPermission(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun requestVpnPermission(result: MethodChannel.Result) {
        val consentIntent = VpnService.prepare(this)
        if (consentIntent == null) {
            result.success(true)
            return
        }
        if (pendingPermissionResult != null) {
            result.error(
                "ALREADY_REQUESTING",
                "A VPN permission request is already in progress",
                null,
            )
            return
        }
        pendingPermissionResult = result
        startActivityForResult(consentIntent, vpnPermissionRequestCode)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == vpnPermissionRequestCode) {
            pendingPermissionResult?.success(resultCode == Activity.RESULT_OK)
            pendingPermissionResult = null
        }
    }
}
