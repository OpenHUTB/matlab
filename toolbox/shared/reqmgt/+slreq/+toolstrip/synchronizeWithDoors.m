function synchronizeWithDoors(cbinfo)

    modelH=slreq.toolstrip.getModelHandle(cbinfo);
    diaH=rmidoors.sync_dlg_mgr('add',modelH);
    if~isempty(diaH)
        diaH.show();
    end

end
