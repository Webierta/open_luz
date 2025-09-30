import 'package:flutter/material.dart';

import '../../../theme/style_app.dart';
import '../../nav/pop_scope_helper.dart';
import 'services/api.dart';
import 'widgets/info_label.dart';
import 'models/product_groups.dart';
import 'widgets/product_not_found.dart';
import 'widgets/show_label.dart';

class LabelScreen extends StatefulWidget {
  const LabelScreen({super.key});
  @override
  State<LabelScreen> createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  TextEditingController controllerGrupo = TextEditingController();
  TextEditingController controllerMarca = TextEditingController();
  TextEditingController controllerModelo = TextEditingController();
  TextEditingController controllerModeloSuggested = TextEditingController();

  String? errorInputMarca;
  String? errorInputModelo;

  Widget label = const SizedBox(height: 0);
  ProductGroups productGroups = ProductGroups.washingmachines2019;

  @override
  initState() {
    controllerGrupo.text = productGroups.nombre;
    super.initState();
  }

  @override
  void dispose() {
    controllerGrupo.dispose();
    controllerMarca.dispose();
    controllerModelo.dispose();
    controllerModeloSuggested.dispose();
    super.dispose();
  }

  Future<void> buscar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      errorInputMarca = controllerMarca.text.trim().isEmpty
          ? 'Valor necesario'
          : null;
      errorInputModelo = controllerModelo.text.trim().isEmpty
          ? 'Valor necesario'
          : null;
      label = const SizedBox(height: 0);
    });
    if (controllerMarca.text.trim().isEmpty ||
        controllerModelo.text.trim().isEmpty) {
      return;
    }
    setState(() {
      //label = const SizedBox(height: 0);
      label = const Center(child: CircularProgressIndicator());
    });

    Api api = Api(
      marca: controllerMarca.text.trim(),
      modelo: controllerModelo.text.trim(),
      productGroups: productGroups.name,
    );
    await api.getApi();
    /* if (api.status == Status.networkError) {
      showSnack('Error de conexión. '
          'Comprueba tu conexión a internet o intentalo dentro de unos minutos.');
      return;
    } */
    if (api.status == StatusEprel.success &&
        api.formatLabel != FormatLabel.none) {
      setState(() => label = ShowLabel(api: api));
    } else {
      if (api.productSimilares.isNotEmpty) {
        controllerModeloSuggested.text = api.productSimilares.first;
      }
      setState(() {
        label = ProductNotFound(
          api: api,
          controllerModelo: controllerModelo,
          controllerModeloSuggested: controllerModeloSuggested,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: PopScopeHelper.onPopInvoked(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Etiqueta energética'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InfoLabel()),
                );
              },
              icon: const Icon(Icons.info),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            decoration: StyleApp.mainDecoration,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Consigue online la etiqueta energética de un aparato eléctrico para conocer '
                      'su eficiencia energética.',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    readOnly: true,
                    controller: controllerGrupo,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: InputDecoration(
                      filled: true,
                      //fillColor: StyleApp.blueGrey200,
                      prefixIcon: Image.asset(
                        productGroups.imagen,
                        color: Colors.white,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        maxWidth: 100,
                      ),
                      suffixIcon: PopupMenuButton<ProductGroups>(
                        initialValue: productGroups,
                        icon: const CircleAvatar(
                          child: Icon(Icons.expand_more),
                        ),
                        itemBuilder: (context) {
                          return ProductGroups.values
                              .map(
                                (grupo) => PopupMenuItem<ProductGroups>(
                                  value: grupo,
                                  child: ListTile(
                                    leading: Image.asset(
                                      grupo.imagen,
                                      color: Colors.white,
                                    ),
                                    title: Text(grupo.nombre),
                                  ),
                                ),
                              )
                              .toList();
                        },
                        onSelected: (product) {
                          if (product.nombre != controllerGrupo.text) {
                            controllerGrupo.text = product.nombre.replaceFirst(
                              ' ',
                              '\n',
                            );
                            setState(() {
                              errorInputMarca = null;
                              errorInputModelo = null;
                              controllerMarca.clear();
                              controllerModelo.clear();
                              controllerModeloSuggested.clear();
                              label = const SizedBox(height: 0);
                              productGroups = product;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controllerMarca,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Marca',
                      labelStyle: const TextStyle(height: -0.4),
                      errorText: errorInputMarca,
                      suffixIcon: IconButton(
                        onPressed: () {
                          controllerMarca.clear();
                        },
                        icon: const Icon(Icons.backspace),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controllerModelo,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Modelo',
                      labelStyle: const TextStyle(height: -0.4),
                      errorText: errorInputModelo,
                      suffixIcon: IconButton(
                        onPressed: () {
                          controllerModelo.clear();
                        },
                        icon: const Icon(Icons.backspace),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: StyleApp.buttonStyle,
                    icon: Icon(Icons.search),
                    onPressed: buscar,
                    label: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text('BUSCAR'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Flexible(child: label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
