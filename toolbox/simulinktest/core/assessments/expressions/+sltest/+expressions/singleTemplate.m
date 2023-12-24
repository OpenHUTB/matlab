function templateHandle=singleTemplate
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.singleTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
