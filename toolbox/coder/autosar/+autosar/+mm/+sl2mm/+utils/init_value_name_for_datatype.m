function name=init_value_name_for_datatype(dataTypeName,maxShortNameLen)






    maxNameLen=min(maxShortNameLen,namelengthmax);

    name=arxml.arxml_private('p_create_aridentifier',...
    ['DefaultInitValue_',dataTypeName],...
    maxNameLen);

end
