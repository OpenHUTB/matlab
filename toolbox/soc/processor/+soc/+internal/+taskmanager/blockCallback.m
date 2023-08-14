function blockCallback(mgrBlk,event)




    import soc.internal.connectivity.*

    idx=strfind(mgrBlk,'/');
    modelName=mgrBlk(1:idx-1);
    if~isequal(get_param(modelName,'SimulationStatus'),'stopped')
        return;
    end

    switch event
    case 'delete'
        tag='SoCBlocksetTaskMapDlg';
        openDlgsWithTag=findDDGByTag(tag);
        if~isempty(openDlgsWithTag)
            tgtSrc='TaskManagerDlg.TaskManagerMap';
            idx=arrayfun(@(x)isa(x.getDialogSource,tgtSrc),openDlgsWithTag);
            if~isempty(idx)
                openTaskMapDlgs=openDlgsWithTag(idx);
                openTaskMapDlgs.delete;
            end
        end
    end
end
