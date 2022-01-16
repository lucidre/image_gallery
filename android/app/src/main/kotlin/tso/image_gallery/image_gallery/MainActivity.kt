package tso.image_gallery.image_gallery
import android.app.DownloadManager
import android.os.Environment

import android.content.Context
import android.net.Uri

import android.widget.Toast
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity() {

    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        )
        methodChannel?.setMethodCallHandler { methodCall, result ->
            when (methodCall.method) {
                FILE_DOWNLOAD -> {
                    val fileUrl = methodCall.argument<String>(KEY_FILE_URL)
                    downloadFile(fileUrl)
                    result.success("file_downloaded")
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun downloadFile(fileUrl: String?) {

        if (fileUrl == null || fileUrl.isEmpty()) {
            return
        }

        val time = SimpleDateFormat(
            IMAGE_FORMAT,
            Locale.getDefault()
        ).format(System.currentTimeMillis())
        val imageName = "image_gallery_$time.png"
        val mDownloadManager = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        val request = DownloadManager.Request(Uri.parse(fileUrl))
        request.apply {
            setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
            setAllowedOverRoaming(false)
            setTitle(imageName)
            setDescription(null)
            setDestinationInExternalPublicDir(
                Environment.DIRECTORY_DOWNLOADS,
                File.separator + "image_gallery" + File.separator + "files" + File.separator + imageName
            )
            setAllowedNetworkTypes(DownloadManager.Request.NETWORK_WIFI or DownloadManager.Request.NETWORK_MOBILE)
        }
        mDownloadManager.enqueue(request)
    }

    companion object {
        private const val CHANNEL_NAME = "native_communication"
        private const val IMAGE_FORMAT = "yyyyMMdd_HHmmss"
        private const val FILE_DOWNLOAD = "downloadFile"
        private const val KEY_FILE_URL = "file_url"
    }
}
