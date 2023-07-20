function name=i_getEscapedName(name)



    name=i_replaceCarriageReturnWithSpace(name);
    name=strtrim(strrep(name,'/','//'));
end
