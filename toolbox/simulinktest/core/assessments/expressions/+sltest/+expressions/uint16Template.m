function templateHandle=uint16Template




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.uint16Template);
    end
    templateHandle=cachedTemplateHandle;
end
