function templateHandle=unaryMinusTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.unaryMinusTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
