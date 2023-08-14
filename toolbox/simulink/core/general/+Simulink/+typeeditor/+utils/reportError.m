function reportError(errMsg)




    ed=Simulink.typeeditor.app.Editor.getInstance;
    if ed.isVisible
        ed.getStudio.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg'));
    end

    dp=DAStudio.DialogProvider;
    title=DAStudio.message('Simulink:busEditor:ErrorText');
    dp.errordlg(errMsg,title,true);


