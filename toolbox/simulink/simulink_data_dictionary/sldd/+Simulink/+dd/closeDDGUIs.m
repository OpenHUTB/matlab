function closeDDGUIs(ddFilespec)









    ed=Simulink.typeeditor.app.Editor.getInstance;
    if isVisible(ed)

        edSource=ed.getSource;

        if edSource.isPresentByDD(ddFilespec)
            [~,fileName,~]=fileparts(ddFilespec);
            Simulink.typeeditor.actions.closeDictionary(fileName);
        end
    end


    tr=DAStudio.ToolRoot;
    openDlgs=tr.getOpenDialogs;
    for i=1:length(openDlgs)
        dlg=openDlgs(i);
        if dlg.isStandAlone
            dlgSrc=dlg.getDialogSource;
            if isa(dlgSrc,'Simulink.dd.EntryDDGSource')


                if strcmp(dlgSrc.m_ddConn.filespec,ddFilespec)
                    dlg.delete;
                end
            end
        end
    end

end

