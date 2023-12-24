function templateHandle=numericSignalTemplate
    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.numericSignalTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
