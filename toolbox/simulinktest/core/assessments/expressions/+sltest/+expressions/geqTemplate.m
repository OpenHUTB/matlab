function templateHandle=geqTemplate
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.geqTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
