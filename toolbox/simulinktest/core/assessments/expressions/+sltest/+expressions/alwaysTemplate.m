function templateHandle=alwaysTemplate

    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.alwaysTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
