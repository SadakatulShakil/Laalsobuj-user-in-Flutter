
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/search_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/no_internet_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/product_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/search_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/search/widget/search_product_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../data/model/response/district_model.dart';
import '../../../data/model/response/upazila_model.dart';
import '../../../provider/district_provider.dart';
import '../../../provider/upazila_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  int? selectedDistrictId;
  Upazila? selectedUpazila;

  @override
  void initState() {
    super.initState();
    context.read<DistrictProvider>().fetchDistricts();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SearchProvider>(context, listen: false).cleanSearchProduct();
    Provider.of<SearchProvider>(context, listen: false).initHistoryList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorResources.getIconBg(context),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: Theme.of(context).canvasColor,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1),)],
              ),
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                            child: InkWell(onTap: (){
                              Navigator.pop(context);
                              Provider.of<SearchProvider>(context, listen: false).cleanSearchProduct();

                            },
                                child: const Icon(Icons.arrow_back_ios)),),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 22.0, right: 20),
                        child: Row(
                            children: [
                              Expanded(child:
                              Consumer<DistrictProvider>(
                                builder: (context, districtProvider, _) {
                                  return DropdownButton<int>(
                                    value: selectedDistrictId,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDistrictId = value;
                                        Provider.of<SearchProvider>(context, listen: false).setDistrictId(value.toString());
                                        selectedUpazila = null; // Reset selected upazila
                                        context.read<UpazilaProvider>().fetchUpazilas(value!);
                                      });
                                    },
                                    hint: Text('Select District'),
                                    items: [
                                      DropdownMenuItem<int>(
                                        value: null,
                                        child: Text('Select District'),
                                      ),
                                      ...districtProvider.districts.map((District district) {
                                        return DropdownMenuItem<int>(
                                          value: district.id,
                                          child: Text(district.district),
                                        );
                                      }),
                                    ],
                                  );
                                },
                              ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child:
                                Consumer<UpazilaProvider>(
                                  builder: (context, upazilaProvider, _) {
                                    return DropdownButton<Upazila>(
                                      value: selectedUpazila,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedUpazila = value;
                                          Provider.of<SearchProvider>(context, listen: false).setUpazilaId(value!.id.toString());
                                        });
                                      },
                                      hint: Text('Select Upazila'),
                                      items: [
                                        DropdownMenuItem<Upazila>(
                                          value: null,
                                          child: Text('Select Upazila'),
                                        ),
                                        ...upazilaProvider.upazilas.map((Upazila upazila) {
                                          return DropdownMenuItem<Upazila>(
                                            value: upazila,
                                            child: Text(upazila.upazila),
                                          );
                                        }),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Row(children: [
                      Expanded(
                        child: SearchWidget(
                        hintText: getTranslated('SEARCH_HINT', context),
                        onSubmit: (String text) {
                          if(text.trim().isEmpty) {
                            Fluttertoast.showToast(
                                msg: getTranslated('enter_somethings', context)!,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                            //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('enter_somethings'), backgroundColor: ColorResources.getRed(context)));

                          }else{
                            print(text+"---->"+Provider.of<SearchProvider>(context, listen: false).districtId.toString()+"---->"+Provider.of<SearchProvider>(context, listen: false).upazilaId.toString());
                            Provider.of<SearchProvider>(context, listen: false).searchProduct(text, selectedDistrictId.toString(), selectedUpazila!.id.toString(), context);
                            Provider.of<SearchProvider>(context, listen: false).saveSearchAddress(text);
                          }},
                        onClearPressed: () => Provider.of<SearchProvider>(context, listen: false).cleanSearchProduct(),
                        ),
                      ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault,),

            Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                return !searchProvider.isClear ? searchProvider.searchProductList != null ?
                searchProvider.searchProductList!.isNotEmpty ?
                Expanded(child: SearchProductWidget(products: searchProvider.searchProductList, isViewScrollable: true)) :
                const Expanded(child: NoInternetOrDataScreen(isNoInternet: false)) :
                Expanded(child: ProductShimmer(isHomePage: false,
                    isEnabled: Provider.of<SearchProvider>(context).searchProductList == null)) :
                Expanded(
                  child: Padding( padding: const EdgeInsets.symmetric(horizontal:  Dimensions.paddingSizeLarge),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getTranslated('SEARCH_HISTORY', context)!, style: robotoBold),


                            InkWell(borderRadius: BorderRadius.circular(10),
                                onTap: () => Provider.of<SearchProvider>(context, listen: false).clearSearchAddress(),
                                child: Container(padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault,
                                    vertical:Dimensions.paddingSizeLarge ),
                                    child: Text(getTranslated('REMOVE', context)!,
                                      style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).primaryColor),)))
                          ],
                        ),
                        Expanded(
                          child: Consumer<SearchProvider>(
                            builder: (context, searchProvider, child) => StaggeredGridView.countBuilder(
                              crossAxisCount: 2,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: searchProvider.historyList.length,
                              itemBuilder: (context, index) => Container(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () => Provider.of<SearchProvider>(context, listen: false).searchProduct(searchProvider.historyList[index], selectedDistrictId.toString(), selectedUpazila!.id.toString(), context),
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
                                          color: ColorResources.getGrey(context)),
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(Provider.of<SearchProvider>(context, listen: false).historyList[index],
                                          style: titilliumItalic.copyWith(fontSize: Dimensions.fontSizeDefault),
                                        ),
                                      ),
                                    ),
                                  )),
                              staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
                              mainAxisSpacing: 4.0,
                              crossAxisSpacing: 4.0,
                            ),
                          ),
                        ),
                        // Positioned(top: -50, left: 0, right: 0,
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Text(getTranslated('SEARCH_HISTORY', context), style: robotoBold),
                        //
                        //
                        //         InkWell(borderRadius: BorderRadius.circular(10),
                        //             onTap: () => Provider.of<SearchProvider>(context, listen: false).clearSearchAddress(),
                        //             child: Container(padding: EdgeInsets.symmetric(horizontal:Dimensions.PADDING_SIZE_DEFAULT,
                        //                 vertical:Dimensions.PADDING_SIZE_LARGE ),
                        //                 child: Text(getTranslated('REMOVE', context),
                        //                   style: titilliumRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL,
                        //                       color: Theme.of(context).primaryColor),)))
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
