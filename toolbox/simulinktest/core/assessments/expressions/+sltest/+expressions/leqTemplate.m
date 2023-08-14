function templateHandle=leqTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.leqTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
