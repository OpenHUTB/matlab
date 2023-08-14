function Libraryrefresher(cbinfo,action)



    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');
    if~isempty(ui)
        if isempty(ui.libraryList)
            action.selected=0;
        else
            action.selected=1;
        end
    end
end
