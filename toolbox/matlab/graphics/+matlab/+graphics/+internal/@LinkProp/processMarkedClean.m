function processMarkedClean(hLink,obj,~)



    post=hLink.HasPostUpdateListeners;
    if strcmp(post,'off')

        hlist=hLink.Targets;
        viewers=localGetAllViewers(hlist);
        if isempty(viewers)
            return
        end
        listeners=hLink.Listeners;
        for m=1:length(viewers)
            viewer=viewers{m};
            hUpdate=event.listener(getCanvas(viewer),'PostUpdate',@hLink.processPostUpdate);
            listeners{end+1}=hUpdate;%#ok<AGROW>
        end
        hLink.Listeners=listeners;
        hLink.HasPostUpdateListeners='on';
    end

    clean=hLink.CleanedTargets;
    clean{end+1}=obj;
    hLink.CleanedTargets=clean;
end
