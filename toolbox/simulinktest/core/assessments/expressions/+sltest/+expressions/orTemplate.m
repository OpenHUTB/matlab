function templateHandle=orTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.orTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
