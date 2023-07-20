function value=str2enum(value,enum_type)




    [~,enum_str_values]=enumeration(enum_type);
    [tf,index]=ismember(lower(value),lower(enum_str_values));
    if tf
        value=enum_str_values{index};
    else
        cell2table(enum_str_values)
        DAStudio.error('MATLAB:class:InvalidEnumValue',value);
    end

end
