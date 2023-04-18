/// @func lexicon_text(textEntry, [substring], [...]
/// @param {String} _textEntry
/// @param {Any*} [substring]
/// @param {Any*} [...]
/// @return {String}
function lexicon_text(_textEntry) {
	gml_pragma("forceinline");
	// Ensure that it's loaded first!
	__lexicon_init();

	// Auto GC
	__lexicon_handle_cache();
	
	// We'll check to see if it already exists in the cache before processing the string at hand.
	with(__LEXICON_STRUCT) {

	// Failsafe before everything else!
	var _replchr = replaceChrLegacy;
	
	// Correct for any potential errors
	if (localeMap[$ locale] == undefined) {
		// Fallback to language
		if (languageMap[$ language] == undefined) {
			return locale + "." + _textEntry;	
		}
	}
	
	var _str = textEntries[$ _textEntry];
	if (_str == undefined) {
		/* Feather ignore once GM2047 */
		if (LEXICON_DEBUG) {
			return "Missing text pointer: " + _textEntry;	
		}
		
		return _textEntry;
	}

	#region Cache
	// Check against Cache
	if (argument_count-1 >= LEXICON_CACHE_ARG_THRESHOLD) {
		var _cacheStr = locale+"."+_textEntry;
		// Substring replacement loop
		var _count = string_count(_replchr,_str);
		var _args = array_create(_count);
		for(var _i = 1; _i < _count; ++_i) {
			if (_i > argument_count) break;
			_args[_i-1] = argument[_i-1];
		}
		_cacheStr += string(_args);

		if (ds_map_exists(cacheMap, _cacheStr)) {
			var _struct = cacheMap[? _cacheStr];
			if _struct.cacheStr == _cacheStr {
				// Update timestamp
				_struct.timeStamp = current_time;
				/* Feather ignore once GM1035 */
				return _struct.str;
			}
		}
	}
	#endregion

	if (argument_count > 1) {
			var _count = string_count(_replchr,_str);
			for(var _i = 0; _i < _count; ++_i) {
				if (_i > argument_count-2) break;
				var _arg = argument[_i+1];
				_str = string_replace(_str, _replchr, _arg);
			}

			if (argument_count-1 >= LEXICON_CACHE_ARG_THRESHOLD) {
				var _struct = new __lexicon_cache_text(_str, _cacheStr);
				__LEXICON_STRUCT.cacheMap[? _cacheStr] = _struct;
				ds_list_add(__LEXICON_STRUCT.cacheList, {cacheStr: _cacheStr, ref: weak_ref_create(_struct)});
				//return _struct;
			}
		}
	}

	return _str;
}