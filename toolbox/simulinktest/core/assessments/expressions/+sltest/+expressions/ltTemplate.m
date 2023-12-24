function templateHandle=ltTemplate
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.ltTemplate);
    end
    templateHandle=cachedTemplateHandle;
end

