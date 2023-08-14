function displayStatusMessage(this,dialog,errmsg)



    if isempty(dialog)
        disp(errmsg);
    else
        this.Status=errmsg;
        dialog.refresh;
    end


