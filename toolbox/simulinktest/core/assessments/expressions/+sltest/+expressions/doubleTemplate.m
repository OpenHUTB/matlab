function templateHandle=doubleTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.doubleTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
