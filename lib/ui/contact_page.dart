import 'dart:io';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import 'package:contatos_flutter/helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = MaskedTextController(mask: '(00) 00000-0000');

  Contact _editedContact;

  bool _userEdited = false;

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }

    _nameController.addListener(() {
      if(_editedContact.name != _nameController.text) {
      _userEdited = true;
      }
      setState(() {
        _editedContact.name = _nameController.text;
      });

    });

    _emailController.addListener(() {
      if(_editedContact.email != _emailController.text) {
        _userEdited = true;
      }
      _editedContact.email = _emailController.text;
     // _userEdited = true;
    });

    _phoneController.addListener(() {
      if(_editedContact.phone != _phoneController.text) {
        _userEdited = true;
      }
      _editedContact.phone = _phoneController.text;
     // _userEdited = true;
    });

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save, size: 40.0),
            backgroundColor: Colors.red,
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Navigator.pop(context, _editedContact);
              }
            }),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      width: 140.0,
                      height: 140.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              colorFilter: _editedContact.img != null ?
                              null : new ColorFilter.mode(
                                  Colors.grey.withOpacity(0.2),
                                  BlendMode.dstATop),
                              image: _editedContact.img != null
                                  ? FileImage(File(_editedContact.img))
                                  : AssetImage("images/add_photo.png",)
                          )),
                    ),
                    onTap: (){
                      ImagePicker.pickImage(source: ImageSource.camera).then((file){
                        if(file == null) {
                          return;
                        } else {
                          setState(() {
                            _editedContact.img = file.path;
                          });
                        }
                      });
                    },
                  ),
                  TextFormField(
                    focusNode: _nameFocus,
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Nome"),

                    validator: (value) {
                      if (value.isEmpty) {
                        FocusScope.of(context).requestFocus(_nameFocus);
                        return "Informe seu nome";
                      }
                    },
                  ),
                  TextFormField(

                    controller: _emailController,
                    decoration: InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty && _phoneController.text.isEmpty) {
                        return "Insira pelo menos uma informação de contato";
                      }

                      RegExp exp = new RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$");

                      if (!exp.hasMatch(value)) {
                        return "Formato de email inválido";
                      }
                    },
                  ),
                  TextFormField(

                    controller: _phoneController,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(labelText: "Telefone"),

                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value.isEmpty && _emailController.text.isEmpty) {
                        return "Insira pelo menos uma informação de contato";
                      }
                      if (value.length < 11 && value.isNotEmpty) {
                        return "Numero de telefone inválido";
                      }
                    },
                  )
                ],
              ),
            )),
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
              content: Text("Se sair as alterações serão descartadas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}