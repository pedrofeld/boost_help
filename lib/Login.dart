import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _HomeState();
}

class _HomeState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Card(
          child: SizedBox(
            width: 350,
            child: Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(24,24,24,10),
              child: Column(
                mainAxisSize: .min,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blueAccent,
                        ),
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blueAccent,
                        ),
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                          'Entrar',
                        style: TextStyle(
                          color: Colors.blueAccent
                        ),
                        selectionColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: (){},
                      child: Text(
                        'Sem conta? Cadastre uma!',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        selectionColor: Colors.blueAccent,
                      )
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
