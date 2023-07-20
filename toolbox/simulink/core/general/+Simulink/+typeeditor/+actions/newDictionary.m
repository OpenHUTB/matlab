function newDictionary(~)




    ed=Simulink.typeeditor.app.Editor.getInstance;
    st=ed.getStudio;
    ts=st.getToolStrip;
    newAction=ts.getAction('newSLDDAction');
    valid=newAction.enabled;

    if ed.isVisible&&valid
        newAction.enabled=false;
        st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorCreateInProgressStatusMsg'));
        try
            slddFile=slprivate('slddCreate',false);
            Simulink.typeeditor.actions.openDictionary(slddFile);
        catch ME
            Simulink.typeeditor.utils.reportError(ME.message);
        end
        st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg'));
        ed.update;
    end
end