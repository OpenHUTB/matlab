function importToEditor(type,~)





    ed=Simulink.typeeditor.app.Editor.getInstance;
    st=ed.getStudio;
    ts=st.getToolStrip;
    importActionMain=ts.getAction('importIntoEditorAction');
    valid=importActionMain.enabled;

    if~isempty(st)&&valid
        treeSel=ed.getCurrentTreeNode{1};
        rootNode=treeSel.getRoot;

        switch type
        case 'MAT'
            fileExt='*.mat';
            fileStr=DAStudio.message('Simulink:busEditor:MATFiles');
        case 'M'
            fileExt='*.m';
            fileStr=DAStudio.message('Simulink:busEditor:MATLABFiles');
        otherwise
            assert(false);
        end

        [filename,pathname]=uigetfile({fileExt,fileStr},...
        DAStudio.message('Simulink:busEditor:FileImportToolTip',rootNode.getNodeName(false)));

        fileToImport=fullfile(pathname,filename);

        if exist(fileToImport,'file')
            [fdir,name,ext]=fileparts(fileToImport);
            if~isvarname(name)&&strcmpi(ext,'.m')
                errorStr=DAStudio.message('Simulink:busEditor:InvalidMATLABFileNameForImport',name);
                Simulink.typeeditor.utils.reportError(errorStr);
                return;
            end

            st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorWaitingForUserInputStatusMsg'));
            nodeName=rootNode.getNodeName(true);
            if slfeature('TypeEditorStudio')>0

                button=ed.getImportDialogPrompt(nodeName);
            else
                button=questdlg(DAStudio.message('Simulink:busEditor:CustomImportOverwriteWarningMsg',nodeName),...
                DAStudio.message('Simulink:busEditor:CustomImportOverwriteWarningText'),...
                DAStudio.message('Simulink:busEditor:YesText'),...
                DAStudio.message('Simulink:busEditor:NoText'),...
                DAStudio.message('Simulink:busEditor:NoText'));
            end
            st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorImportInProgressStatusMsg'));

            if~isempty(button)&&strcmpi(button,DAStudio.message('Simulink:busEditor:YesText'))
                curDir=pwd;
                try
                    if strcmpi(ext,'.m')==1
                        cd(fdir);
                        cmd=[name,';'];
                    else
                        assert(strcmp(ext,'.mat'));
                        cmd=['load(''',...
                        strrep(fileToImport,...
                        '''',''''''),''');'];
                    end
                    evalin('base',cmd);
                    cd(curDir);
                    rootNode.refresh;
                catch ME
                    Simulink.typeeditor.utils.reportError(ME.message);
                end
                cd(curDir);
            else
                if ed.isImportForBaseDisabled
                    ed.update;
                end
            end
        end
        st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg'));
        ed.open;
    end