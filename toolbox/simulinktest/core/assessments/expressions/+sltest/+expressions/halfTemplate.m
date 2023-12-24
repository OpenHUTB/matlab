function templateHandle=halfTemplate
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.halfTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
