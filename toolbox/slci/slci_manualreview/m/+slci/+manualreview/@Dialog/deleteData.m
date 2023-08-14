


function deleteData(obj,codeLanguage,data)
    assert(iscell(data));
    key=obj.constructKey(data{1});
    if isKey(obj.fCurrentData,key)
        remove(obj.fCurrentData,key);
    end

    assert(strcmpi(codeLanguage,obj.getCodeLanguage),...
    'DeleteData inconsistent Code Language');

    obj.updateCodeViewAnnotation(codeLanguage,obj.fCurrentData);

end