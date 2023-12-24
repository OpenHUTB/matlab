function templateHandle=andTemplate
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.andTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
