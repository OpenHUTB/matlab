function templateHandle=cmpTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.cmpTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
