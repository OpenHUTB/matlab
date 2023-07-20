function onRemoveCb(this,dlg)



    try
        onRemoveCb(this.StepHandles{10},dlg);
        dlg.refresh;
    catch ME
        displayErrorMessage(this,dlg,ME.message);
    end
end

