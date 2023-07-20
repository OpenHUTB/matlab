function show(aObj)




    map=slci.Configuration.ModelToDialogMap();
    if isKey(map,aObj.getModelName)
        dlg=map(aObj.getModelName);
        if~isempty(dlg)
            dlg.show
            return
        end
    end

    dlg=DAStudio.Dialog(aObj);
    aObj.fDialogHandle=dlg;
    map(aObj.getModelName)=dlg;%#ok
    oModel=get_param(aObj.getModelName,'Object');
    aObj.fCloseListener=Simulink.listener(...
    oModel,'CloseEvent',@(src,evt)slci.Configuration.CloseListener(src,evt,aObj));
    aObj.fPostSaveListener=Simulink.listener(...
    oModel,'PostSaveEvent',@(src,evt)slci.Configuration.PostSaveListener(src,evt,aObj));
end

