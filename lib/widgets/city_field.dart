import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sienna_app/services/geonames_service.dart';

class CityField extends StatefulWidget {
  final bool isIndonesian;
  final bool enabled;
  final ValueChanged<CityLocation?> onSelected;
  const CityField({
    super.key,
    required this.isIndonesian,
    required this.enabled,
    required this.onSelected,
  });

  @override
  State<CityField> createState() => _CityFieldState();
}
class _CityFieldState extends State<CityField> {
  static const _green = Color(0xFF176B59);
  static const _forest = Color(0xFF233B35);
  final _controller = TextEditingController();
  final _service = GeoNamesService();
  Timer? _debounce;
  int _requestVersion = 0;
  List<CityLocation> _results = [];
  CityLocation? _selected;
  bool _loading = false;
  bool _searched = false;
  String? _error;
  String tr(String id, String en) => widget.isIndonesian ? id : en;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }
  void _onChanged(String value) {
    _debounce?.cancel();
    final version = ++_requestVersion;
    _selected = null;
    widget.onSelected(null);
    setState(() {
      _results = [];
      _error = null;
      _searched = false;
      _loading = false;
    });
    final query = value.trim();
    if (query.length < 2) return;
    setState(() => _loading = true);
    _debounce = Timer(const Duration(
      milliseconds: 450,
    ), () async {
      try {
        final locations = await _service.searchCities(query);
        if (!mounted || version != _requestVersion) return;
        setState(() {
          _results = locations;
          _loading = false;
          _searched = true;
        });
      } on GeoNamesException catch (error) {
        if (!mounted || version != _requestVersion) return;
        setState(() {
          _loading = false;
          _searched = true;
          _error = error.message;
        });
      } catch (error) {
        if (!mounted || version != _requestVersion) return;
        setState(() {
          _loading = false;
          _searched = true;
          _error = tr(
            'Gagal mencari kota.',
            'Could not search cities.',
          );
        });
      }
    });
  }
  void _choose(CityLocation location) {
    _debounce?.cancel();
    _requestVersion++;
    _controller.text = location.label;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _selected = location;
    widget.onSelected(location);
    FocusScope.of(context).unfocus();
    setState(() {
      _results = [];
      _searched = false;
      _loading = false;
      _error = null;
    });
  }
  String? _validate(String? value) {
    if ((value ?? '').trim().isEmpty) return null;
    if (_selected == null) {
      return tr(
        'Pilih kota dari hasil pencarian.',
        'Select a city from the search results.',
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions = _selected == null && _controller.text.trim().length >= 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          enabled: widget.enabled,
          onChanged: _onChanged,
          validator: _validate,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: tr(
              'Kota Asal (opsional)',
              'Hometown (optional)',
            ),
            hintText: tr(
              'Ketik minimal 2 huruf',
              'Type at least 2 letters',
            ),
            prefixIcon: const Icon(
              Icons.location_city_outlined,
              color: _green,
            ),
            suffixIcon: _loading
                ? const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : _selected != null
                ? const Icon(
              Icons.check_circle,
              color: _green,
            )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E5DF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: _green,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          tr(
            'Cari berdasarkan nama kota, bukan negara.',
            'Search by city name, not country name.',
          ),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718078),
          ),
        ),
        if (showSuggestions && _error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: const TextStyle(
              color: Colors.deepOrange,
              fontSize: 12,
            )),
          ),
        if (showSuggestions && _searched && !_loading && _error == null && _results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              tr(
                'Tidak ada kota yang cocok.',
                'No matching cities found.',
              ),
              style: const TextStyle(
                color: _forest,
                fontSize: 12,
              ),
            ),
          ),
        if (showSuggestions && _results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E5DF)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _results.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final city = _results[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.place_outlined,
                    color: _green,
                  ),
                  title: Text(
                    city.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(city.countryName),
                  onTap: widget.enabled ? () => _choose(city) : null,
                );
              },
            ),
          ),
        const SizedBox(height: 5),
      ],
    );
  }
}