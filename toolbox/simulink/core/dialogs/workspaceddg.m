function dlgstruct=workspaceddg(hObj)































































    if isa(hObj,'DAStudio.WorkspaceNode')||isa(hObj,'Simulink.slobject.WorkspaceNode')
        hObj=hObj.getParent;
    end

    if isa(hObj,'DAStudio.DAObjectProxy')

        hObj=hObj.getMCOSObjectReference;
    end

    if(isa(hObj,'Simulink.Root'))
        BaseWrkSpaceDesc.Type='textbrowser';
        BaseWrkSpaceDesc.Text=l_BaseWSInfo;
        BaseWrkSpaceDesc.Tag='BaseWrkSpaceDesc';

        if slfeature('ShowMECmdWindow')>0
            BaseWrkSpaceDesc.MaximumSize=[-1,100];
            cmdWindow=cmdWindowDDG(hObj);
            dlgstruct.Items={BaseWrkSpaceDesc,cmdWindow};
        else
            dlgstruct.Items={BaseWrkSpaceDesc};
        end

        dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:WorkspaceRootDlgStructDialogTitle');
        dlgstruct.HelpMethod='helpview';
        dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'base_workspace'};
    else
        mdl=hObj;
        hWS=mdl.getWorkspace;


        isMDLSrc=false;
        isMATSrc=false;
        isMFileSrc=false;
        isMCodeSrc=false;

        dataSource=hWS.DataSource;
        switch dataSource
        case 'Model File'
            isMDLSrc=true;
        case 'MAT-File'
            isMATSrc=true;
        case 'MATLAB File'
            isMFileSrc=true;
        case 'MATLAB Code'
            isMCodeSrc=true;
        otherwise
            DAStudio.error('Simulink:dialog:WorkspaceDataSourceError',dataSource);
        end


        source.Name=DAStudio.message('Simulink:dialog:WorkspaceSourceName');
        source.Tag='dataSource';
        source.RowSpan=[1,1];
        source.ColSpan=[1,4];
        source.Type='combobox';
        source.DialogRefresh=1;
        source.Entries={DAStudio.message('Simulink:dialog:WorkspaceSourceModelFile'),...
        DAStudio.message('Simulink:dialog:WorkspaceSourceMATFile'),...
        DAStudio.message('Simulink:dialog:WorkspaceSourceMATLABFile'),...
        DAStudio.message('Simulink:dialog:WorkspaceSourceMATLABCode')};
        source.Values=...
        [workspaceddg_cb([],'mapDataSourceToValue',hWS,'Model File'),...
        workspaceddg_cb([],'mapDataSourceToValue',hWS,'MAT-File'),...
        workspaceddg_cb([],'mapDataSourceToValue',hWS,'MATLAB File'),...
        workspaceddg_cb([],'mapDataSourceToValue',hWS,'MATLAB Code')];
        source.Value=workspaceddg_cb([],'mapDataSourceToValue',hWS,dataSource);
        source.MatlabMethod='workspaceddg_cb';
        source.MatlabArgs={'%dialog','%tag',hWS,'%value'};






        fileEdit.Name=DAStudio.message('Simulink:dialog:WorkspaceFileEditName');
        fileEdit.Tag='WorkspaceFileName';
        fileEdit.RowSpan=[2,2];
        fileEdit.ColSpan=[1,3];
        fileEdit.Type='edit';
        fileEdit.Visible=isMATSrc||isMFileSrc;
        if isMATSrc||isMFileSrc
            fileEdit.Source=hWS;
            fileEdit.ObjectProperty='FileName';
            fileEdit.Mode=1;
            fileEdit.DialogRefresh=1;
        end
        fileEdit.ToolTip=DAStudio.message('Simulink:dialog:WorkspaceFileEditToolTip');


        fileBrowserButton.Name=DAStudio.message('Simulink:dialog:WorkspaceFileBrowserButtonName');
        fileBrowserButton.Tag='WorkspaceFileBrowser';
        fileBrowserButton.RowSpan=[2,2];
        fileBrowserButton.ColSpan=[4,4];
        fileBrowserButton.Type='pushbutton';
        fileBrowserButton.Visible=isMATSrc||isMFileSrc;
        fileBrowserButton.MatlabMethod='workspaceddg_cb';
        fileBrowserButton.MatlabArgs={'%dialog','%tag',hWS};
        fileBrowserButton.DialogRefresh=1;
        fileBrowserButton.Enabled=1;
        fileBrowserButton.ToolTip=DAStudio.message('Simulink:dialog:WorkspaceFileBrowserButtonToolTip');


        userMcode.Name=DAStudio.message('Simulink:dialog:WorkspaceUserMCodeName');
        userMcode.Tag='MATLABCode';
        userMcode.RowSpan=[3,3];
        userMcode.ColSpan=[1,4];
        userMcode.Type='matlabeditor';
        userMcode.Visible=isMCodeSrc;
        if isMCodeSrc
            userMcode.Source=hWS;


            userMcode.Value=hWS.MATLABCode;
        end
        userMcode.MatlabMethod='workspaceddg_cb';
        userMcode.MatlabArgs={'%dialog','%tag',hWS};
        userMcode.ToolTip=DAStudio.message('Simulink:dialog:WorkspaceUserMCodeToolTip');







        reloadButton.Name=DAStudio.message('Simulink:dialog:WorkspaceReloadButtonName');
        reloadButton.Tag='reload';
        reloadButton.RowSpan=[4,4];
        reloadButton.ColSpan=[1,1];
        reloadButton.Type='pushbutton';
        reloadButton.Visible=~isMDLSrc;
        reloadButton.MatlabMethod='workspaceddg_cb';
        reloadButton.MatlabArgs={'%dialog','%tag',hWS};
        reloadButton.DialogRefresh=1;
        reloadButton.Enabled=((isMATSrc||isMFileSrc)&&filenameNonEmpty(hWS))||...
        (isMCodeSrc&&~isempty(hWS.MATLABCode));
        reloadButton.ToolTip=DAStudio.message('Simulink:dialog:WorkspaceReloadButtonToolTip');


        savetosrcButton.Name=DAStudio.message('Simulink:dialog:WorkspaceSavetosrcButtonName');
        savetosrcButton.Tag='saveToSource';
        savetosrcButton.RowSpan=[4,4];
        savetosrcButton.ColSpan=[2,2];
        savetosrcButton.Type='pushbutton';
        savetosrcButton.Visible=isMATSrc||isMFileSrc;
        savetosrcButton.MatlabMethod='workspaceddg_cb';
        savetosrcButton.MatlabArgs={'%dialog','%tag',hWS};
        savetosrcButton.DialogRefresh=1;
        savetosrcButton.Enabled=filenameNonEmpty(hWS)&&wsIsDirty(hWS)&&~wsIsEmpty(hWS);
        savetosrcButton.ToolTip=DAStudio.message('Simulink:dialog:WorkspaceSavetosrcButtonToolTip');





        pnlModelWrkSpace.Name=DAStudio.message('Simulink:dialog:WorkspacePnlModelWrkSpaceName');
        pnlModelWrkSpace.Type='group';
        pnlModelWrkSpace.RowSpan=[1,1];
        pnlModelWrkSpace.ColSpan=[1,1];
        pnlModelWrkSpace.LayoutGrid=[4,4];
        pnlModelWrkSpace.ColStretch=[0,0,1,0];
        pnlModelWrkSpace.Items=...
        {source,fileEdit,fileBrowserButton,userMcode,...
        reloadButton,savetosrcButton};
        pnlModelWrkSpace.Tag='PnlModelWrkSpace';

        pnlParamValues=buildParameterValuePanel(mdl.Name);
        pnlParamValues.RowSpan=[2,2];
        pnlParamValues.ColSpan=[1,1];

        bIsModelMaskEnabled=slInternal('isCreateOrEditModelMaskEnabled',mdl.Handle);
        bIsModelAlreadyMasked=slInternal('isModelAlreadyMasked',mdl.Handle);


        modelArgNames.Name=DAStudio.message('Simulink:dialog:WorkspaceModelArgNamesName');
        modelArgNames.NameLocation=2;
        modelArgNames.RowSpan=[2,2];
        modelArgNames.ColSpan=[1,1];
        modelArgNames.Type='edit';
        modelArgNames.Tag='ModelParamArgNames';
        modelArgNames.Source=mdl.Handle;
        modelArgNames.ObjectProperty='ParameterArgumentNames';
        modelArgNames.Enabled=true;
        modelArgNames.Visible=false;
        modelArgNames.ToolTip=DAStudio.message('Simulink:dialog:WorkspaceModelArgNamesToolTip');


        if(bIsModelAlreadyMasked)
            modelmask.Name=DAStudio.message('Simulink:dialog:WorkspaceEditModelMask');
            modelmask.ToolTip=DAStudio.message('Simulink:dialog:WorkspaceEditModelMaskToolTip');
        else
            modelmask.Name=DAStudio.message('Simulink:dialog:WorkspaceCreateModelMask');
            modelmask.ToolTip=DAStudio.message('Simulink:dialog:WorkspaceCreateModelMaskToolTip');
        end
        modelmask.Tag='createoreditmodelmask';
        modelmask.RowSpan=[3,3];
        modelmask.ColSpan=[1,1];
        modelmask.Type='pushbutton';
        modelmask.Visible=bIsModelMaskEnabled;
        modelmask.Enabled=bIsModelMaskEnabled;
        modelmask.MatlabMethod='slInternal';
        modelmask.MatlabArgs={'createOrEditModelMask',mdl.Handle};
        modelmask.DialogRefresh=1;
        modelmask.Alignment=7;
        modelmask.MinimumSize=[110,20];





        spacer.RowSpan=[4,4];
        spacer.ColSpan=[1,1];
        spacer.Type='panel';
        spacer.Tag='Spacer';

        dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:WorkspaceDlgStructDialogTitle');

        if slfeature('ShowMECmdWindow')>0
            cmdWindow=cmdWindowDDG(hObj);
            cmdWindow.RowSpan=[5,5];
            cmdWindow.ColSpan=[1,1];

            dlgstruct.LayoutGrid=[5,1];
            dlgstruct.RowStretch=[0,0,0,1,20];
            dlgstruct.Items={pnlModelWrkSpace,pnlParamValues,modelArgNames,modelmask,spacer,cmdWindow};
        else
            if isMCodeSrc
                dlgstruct.LayoutGrid=[3,1];
                dlgstruct.RowStretch=[1,0,0];
                dlgstruct.Items={pnlModelWrkSpace,pnlParamValues,modelArgNames,modelmask};
            else
                dlgstruct.LayoutGrid=[4,1];
                dlgstruct.RowStretch=[0,0,0,1];
                dlgstruct.Items={pnlModelWrkSpace,pnlParamValues,modelArgNames,modelmask,spacer};
            end
        end

        dlgstruct.PostApplyCallback='workspaceddg_cb';
        dlgstruct.PostApplyArgs={'%dialog','postApply',hWS};


        dlgstruct.SmartApply=0;
        dlgstruct.HelpMethod='helpview';
        dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'model_workspace'};
    end
