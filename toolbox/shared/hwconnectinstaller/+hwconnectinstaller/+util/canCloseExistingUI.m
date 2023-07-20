function doCloseUI=canCloseExistingUI(hSetup)




    doCloseUI=false;

    dialogTitle=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:CmdLine_UIName'));
    msg=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','UIAlreadyOpen',...
    {'Question','Continue','StartOver','NotAllowed','OK'});




    if hSetup.isUIResetAllowed()

        result=questdlg(msg.Question,dialogTitle,...
        msg.Continue,msg.StartOver,msg.Continue);
        if isempty(result)

            result=msg.Continue;
        end
        if strcmp(result,msg.Continue)
            return;
        end
    else





        questdlg(msg.NotAllowed,dialogTitle,msg.OK,msg.OK);
        return;
    end

    doCloseUI=true;
end