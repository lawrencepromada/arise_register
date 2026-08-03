import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/user_service.dart';


class CreateUserScreen extends StatefulWidget {

  final String branchId;
  final String branchName;


  const CreateUserScreen({
    super.key,
    required this.branchId,
    required this.branchName,
  });


  @override
  State<CreateUserScreen> createState() =>
      _CreateUserScreenState();

}



class _CreateUserScreenState
    extends State<CreateUserScreen> {


  final _formKey = GlobalKey<FormState>();

  final UserService _userService = UserService();


final nameController = TextEditingController();
final emailController = TextEditingController();
final passwordController = TextEditingController();


  String selectedRole = 'Usher';


  bool obscurePassword = true;



  @override
  void dispose() {

   nameController.dispose();
emailController.dispose();
passwordController.dispose();

    super.dispose();

  }



  void createAccount() {


    if(_formKey.currentState!.validate()) {




      ScaffoldMessenger.of(context)
      .showSnackBar(

        const SnackBar(

          content: Text(
            'Account ready for Firebase connection',
          ),

        ),

      );


    }

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Create User Account',
        ),

      ),



      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),


        child: Form(

          key: _formKey,


          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,


            children: [


              const Text(

                'User Information',

                style: TextStyle(

                  fontSize: 22,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const SizedBox(height: 20),




              TextFormField(

                controller: nameController,


                decoration: const InputDecoration(

                  labelText: 'Full Name',

                  border:
                  OutlineInputBorder(),

                ),


                validator: (value){

                  if(value == null ||
                      value.trim().isEmpty){

                    return 'Enter full name';

                  }

                  return null;

                },

              ),




              const SizedBox(height: 15),





              TextFormField(

                controller: emailController,


                keyboardType:
                TextInputType.emailAddress,


                decoration: const InputDecoration(

                  labelText: 'Email Address',

                  border:
                  OutlineInputBorder(),

                ),



                validator: (value){

                  if(value == null ||
                      value.trim().isEmpty){

                    return 'Enter email';

                  }


                  if(!value.contains('@')){

                    return 'Enter valid email';

                  }


                  return null;

                },

              ),





              const SizedBox(height: 15),





              TextFormField(

                controller:
                passwordController,


                obscureText:
                obscurePassword,


                decoration: InputDecoration(


                  labelText: 'Temporary Password',


                  border:
                  const OutlineInputBorder(),


                  suffixIcon:
                  IconButton(


                    icon: Icon(

                      obscurePassword

                          ? Icons.visibility

                          : Icons.visibility_off,

                    ),



                    onPressed: (){

                      setState(() {

                        obscurePassword =
                        !obscurePassword;

                      });

                    },

                  ),

                ),



                validator: (value){

                  if(value == null ||
                      value.length < 6){

                    return 'Password must be at least 6 characters';

                  }


                  return null;

                },

              ),




              const SizedBox(height: 20),





              Text(

                'Branch: ${widget.branchName}',


                style: const TextStyle(

                  fontSize: 16,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),





              const SizedBox(height: 20),





              DropdownButtonFormField<String>(


                value: selectedRole,


                decoration: const InputDecoration(

                  labelText: 'User Role',

                  border:
                  OutlineInputBorder(),

                ),



                items: const [


                  DropdownMenuItem(

                    value: 'Chief Usher',

                    child:
                    Text('Chief Usher'),

                  ),



                  DropdownMenuItem(

                    value: 'Usher',

                    child:
                    Text('Usher'),

                  ),


                ],




                onChanged: (value){

                  setState(() {

                    selectedRole = value!;

                  });

                },

              ),





              const SizedBox(height: 30),





              SizedBox(

                width: double.infinity,


                child: ElevatedButton(


                  onPressed:
                  createAccount,


                  child: const Text(

                    'CREATE USER',

                  ),

                ),

              ),



            ],

          ),

        ),

      ),

    );

  }

}