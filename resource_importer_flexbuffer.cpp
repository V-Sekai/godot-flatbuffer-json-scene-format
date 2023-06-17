/*************************************************************************/
/*  resource_importer_json.cpp                                           */
/*************************************************************************/
/*                       This file is part of:                           */
/*                           GODOT ENGINE                                */
/*                      https://godotengine.org                          */
/*************************************************************************/
/* Copyright (c) 2007-2020 Juan Linietsky, Ariel Manzur.                 */
/* Copyright (c) 2014-2020 Godot Engine contributors (cf. AUTHORS.md).   */
/*                                                                       */
/* Permission is hereby granted, free of charge, to any person obtaining */
/* a copy of this software and associated documentation files (the       */
/* "Software"), to deal in the Software without restriction, including   */
/* without limitation the rights to use, copy, modify, merge, publish,   */
/* distribute, sublicense, and/or sell copies of the Software, and to    */
/* permit persons to whom the Software is furnished to do so, subject to */
/* the following conditions:                                             */
/*                                                                       */
/* The above copyright notice and this permission notice shall be        */
/* included in all copies or substantial portions of the Software.       */
/*                                                                       */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.*/
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                */
/*************************************************************************/

#include "resource_importer_flexbuffer.h"

#include "core/io/file_access_pack.h"
#include "core/io/resource_importer.h"
#include "core/string/string_name.h"
#include "core/string/ustring.h"
#include "core/variant/variant_parser.h"

String ResourceImporterFlatbuffers::get_preset_name(int p_idx) const {
	return ::String();
}

String ResourceImporterFlatbuffers::get_importer_name() const {
	return "Flatbuffers";
}

String ResourceImporterFlatbuffers::get_visible_name() const {
	return "Flatbuffers";
}

String ResourceImporterFlatbuffers::get_save_extension() const {
	return "res";
}

String ResourceImporterFlatbuffers::get_resource_type() const {
	return "FlatbuffersData";
}

int ResourceImporterFlatbuffers::get_preset_count() const {
	return 0;
}

Error ResourceImporterFlatbuffers::import(const String &p_source_file, const String &p_save_path, const HashMap<StringName, Variant> &p_options, List<String> *r_platform_variants, List<String> *r_gen_files, Variant *r_metadata) {
	Ref<FileAccess> file = FileAccess::create(FileAccess::ACCESS_RESOURCES);
	ERR_FAIL_COND_V(file.is_null(), FAILED);
	Vector<uint8_t> array = file->get_file_as_bytes(p_source_file);
	Ref<FlatbuffersData> flexbuffer_data;
	flexbuffer_data.instantiate();
	flexbuffer_data->set_flatbuffers(array);
	return ResourceSaver::save(flexbuffer_data, p_save_path + String(".res"));
}

void FlatbuffersData::set_flatbuffers(const Vector<uint8_t> p_buffer) {
	Variant new_data = flatbuffer_buffer_to_variant(p_buffer);
	set_data(new_data);
}

Vector<uint8_t> FlatbuffersData::get_flatbuffers() const {
	return variant_to_flatbuffer(data);
}

void FlatbuffersData::set_data(Variant p_data) {
	data = p_data;
}

Variant FlatbuffersData::get_data() const {
	return data;
}

void FlatbuffersData::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_data", "_data"), &FlatbuffersData::set_data);
	ClassDB::bind_method(D_METHOD("get_data"), &FlatbuffersData::get_data);
	ClassDB::bind_method(D_METHOD("set_flatbuffers", "flexbuffers"), &FlatbuffersData::set_flatbuffers);
	ClassDB::bind_method(D_METHOD("get_flatbuffers"), &FlatbuffersData::get_flatbuffers);

	ADD_PROPERTY(PropertyInfo(Variant::NIL, "_data", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL), "set_data", "get_data");
}

static Variant flatbuffer_buffer_to_variant(Vector<uint8_t> p_buffer) {
	std::vector<uint8_t> std_vector;
	std_vector.resize(p_buffer.size());
	memcpy(std_vector.data(), p_buffer.ptr(), p_buffer.size());
	flexbuffers::Reference flat = flexbuffers::GetRoot(std_vector);
	return flatbuffer_to_variant(flat);
}

static Vector<uint8_t> variant_to_flatbuffer(Variant variant) {
	flexbuffers::Builder fbb;
	flatbuffer_variant_add(fbb, variant);
	fbb.Finish();
	std::vector<uint8_t> std_vector = fbb.GetBuffer();
	Vector<uint8_t> godot_bytes;
	godot_bytes.resize(std_vector.size());
	memcpy(godot_bytes.ptrw(), std_vector.data(), std_vector.size());
	return godot_bytes;
}

static void flatbuffer_variant_add(flexbuffers::Builder &fbb, Variant variant) {
	String value;
	VariantWriter::write_to_string(variant, value);
	fbb.String(value.ascii().get_data());
}

static const Variant flatbuffer_to_variant(flexbuffers::Reference buffer) {
	if (buffer.IsString()) {
		VariantParser::StreamString ss;
		ss.s = buffer.AsString().c_str();
		String errs;
		int line;
		Variant ret;
		(void)VariantParser::parse(&ss, ret, errs, line);
		return ret;
	}

	return Variant();
}
void ResourceImporterFlatbuffers::get_recognized_extensions(List<String> *p_extensions) const {
	p_extensions->push_back("bin");
}

void ResourceImporterFlatbuffers::get_import_options(const String &p_path, List<ImportOption> *r_options, int p_preset) const {
	return;
}

bool ResourceImporterFlatbuffers::get_option_visibility(const String &p_path, const String &p_option, const HashMap<StringName, Variant> &p_options) const {
	return true;
}