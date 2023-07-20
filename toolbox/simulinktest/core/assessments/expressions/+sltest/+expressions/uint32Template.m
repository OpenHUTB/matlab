function templateHandle=uint32Template




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.uint32Template);
    end
    templateHandle=cachedTemplateHandle;
end
