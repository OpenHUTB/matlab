function templateHandle=gtTemplate
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.gtTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
