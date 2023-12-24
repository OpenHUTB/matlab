function templateHandle=notTemplate
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.notTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
