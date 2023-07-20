function displayErrorMessage(this,dialog,errmsg)



    if isempty(dialog)
        disp(['Error: ',newline,errmsg]);
    else
        this.Status=['Error:',newline,errmsg];
        dialog.refresh;
    end

