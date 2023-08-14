function templateHandle=castTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.castTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
