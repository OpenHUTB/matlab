function str=replaceMissingType(str)



    if isstring(str)
        str=replace(str,"<missing>",string(missing));
    end
end