



function insertAnnotationCB(cbinfo)

    editor=cbinfo.studio.App.getActiveEditor;
    if isa(cbinfo.domain,'StateflowDI.SFDomain')
        StateflowDI.ToolCreation.enterCreateAnnotationMode(editor);
    else

        msg='FORMAT/Insert Annotation is not implemented in the Simulink Toolstrip yet';
        disp(msg);
        beep;
        dp=DAStudio.DialogProvider;
        dp.msgbox(msg,'Simulink Toolstrip');
    end
end
