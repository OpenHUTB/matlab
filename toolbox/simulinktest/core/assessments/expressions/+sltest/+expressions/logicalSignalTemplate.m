function templateHandle=logicalSignalTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.logicalSignalTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
