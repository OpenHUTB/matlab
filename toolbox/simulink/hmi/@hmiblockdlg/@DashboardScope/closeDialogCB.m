
function closeDialogCB(obj,dlg,~)

    openDlgs=obj.getOpenDialogs(true);
    if length(openDlgs)<1
        for idx=1:length(obj.Listeners)
            delete(obj.Listeners(idx));
        end
        obj.Listeners=[];
    end

    closeCallback(obj,dlg);
end

