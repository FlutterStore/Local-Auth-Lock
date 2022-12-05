// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Home());
}

class Home extends StatefulWidget { 
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String check="", lockauth="";
  bool checkans = false, isAuth = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Local Auth",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                onPressed: (){
                  checkavaibility();
                },
                child: const Text("Check Availability",style: TextStyle(color: Colors.white),),
              ),
              Text(check),
              checkans==true 
              ? 
              Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_isAuthenticating)
                  OutlinedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                    onPressed: _cancelAuthentication,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text('Cancel Authentication',style: TextStyle(color: Colors.white),),
                        Icon(Icons.cancel,color: Colors.white,),
                      ],
                    ),
                  )
                  else
                    Column(
                      children: <Widget>[
                        OutlinedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                          onPressed: _authenticate,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const <Widget>[
                              Text('Authenticate',style: TextStyle(color: Colors.white),),
                              Icon(Icons.perm_device_information,color: Colors.white,),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                          onPressed: secure,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(_isAuthenticating
                                  ? 'Cancel'
                                  : 'Authenticate: biometrics only',style: const TextStyle(color: Colors.white),),
                              const Icon(Icons.fingerprint,color: Colors.white,),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              )
              : 
              const SizedBox(),
              Text(lockauth),
            ],
          ),
        ),
      ),
    );
  }

  checkavaibility()async
  {
    try {
      checkans = await auth.canCheckBiometrics;
      if(checkans==true)
      {
        setState(() {
          check="Yes, Biometrics is available";
        });
        authtype();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  authtype()async
  {
    List<BiometricType>? availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } catch (e) {
      print(e.toString());
    }
    
    for (var ab in availableBiometrics!) {
      print("Avalible Biomatrics: $ab");
    }
    
  }
  _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  secure()async{
    try {
      isAuth = await auth.authenticate(
        localizedReason: 'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          ),
        );
      } catch (e) {
      print(e);
      }

      if(isAuth==true)
      {
        setState(() {
          lockauth='Success';
        });
      }
      else
      {
        setState(() {
          lockauth='Auth Fail';
        });        
      } 
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }


}