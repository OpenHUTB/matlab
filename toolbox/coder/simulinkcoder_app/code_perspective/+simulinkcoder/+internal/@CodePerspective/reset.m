function reset(obj,studio)




    mdl=studio.App.blockDiagramHandle;
    cps=obj.getFlag(mdl,studio);
    if isempty(cps)

        return;
    end

    for i=1:length(obj.tasks)
        t=obj.tasks{i};
        t.reset(cps);
    end