end

function panel=buildParameterValuePanel(mdlName)

    btnLaunch.Name=message('sl_valuesrc:messages:LaunchApp').getString();
    btnLaunch.Type='pushbutton';
    btnLaunch.Tag='btnLaunch';
    btnLaunch.RowSpan=[1,1];
    btnLaunch.ColSpan=[1,1];
    btnLaunch.MatlabMethod='sl_valuesrc.ValueSrcManager.launch';
    btnLaunch.MatlabArgs={mdlName};



    panel.Name=message('sl_valuesrc:messages:ParameterValues').getString();
    panel.Type='group';
    panel.LayoutGrid=[4,4];
    panel.ColStretch=[0,0,1,0];
    panel.Items={btnLaunch};
    panel.Tag='pnlParamValues';
    panel.Visible=(slfeature('MWSValueSource')>0);

end


function result=filenameNonEmpty(hWS)

    dataSource=hWS.DataSource;
    result=((strcmp(dataSource,'MAT-File')||strcmp(dataSource,'MATLAB File'))...
    &&~strcmp(strtrim(hWS.FileName),''));
end

function result=wsIsEmpty(hWS)

    result=isempty(hWS.whos);
end

function result=wsIsDirty(hWS)

    result=false;

    if islogical(hWS.isDirty)&&hWS.isDirty
        result=true;
    end
end

function htm=l_BaseWSInfo
    htm=['<p>',DAStudio.message('Simulink:dialog:WorkspaceHTMLText'),'<\p>'];
end


