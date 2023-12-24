function templateHandle=int8Template
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.int8Template);
    end
    templateHandle=cachedTemplateHandle;
end
