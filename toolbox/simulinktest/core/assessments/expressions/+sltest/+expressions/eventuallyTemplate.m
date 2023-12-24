function templateHandle=eventuallyTemplate
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.eventuallyTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
