function templateHandle=plusTemplate
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.plusTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
