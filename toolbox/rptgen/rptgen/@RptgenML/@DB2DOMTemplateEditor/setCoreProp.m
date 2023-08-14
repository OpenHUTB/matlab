function valueStored=setCoreProp(h,proposedValue,propName)




    import mlreportgen.dom.*;

    if isempty(h.CoreProps)
        if~isempty(h.TemplatePath)
            if~isempty(dir(h.TemplatePath))
                h.CoreProps=Document.getCoreProperties(h.TemplatePath);
            end
        end
    end

    if isempty(h.CoreProps)
        valueStored=proposedValue;
    else
        set(h.CoreProps,h.CorePropMap(propName),proposedValue);
        Document.setCoreProperties(h.TemplatePath,h.CoreProps);
        valueStored='';
    end
