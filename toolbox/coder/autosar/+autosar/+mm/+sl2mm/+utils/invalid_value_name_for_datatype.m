function name=invalid_value_name_for_datatype(dataTypeName,maxShortNameLen)






    maxNameLen=min(maxShortNameLen,namelengthmax);

    name=arxml.arxml_private('p_create_aridentifier',...
    ['DefaultInvalidValue_',dataTypeName],...
    maxNameLen);

end
