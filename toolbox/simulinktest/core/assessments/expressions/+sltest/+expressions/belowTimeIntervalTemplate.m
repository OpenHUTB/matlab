function templateHandle=belowTimeIntervalTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.belowTimeIntervalTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
