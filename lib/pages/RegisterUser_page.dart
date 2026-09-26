// ignore_for_file: file_names

import 'package:flutter/material.dart';

enum _UserRole { visionary, investor }

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final _formKey = GlobalKey<FormState>();
  _UserRole _role = _UserRole.visionary;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _biography = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _linkedIn = TextEditingController();
  final _profession = TextEditingController();
  final _studyArea = TextEditingController();
  final _investorType = TextEditingController();
  final _companyName = TextEditingController();
  final _position = TextEditingController();
  final _companyWebsite = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _email,
      _password,
      _city,
      _state,
      _biography,
      _phoneNumber,
      _linkedIn,
      _profession,
      _studyArea,
      _investorType,
      _companyName,
      _position,
      _companyWebsite,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulário preenchido com sucesso.')),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório.';
    return null;
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueAccent),
    ),
    floatingLabelStyle: const TextStyle(color: Colors.blueAccent),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _decoration(required ? '$label *' : label),
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      validator: required ? _required : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crie uma conta', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black38,
      ),
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Tipo de usuário',
                        textAlign: .center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<_UserRole>(
                        segments: const [
                          ButtonSegment(
                            value: _UserRole.visionary,
                            label: Text('Visionary'),
                            icon: Icon(Icons.lightbulb_outline),
                          ),
                          ButtonSegment(
                            value: _UserRole.investor,
                            label: Text('Investor'),
                            icon: Icon(Icons.trending_up),
                          ),
                        ],
                        selected: {_role},
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? Colors.white
                                : Colors.blueAccent,
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? Colors.blueAccent
                                : Colors.transparent,
                          ),
                          side: WidgetStateProperty.all(
                            const BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                        onSelectionChanged: (selection) {
                          setState(() => _role = selection.first);
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _field(_firstName, 'Nome', required: true),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              _lastName,
                              'Sobrenome',
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _field(
                        _email,
                        'E-mail',
                        required: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        _password,
                        'Senha',
                        required: true,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _field(_city, 'Cidade', required: true),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(_state, 'Estado', required: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _field(_biography, 'Biografia', maxLines: 3),
                      const SizedBox(height: 16),
                      _field(
                        _phoneNumber,
                        'Telefone',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        _linkedIn,
                        'LinkedIn',
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      if (_role == _UserRole.visionary) ...[
                        _field(_profession, 'Profissão'),
                        const SizedBox(height: 16),
                        _field(_studyArea, 'Área de estudo'),
                      ] else ...[
                        _field(_investorType, 'Tipo de investidor'),
                        const SizedBox(height: 16),
                        _field(_companyName, 'Nome da empresa'),
                        const SizedBox(height: 16),
                        _field(_position, 'Cargo'),
                        const SizedBox(height: 16),
                        _field(
                          _companyWebsite,
                          'Site da empresa',
                          keyboardType: TextInputType.url,
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(
                            color: Colors.blueAccent
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
