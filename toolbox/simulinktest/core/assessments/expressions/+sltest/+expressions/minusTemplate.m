function templateHandle=minusTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.minusTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
