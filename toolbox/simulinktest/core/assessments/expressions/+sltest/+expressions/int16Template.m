function templateHandle=int16Template
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.int16Template);
    end
    templateHandle=cachedTemplateHandle;
end
