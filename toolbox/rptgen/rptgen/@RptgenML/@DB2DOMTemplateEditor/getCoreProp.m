function returnedValue=getCoreProp(h,storedValue,propName)




    import mlreportgen.dom.*;

    if isempty(h.CoreProps)
        if~isempty(h.TemplatePath)
            if~isempty(dir(h.TemplatePath))
                h.CoreProps=Document.getCoreProperties(h.TemplatePath);
            end
        end
    end

    if isempty(h.CoreProps)
        returnedValue=storedValue;
    else
        returnedValue=get(h.CoreProps,h.CorePropMap(propName));
        if isempty(returnedValue)
            returnedValue='';
        end
    end