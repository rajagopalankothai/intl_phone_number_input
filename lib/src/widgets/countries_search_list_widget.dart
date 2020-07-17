import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/test/test_helper.dart';

class CountrySearchListWidget extends StatefulWidget {
  final List<Country> countries;
  final InputDecoration searchBoxDecoration;
  final String locale;
  final ScrollController scrollController;

  CountrySearchListWidget(this.countries, this.locale,
      {this.searchBoxDecoration, this.scrollController});

  @override
  _CountrySearchListWidgetState createState() =>
      _CountrySearchListWidgetState();
}

class _CountrySearchListWidgetState extends State<CountrySearchListWidget> {
  TextEditingController _searchController = TextEditingController();
  List<Country> filteredCountries;

  @override
  void initState() {
    filteredCountries = filterCountries();
    super.initState();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    super.dispose();
  }

  InputDecoration getSearchBoxDecoration() {
    return widget.searchBoxDecoration ??
        InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 0.9, color: Colors.black26),
            ),
            hintText: 'Type to Search ',
            hintStyle: TextStyle(fontSize: 12.0),
            contentPadding: EdgeInsets.only(bottom: 5.0, top: 18.0));
  }

  List<Country> filterCountries() {
    final value = _searchController.text.trim();

    if (value.isNotEmpty) {
      return widget.countries
          .where(
            (Country country) =>
                country.name.toLowerCase().contains(value.toLowerCase()) ||
                getCountryName(country)
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                country.dialCode.contains(value.toLowerCase()),
          )
          .toList();
    }

    return widget.countries;
  }

  String getCountryName(Country country) {
    if (widget.locale != null && country.nameTranslations != null) {
      String translated = country.nameTranslations[widget.locale];
      if (translated != null && translated.isNotEmpty) {
        return translated;
      }
    }
    return country.name;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0),
            child: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 28.0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                })),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
          child: TextFormField(
            cursorColor: Colors.grey,
            style: TextStyle(fontSize: 14.0),
            key: Key(TestHelper.CountrySearchInputKeyValue),
            decoration: getSearchBoxDecoration(),
            controller: _searchController,
            onChanged: (value) =>
                setState(() => filteredCountries = filterCountries()),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(0.0),
            controller: widget.scrollController,
            shrinkWrap: true,
            itemCount: filteredCountries.length,
            itemBuilder: (BuildContext context, int index) {
              Country country = filteredCountries[index];
              if (country == null) return null;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 18.0),
                key: Key(TestHelper.countryItemKeyValue(country.countryCode)),
                leading: CircleAvatar(
                  backgroundImage: AssetImage(
                    country.flagUri,
                    package: 'intl_phone_number_input',
                  ),
                ),
                title: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('${getCountryName(country)}',
                        style: TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.start)),
                subtitle: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('${country?.dialCode ?? ''}',
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start)),
                onTap: () => Navigator.of(context).pop(country),
              );
            },
          ),
        ),
      ],
    );
  }
}
