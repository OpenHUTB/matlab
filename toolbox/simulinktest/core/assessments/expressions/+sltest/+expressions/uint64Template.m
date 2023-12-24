function templateHandle=uint64Template
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.uint64Template);
    end
    templateHandle=cachedTemplateHandle;
end
