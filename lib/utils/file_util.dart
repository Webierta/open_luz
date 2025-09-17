import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart' as httpdio;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class FileUtil {
  static const dirPVPC = 'PVPC';

  /*static Future<String> getAppDocDirPath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path;
  }*/

  static Future<String> pathTempDir() async {
    final dirTemp = await getTemporaryDirectory();
    return dirTemp.path;
  }

  static Future<httpdio.Response> downloadFilePVPC({
    required String fecha1,
    required String fecha2,
  }) async {
    var url =
        'https://api.esios.ree.es/archives/70/download_json?start_date=${fecha1}T00:00&end_date=${fecha2}T23:59&date_type=datos';
    // https://api.esios.ree.es/archives/70/download_json?start_date=2024-01-01T00:00&end_date=2024-12-31T23:59&date_type=datos
    final dio = httpdio.Dio();
    //final appDocDirPath = await getAppDocDirPath();
    final dirTempPath = await pathTempDir();
    if (fecha1 != fecha2) {
      final String fileName = '$fecha1-$fecha2.zip';
      return await dio.download(url, path.join(dirTempPath, fileName));
    } else {
      // final Directory appDocDirPVPC =
      final Directory dirTempPVPC = Directory(path.join(dirTempPath, dirPVPC));
      var dirTempPVPCPath = (await dirTempPVPC.exists())
          ? dirTempPVPC.path
          : (await dirTempPVPC.create(recursive: true)).path;
      final String fileName = '${fecha1.replaceAll('-', '')}.json';
      return await dio.download(url, path.join(dirTempPVPCPath, fileName));
    }
  }

  /*static requestDatosGeneracion({
    required String fecha1,
    required String fecha2,
  }) async {
    var url =
        'https://apidatos.ree.es/es/datos/balance/balance-electrico?start_date=${fecha1}T00:00&end_date=${fecha2}T23:59&time_trunc=day';
  }*/

  //static saveFile() {}

  static Future<List<File>> getFilesPVPC() async {
    //final appDocDirPath = await getAppDocDirPath();
    final dirTempPath = await pathTempDir();
    //final Directory appDocDirPVPC = Directory('$appDocDirPath/PVPC/');
    final Directory dirTempPVPC = Directory('$dirTempPath/$dirPVPC/');
    if (!await dirTempPVPC.exists()) return [];
    //if (appDocDirPVPC.path.isEmpty) return;
    //for (var file in appDocDirPVPC.path) {}
    var archivos = dirTempPVPC.listSync();
    // [File: '/data/user/0/com.github.webierta.tarifa_luz/app_flutter/PVPC/20250311.json', ...
    List<File> files = [];
    for (var fileSystem in archivos) {
      files.add(File(fileSystem.path));
    }
    return files;
  }

  static Future<({bool isSelect, File? fileCsv})> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      //allowedExtensions: ['csv'],
      //type: FileType.custom,
    );
    if (result == null) return (isSelect: false, fileCsv: null);
    File file = File(result.files.single.path!);
    if (path.extension(file.path) != '.csv') {
      return (isSelect: true, fileCsv: null);
    }
    return (isSelect: true, fileCsv: file);
  }

  static Future<List<List<dynamic>>> loadCsvData(String ruta) async {
    try {
      final csvFile = File(ruta).openRead();
      return await csvFile
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(fieldDelimiter: ';', eol: '\n'))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> extractZipPVPC(String fileName) async {
    //final appDocDirPath = await getAppDocDirPath();
    final dirTempPath = await pathTempDir();
    final ruta = path.join(dirTempPath, fileName);

    String dirTempPVPCPath = '';
    //final Directory appDocDirPVPC = Directory(path.join(appDocDirPath, 'PVPC'));
    final Directory dirTempPVPC = Directory(path.join(dirTempPath, dirPVPC));
    dirTempPVPCPath = (await dirTempPVPC.exists())
        ? dirTempPVPC.path
        : (await dirTempPVPC.create(recursive: true)).path;
    if (dirTempPVPCPath.isEmpty) return false;

    try {
      final bytes = File(ruta).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final ArchiveFile file in archive) {
        // PVPC_CURV_DD_20250423.txt.json => 20250423.json
        String nameFile = file.name
            .replaceAll('PVPC_CURV_DD_', '')
            .replaceAll('.txt', '');
        if (file.isFile) {
          //final fileBytes = file.readBytes();
          final data = file.content as List<int>;
          File(path.join(dirTempPVPCPath, nameFile))
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          return false;
        }
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  static Future<bool> deleteFile(String fileName) async {
    //final appDocDirPath = await getAppDocDirPath();
    final dirTempPath = await pathTempDir();
    var fileByName = File(path.join(dirTempPath, fileName));
    if (!await fileByName.exists()) return false;
    try {
      await fileByName.delete();
    } catch (e) {
      return false;
    }
    return true;
  }

  static Future<void> deleteDir() async {
    //final appDocDirPath = await getAppDocDirPath();
    final dirTempPath = await pathTempDir();
    final Directory dirTempPVPC = Directory('$dirTempPath/$dirPVPC/');
    if (!await dirTempPVPC.exists()) return;
    final dir = Directory(dirTempPVPC.path);
    dir.deleteSync(recursive: true);
    // await Directory(appDocDirPVPC.path).delete();
  }

  static Future<void> sharingScreenshot(
    ScreenshotController screenshotController,
  ) async {
    await screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((image) async {
          if (image != null) {
            //final directory = await getApplicationDocumentsDirectory();
            //final dirTemp = await getTemporaryDirectory();
            final dirTempPath = await pathTempDir();
            final imagePath = await File(
              '$dirTempPath/comparador.png',
            ).create();
            await imagePath.writeAsBytes(image);

            /// Share Plugin
            final params = ShareParams(
              text: 'Comparador de Tarifas Eléctricas',
              files: [XFile(imagePath.path)],
            );
            await SharePlus.instance.share(params);
            if (await imagePath.exists()) {
              try {
                await imagePath.delete();
              } catch (e) {
                return;
              }
            }
          }
        });
  }
}
