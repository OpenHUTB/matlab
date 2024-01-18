function cell_array=strToCell(string)

    if isempty(strtrim(string))
        cell_array={};
    else
        tokens=textscan(string,'%s','delimiter',',');
        cell_array=strtrim(tokens{1});
    end
end
