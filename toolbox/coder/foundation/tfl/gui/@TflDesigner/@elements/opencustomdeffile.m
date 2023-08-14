function opencustomdeffile(this)






    if this.iscustomtype

        try
            edit(this.customfilepath);
        catch ME
            dp=DAStudio.DialogProvider;
            dp.errordlg(ME.message,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
            return;
        end
    end