function diaH=sync_dlg_mgr(method,varargin)



    persistent dialogH_cached;

    diaH=[];

    if~license_checkout_slvnv()
        return;
    end

    switch(lower(method))
    case 'remove'
        diaH=varargin{1};
        indx=[dialogH_cached.dialogH]==diaH;
        dialogH_cached(indx)=[];
    case 'add'
        modelH=varargin{1};
        if(~isempty(dialogH_cached))
            try
                for idx=1:length(dialogH_cached)
                    if(modelH==dialogH_cached(idx).modelH)
                        diaH=dialogH_cached(idx).dialogH;
                        diaH.refresh();
                        return
                    end
                end
            catch Mex %#ok<NASGU>
            end
        end
        dlgSrc=ReqSync.DoorsSyncSetting;
        dlgSrc.modelH=modelH;
        diaH=DAStudio.Dialog(dlgSrc);
        dialogH_cached(end+1).dialogH=diaH;
        dialogH_cached(end).modelH=modelH;
        objectH=get_param(modelH,'object');
        dialogH_cached(end).listener=handle.listener(objectH,'ObjectBeingDestroyed',...
        {@doorsync_delete_dialog,dialogH_cached(end).dialogH});
    end
end

function doorsync_delete_dialog(~,~,diaH)
    try
        diaH.refresh();
        delete(diaH);
        rmidoors.sync_dlg_mgr('remove',diaH);
    catch Mex %#ok<NASGU>
    end
end

function success=license_checkout_slvnv()
    invalid=builtin('_license_checkout','Simulink_Requirements','quiet');
    success=~invalid;
    if invalid
        rmi.licenseErrorDlg();
    end
end

