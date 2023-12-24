function templateHandle=aboveTimeIntervalTemplate

    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.aboveTimeIntervalTemplate);
    end
    templateHandle=cachedTemplateHandle;
end

