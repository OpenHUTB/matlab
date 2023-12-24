function templateHandle=int32Template
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.int32Template);
    end
    templateHandle=cachedTemplateHandle;
end
