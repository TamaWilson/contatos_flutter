import 'dart:io';

import 'package:contatos_flutter/database/database.dart';
import 'package:contatos_flutter/helpers/image.helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moor/moor.dart' as moor;

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({Key key, this.contact}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _imagePicker = ImagePicker();
  final ImageHelper imageHelper = ImageHelper();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();

  bool _userEdited = false;

  ContactsCompanion _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = ContactsCompanion();
    } else {
      _editedContact = widget.contact.toCompanion(true);

      _nameController.text = _editedContact.name.value;
      _emailController.text = _editedContact.email.value;
      _phoneController.text = _editedContact.phone.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name.value ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              Navigator.pop(context, _editedContact);
            }
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Form(
              key: _formKey,
              child: Column(children: [
                GestureDetector(
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            colorFilter: _editedContact.img.present
                                ? null
                                : new ColorFilter.mode(
                                    Colors.grey.withOpacity(0.2),
                                    BlendMode.dstATop),
                            fit: BoxFit.cover,
                            image: _editedContact.img.present
                                ? imageHelper
                                    .showImage(_editedContact.img.value)
                                : AssetImage("images/add_photo.png"))),
                  ),
                  onTap: () {
                    _imagePicker
                        .getImage(source: ImageSource.camera)
                        .then((pickedFile) {
                      if (pickedFile == null) {
                        return;
                      }
                      setState(() {
                        _editedContact.img = moor.Value(pickedFile.path);
                      });
                    });
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Nome"),
                  focusNode: _nameFocus,
                  validator: (value) {
                    if (value.isEmpty || value.length < 6) {
                      FocusScope.of(context).requestFocus(_nameFocus);
                      return "Seu nome deve ter pelo menos 6 caracteres";
                    }

                    return null;
                  },
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _editedContact.name = moor.Value(text);
                    });
                  },
                ),
                TextFormField(
                  focusNode: _emailFocus,
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _editedContact.email = moor.Value(text);
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty && _phoneController.text.isEmpty) {
                      return "Insira pelo menos uma informação de contato";
                    }

                    RegExp exp = new RegExp(
                        r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$");

                    if (!exp.hasMatch(value)) {
                      FocusScope.of(context).requestFocus(_emailFocus);
                      return "Formato de email inválido";
                    }

                    return null;
                  },
                ),
                TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: "Phone"),
                    onChanged: (text) {
                      _userEdited = true;
                      setState(() {
                        _editedContact.phone = moor.Value(text);
                      });
                    },
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value.isEmpty && _emailController.text.isEmpty) {
                        return "Insira pelo menos uma informação de contato";
                      }
                      if (value.length < 11 && value.isNotEmpty) {
                        FocusScope.of(context).requestFocus(_phoneFocus);
                        return "Numero de telefone inválido";
                      }

                      return null;
                    },
                    inputFormatters: [MaskedInputFormatter('(00) 0 0000-0000')])
              ])),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancelar")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text("Sim")),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
