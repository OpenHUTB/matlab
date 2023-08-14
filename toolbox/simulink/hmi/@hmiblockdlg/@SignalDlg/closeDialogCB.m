

function closeDialogCB(obj,dlg,~)

    openDlgs=obj.getOpenDialogs(true);
    if(length(openDlgs)==1)
        utils.deleteTimersAndListeners(obj);
    end
    closeCallback(obj,dlg);

end

