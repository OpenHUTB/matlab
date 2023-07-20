function onResetLoadOpt(this,dialog)



    if isempty(dialog)
        questdlg_cb('Yes');
    else
        Question=['Any changes you have will be discarded. '...
        ,'Click Yes to restore the default options. '...
        ,'Click No to keep your changes.'];

        dp=DAStudio.DialogProvider;
        dp.questdlg(Question,'Confirm Change',{'Yes','No'},'No',@questdlg_cb);
    end

    function questdlg_cb(Answer)
        switch(Answer)
        case 'Yes'
            this.UserData.LoadOptions=this.UserData.DefaultLoadOptions;
            this.UserData.ElabOptions=this.UserData.DefaultElabOptions;
            this.UserData.Connection='Socket';
            this.StepHandles{4}.ResetOptions;
            if~isempty(dialog)
                dialog.refresh;
            end
        otherwise

        end
    end

end



