function templateHandle=uint8Template
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.uint8Template);
    end
    templateHandle=cachedTemplateHandle;
end
