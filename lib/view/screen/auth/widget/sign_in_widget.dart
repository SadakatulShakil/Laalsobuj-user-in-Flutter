import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/body/login_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/auth_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/cart_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/splash_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/button/custom_button.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/textfield/custom_password_textfield.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/textfield/custom_textfield.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/forget_password_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/widget/mobile_verify_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/widget/social_login_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';

import 'code_picker_widget.dart';
import 'otp_verification_screen.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  SignInWidgetState createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  GlobalKey<FormState>? _formKeyLogin;

  String? _countryDialCode = "+880";
  String? _phoneNumber;
  @override
  void initState() {
    super.initState();
    Provider.of<SplashProvider>(context,listen: false).configModel;
    _countryDialCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.countryCode!).dialCode;
    print("jjjjjjjjjjjjjjj: "+_countryDialCode.toString());
    _formKeyLogin = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController!.text = (Provider.of<AuthProvider>(context, listen: false).getUserEmail());
    _passwordController!.text = (Provider.of<AuthProvider>(context, listen: false).getUserPassword());
  }

  @override
  void dispose() {
    _emailController!.dispose();
    _passwordController!.dispose();
    super.dispose();
  }

  final FocusNode _emailNode = FocusNode();
  final FocusNode _passNode = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  LoginModel loginBody = LoginModel();

  void loginUser() async {
    if (_formKeyLogin!.currentState!.validate()) {
      _formKeyLogin!.currentState!.save();

      if(_emailController!.text.trim().startsWith('0')){
        _phoneNumber = _emailController!.text.trim().substring(1);
      }else{
        _phoneNumber = _emailController!.text.trim();
      }
      String email = _countryDialCode!.substring(1)+_phoneNumber!;
      String password = _passwordController!.text.trim();
      print("check number: "+email);

      if (email.isEmpty) {
        print("check number: "+email);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(getTranslated('EMAIL_MUST_BE_REQUIRED', context)!),
          backgroundColor: Colors.red,
        ));
      } else if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(getTranslated('PASSWORD_MUST_BE_REQUIRED', context)!),
          backgroundColor: Colors.red,
        ));
      } else {
        print("check number: "+email);
        if (Provider.of<AuthProvider>(context, listen: false).isRemember!) {
          Provider.of<AuthProvider>(context, listen: false).saveUserEmail(email, password);
        } else {
          Provider.of<AuthProvider>(context, listen: false).clearUserEmailAndPassword();
        }

        loginBody.email = email;
        loginBody.password = password;
        await Provider.of<AuthProvider>(context, listen: false).login(loginBody, route);
      }
    }
  }

  route(bool isRoute, String? token, String? temporaryToken, String? errorMessage) async {
    if (isRoute) {
      if(token==null || token.isEmpty){
        if(Provider.of<SplashProvider>(context,listen: false).configModel!.emailVerification!){
          Provider.of<AuthProvider>(context, listen: false).checkEmail(_emailController!.text.toString(),
              temporaryToken!).then((value) async {
            if (value.isSuccess) {
              Provider.of<AuthProvider>(context, listen: false).updateEmail(_emailController!.text.toString());
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => VerificationScreen(
                  temporaryToken,'',_emailController!.text.toString())), (route) => false);

            }
          });
        }else if(Provider.of<SplashProvider>(context,listen: false).configModel!.phoneVerification!){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MobileVerificationScreen(
              temporaryToken!)), (route) => false);
        }
      }
      else{
        await Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);
        if(context.mounted){}
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashBoardScreen()), (route) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage!), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).isRemember;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.marginSizeLarge),
      child: Form(
        key: _formKeyLogin,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          children: [

            Container(
              margin: const EdgeInsets.only(left: Dimensions.marginSizeDefault,
                  right: Dimensions.marginSizeDefault, top: Dimensions.marginSizeSmall),
              child: Row(children: [
                CodePickerWidget(
                  onChanged: (CountryCode countryCode) {
                    _countryDialCode = countryCode.dialCode;
                  },
                  initialSelection: _countryDialCode,
                  favorite: [_countryDialCode!],
                  showDropDownButton: true,
                  padding: EdgeInsets.zero,
                  showFlagMain: true,
                  textStyle: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),

                ),



                Expanded(child: CustomTextField(
                  hintText: getTranslated('ENTER_MOBILE_NUMBER', context),
                  controller: _emailController,
                  focusNode: _emailNode,
                  nextNode: _passwordFocus,
                  isPhoneNumber: true,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.phone,

                )),
              ]),
            ),

            // Container(
            //     margin:
            //     const EdgeInsets.only(bottom: Dimensions.marginSizeSmall),
            //     child: CustomTextField(
            //       hintText: getTranslated('ENTER_YOUR_EMAIL_or_mobile', context),
            //       focusNode: _emailNode,
            //       nextNode: _passNode,
            //       textInputType: TextInputType.emailAddress,
            //       controller: _emailController,
            //     )),
            //
            //
            // Padding(
            //   padding: const EdgeInsets.only(left: 8.0),
            //   child: Text('NOTE: please enter phone number with country code. ex: 8801787878787',
            //     style: robotoWarning,),
            // ),
            SizedBox(height: 8,),
            Container(
                margin:
                const EdgeInsets.only(bottom: Dimensions.marginSizeDefault),
                child: CustomPasswordTextField(
                  hintTxt: getTranslated('ENTER_YOUR_PASSWORD', context),
                  textInputAction: TextInputAction.done,
                  focusNode: _passNode,
                  controller: _passwordController,
                )),



            Container(
              margin: const EdgeInsets.only(right: Dimensions.marginSizeSmall),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Row(children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) => Checkbox(
                      checkColor: ColorResources.white,
                      activeColor: Theme.of(context).primaryColor,
                      value: authProvider.isRemember,
                      onChanged: authProvider.updateRemember,),),


                  Text(getTranslated('REMEMBER', context)!, style: titilliumRegular),
                ],),

                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgetPasswordScreen())),
                    child: Text(getTranslated('FORGET_PASSWORD', context)!,
                        style: titilliumRegular.copyWith(
                        color: ColorResources.getLightSkyBlue(context))),
                  ),
                ],
              ),
            ),



            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 30),
              child: Provider.of<AuthProvider>(context).isLoading ?
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),) :
              CustomButton(onTap: loginUser, buttonText: getTranslated('SIGN_IN', context)),),
            const SizedBox(width: Dimensions.paddingSizeDefault),



            const SocialLoginWidget(),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            Center(child: Text(getTranslated('OR', context)!,
                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault))),



            GestureDetector(
              onTap: () {
                if (!Provider.of<AuthProvider>(context, listen: false).isLoading) {
                  Provider.of<CartProvider>(context, listen: false).getCartData();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashBoardScreen()),
                          (route) => false);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(left: Dimensions.marginSizeAuth, right: Dimensions.marginSizeAuth,
                    top: Dimensions.marginSizeAuthSmall),
                width: double.infinity, height: 40, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent, borderRadius: BorderRadius.circular(6),),
                child: Text(getTranslated('CONTINUE_AS_GUEST', context)!,
                    style: titleHeader.copyWith(color: ColorResources.getPrimary(context))),
              ),
            ),
          ],
        ),
      ),
    );


  }

}
