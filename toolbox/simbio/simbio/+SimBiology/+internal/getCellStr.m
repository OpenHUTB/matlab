function s=getCellStr(arg,emsgstr)


    if ischar(arg)
        s={arg};
    elseif iscellstr(arg)
        s=arg(:);
    else
        error(message('SimBiology:getCellStr:INVALID_ARGUMENT',emsgstr));
    end



    if length(s)==1&&isempty(s{1})
        s=cell(0,1);
    end
end