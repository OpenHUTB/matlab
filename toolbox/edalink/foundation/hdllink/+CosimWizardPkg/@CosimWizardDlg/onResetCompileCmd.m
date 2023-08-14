function onResetCompileCmd(this,dialog)



    Question=['Any changes you have will be discarded. '...
    ,'Click Yes to restore the default commands. '...
    ,'Click No to keep your changes.'];

    dp=DAStudio.DialogProvider;
    dp.questdlg(Question,'Confirm Change',{'Yes','No'},'No',@questdlg_cb);

    function questdlg_cb(Answer)
        switch(Answer)
        case 'Yes'
            this.CompileCmd=this.UserData.GeneratedCompileCmd;
            dialog.refresh;
        otherwise

        end
    end

end




