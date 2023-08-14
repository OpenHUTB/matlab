function value=isValidObject(elements)
    value=true;
    for i=1:length(elements)
        element=elements(i);
        try
            get_param(element,'Object');
        catch
            value=false;
            return;
        end
    end
end