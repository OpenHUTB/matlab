function closeDialog(this,dialogHandle)




    if isa(dialogHandle,'DAStudio.Dialog')
        dialogHandle.delete;
    end
