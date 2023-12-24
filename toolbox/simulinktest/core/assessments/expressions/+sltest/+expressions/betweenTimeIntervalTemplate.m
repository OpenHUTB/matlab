function templateHandle=betweenTimeIntervalTemplate

    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.betweenTimeIntervalTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
