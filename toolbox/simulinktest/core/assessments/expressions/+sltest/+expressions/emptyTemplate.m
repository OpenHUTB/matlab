function templateHandle=emptyTemplate




    import sltest.expressions.*
    persistent cachedTemplateHandle;
    if isempty(cachedTemplateHandle)
        cachedTemplateHandle=TemplateHandle.makeMoveFrom(mi.emptyTemplate);
    end
    templateHandle=cachedTemplateHandle;
end
