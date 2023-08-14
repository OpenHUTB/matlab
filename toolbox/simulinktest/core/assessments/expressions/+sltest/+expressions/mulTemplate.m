function templateHandle=mulTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.mulTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
