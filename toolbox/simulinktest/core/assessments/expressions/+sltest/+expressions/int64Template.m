function templateHandle=int64Template
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.int64Template);
    end
    templateHandle=cachedTemplateHandle;
end
