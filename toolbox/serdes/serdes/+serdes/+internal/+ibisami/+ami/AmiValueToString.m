function str=AmiValueToString(value)





    if isstring(value)||ischar(value)
        str=string(value);
    else
        str=string(mat2str(value));
    end
end

