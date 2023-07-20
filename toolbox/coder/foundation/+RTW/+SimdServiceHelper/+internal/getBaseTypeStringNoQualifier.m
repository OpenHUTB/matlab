function baseTypeString=getBaseTypeStringNoQualifier(typeString)


    result=strsplit(typeString,'*');
    baseTypeString=strtrim(result{1});
    baseTypeString=strtrim(strrep(baseTypeString,'const',''));
end