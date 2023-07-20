function bool=isTypeCompatible(type,expectedTypes)




    bool=isempty(type)...
    ||strlength(type)==0...
    ||any(strcmpi(string(type),expectedTypes));
end
