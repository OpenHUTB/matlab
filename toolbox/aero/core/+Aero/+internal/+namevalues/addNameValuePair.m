function pvpairs=addNameValuePair(pvpairs,name,value)





    if~any(strcmpi(pvpairs,name))
        pvpairs{end+1}=name;
        pvpairs{end+1}=value;
    end
end