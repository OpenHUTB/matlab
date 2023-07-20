function templateHandle=untilTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.untilTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
