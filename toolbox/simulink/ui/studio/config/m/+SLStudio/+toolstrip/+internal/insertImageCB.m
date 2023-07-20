



function insertImageCB(cbinfo)

    editor=cbinfo.studio.App.getActiveEditor;
    if isa(cbinfo.domain,'StateflowDI.SFDomain')
        StateflowDI.ToolCreation.enterCreateImageMode(editor);
    else

        msg='FORMAT/Insert Image is not implemented in the Simulink Toolstrip yet';
        disp(msg);
        beep;
        dp=DAStudio.DialogProvider;
        dp.msgbox(msg,'Simulink Toolstrip');
    end
end
