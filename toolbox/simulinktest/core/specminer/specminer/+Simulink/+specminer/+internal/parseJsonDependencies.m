function data = parseJsonDependencies(jsonDependencies)
    formattedJson = strrep(jsonDependencies, '''', '"');
    data = jsondecode(formattedJson);
end