function valueStored=setID(h,proposedValue)




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
        set(h.CoreProps,'Identifier',proposedValue);
        cache=rptgen.db2dom.TemplateCache.getTheCache();
        uncacheTemplate(cache,h.TemplatePath);
        Document.setCoreProperties(h.TemplatePath,h.CoreProps);
        cacheTemplate(cache,h.TemplatePath);
        valueStored='';
    end
