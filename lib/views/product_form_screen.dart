import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageURlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _formData = Map<String, Object>();

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final product = ModalRoute.of(context).settings.arguments as Product;

      if (product == null) return;

      _formData['id'] = product.id;
      _formData['title'] = product.title;
      _formData['description'] = product.description;
      _formData['price'] = product.price;
      _formData['imageUrl'] = product.imageUrl;

      _imageURlController.text = _formData['imageUrl'];
    }
  }

  void _updateImageUrl() {
    if (isValidImageUrl(_imageURlController.text)) {
      setState(() {});
    }
  }

  bool isValidImageUrl(String url) {
    bool isValidProtocol = url.toLowerCase().startsWith('http://') ||
        url.toLowerCase().startsWith('https://');
    bool endsWithPng = url.toLowerCase().endsWith('.png');
    bool endsWithJpg = url.toLowerCase().endsWith('.jpg');
    bool endsWithJpeg = url.toLowerCase().endsWith('.jpeg');

    return isValidProtocol && (endsWithPng || endsWithJpg || endsWithJpeg);
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

  void _saveForm() {
    if (!_form.currentState.validate()) return;

    _form.currentState.save();
    final product = Product(
      id: _formData['id'],
      title: _formData['title'],
      description: _formData['description'],
      price: _formData['price'],
      imageUrl: _formData['imageUrl'],
    );
    print(product.title);

    final products = Provider.of<Products>(context, listen: false);

    if (_formData['id'] == null) {
      products.addProduct(product);
    } else {
      products.update(product);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formuário Produto'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveForm(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _form,
          child: Container(
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value.trim().isEmpty) return 'Informe um título';
                    if (value.trim().length <= 3)
                      return 'Informe um título com no mínimo 3 letras';

                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_priceFocusNode),
                  onSaved: (value) => _formData['title'] = value,
                  initialValue: _formData['title'],
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Preço'),
                  validator: (value) {
                    if (value.trim().isEmpty) return 'Informe um preço';
                    if (double.tryParse(value) == null ||
                        double.tryParse(value) <= 0) {
                      return 'Valor inválido';
                    }

                    return null;
                  },
                  focusNode: _priceFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onFieldSubmitted: (_) => FocusScope.of(context)
                      .requestFocus(_descriptionFocusNode),
                  onSaved: (value) => _formData['price'] = double.parse(value),
                  initialValue: _formData['price'] != null
                      ? _formData['price'].toString()
                      : '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Descrição'),
                  validator: (value) {
                    if (value.trim().isEmpty) return 'Informe uma descrição';
                    if (value.trim().length <= 3)
                      return 'Informe uma descrição com no mínimo 3 letras';

                    return null;
                  },
                  focusNode: _descriptionFocusNode,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  onSaved: (value) => _formData['description'] = value,
                  initialValue: _formData['description'],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'URL da Imagem'),
                        validator: (value) {
                          if (value.trim().isEmpty ||
                              !isValidImageUrl(value.trim())) {
                            return 'Informe uma url válida';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        focusNode: _imageUrlFocusNode,
                        controller: _imageURlController,
                        onFieldSubmitted: (_) {
                          _saveForm();
                        },
                        onSaved: (value) => _formData['imageUrl'] = value,
                      ),
                    ),
                    Container(
                      height: 100,
                      width: 100,
                      margin: EdgeInsets.only(top: 8, left: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: _imageURlController.text.isEmpty
                          ? Text('Informe a URL')
                          : FittedBox(
                              child: Image.network(
                                _imageURlController.text,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
