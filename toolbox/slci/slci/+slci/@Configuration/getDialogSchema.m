


function dlg=getDialogSchema(aObj,~)



    dlg.DialogTitle=aObj.CreateDialogTitle();
    dlg.DialogTag=aObj.cDialogTag;

    topModelTarget.Name=DAStudio.message('Slci:ui:TopModel');
    topModelTarget.ToolTip=DAStudio.message('Slci:ui:TopModelTooltip',aObj.getModelName());
    topModelTarget.Type='checkbox';
    topModelTarget.RowSpan=[1,1];
    topModelTarget.ColSpan=[1,1];
    topModelTarget.Tag=aObj.getTag('TopModel');
    topModelTarget.WidgetId=aObj.getWidgetId('TopModel');
    topModelTarget.Value=aObj.getTopModel();
    topModelTarget.DialogRefresh=true;

    followModelLinks.Name=DAStudio.message('Slci:ui:FollowModelLinks');
    followModelLinks.ToolTip=DAStudio.message('Slci:ui:FollowModelLinksTooltip',aObj.getModelName());
    followModelLinks.Type='checkbox';
    followModelLinks.RowSpan=[2,2];
    followModelLinks.ColSpan=[1,1];
    followModelLinks.Tag=aObj.getTag('FollowModelLinks');
    followModelLinks.WidgetId=aObj.getWidgetId('FollowModelLinks');
    followModelLinks.Value=aObj.getFollowModelLinks();
    followModelLinks.DialogRefresh=true;

    includeTopModelChecksum.Name=DAStudio.message('Slci:ui:IncludeTopModelChecksumForRef');
    includeTopModelChecksum.ToolTip=DAStudio.message('Slci:ui:IncludeTopModelChecksumForRefTooltip');
    includeTopModelChecksum.Type='checkbox';
    includeTopModelChecksum.RowSpan=[3,3];
    includeTopModelChecksum.ColSpan=[1,1];
    includeTopModelChecksum.Tag=aObj.getTag('IncludeTopModelChecksumForRef');
    includeTopModelChecksum.WidgetId=aObj.getWidgetId('IncludeTopModelChecksumForRef');
    includeTopModelChecksum.Value=aObj.getIncludeTopModelChecksumForRefModels();
    includeTopModelChecksum.Visible=~aObj.getWidgetValue('TopModel')||...
    aObj.getWidgetValue('FollowModelLinks');

    mdlRefGroup.Type='group';
    mdlRefGroup.Name=DAStudio.message('Slci:ui:MdlRefGroup');
    mdlRefGroup.Items={topModelTarget,followModelLinks,includeTopModelChecksum};
    mdlRefGroup.RowSpan=[1,1];
    mdlRefGroup.ColSpan=[1,1];

    inspectSharedUtils.Name=DAStudio.message('Slci:ui:InspectSharedUtils');
    inspectSharedUtils.ToolTip=DAStudio.message('Slci:ui:InspectSharedUtilsToolTip');
    inspectSharedUtils.Type='checkbox';
    inspectSharedUtils.RowSpan=[1,1];
    inspectSharedUtils.ColSpan=[1,1];
    inspectSharedUtils.Tag=aObj.getTag('InspectSharedUtils');
    inspectSharedUtils.WidgetId=aObj.getWidgetId('InspectSharedUtils');
    inspectSharedUtils.Value=slcifeature('InspectSharedUtils')&&...
    aObj.getInspectSharedUtils();
    inspectSharedUtils.DialogRefresh=true;

    sharedUtilsGroup.Type='group';
    sharedUtilsGroup.Name=DAStudio.message('Slci:ui:SharedUtilsGroup');
    sharedUtilsGroup.Items={inspectSharedUtils};
    sharedUtilsGroup.LayoutGrid=[2,2];
    sharedUtilsGroup.ColStretch=[0,1];
    sharedUtilsGroup.RowSpan=[2,2];
    sharedUtilsGroup.ColSpan=[1,1];
    sharedUtilsGroup.Visible=slcifeature('InspectSharedUtils');

    if aObj.getWidgetValue('FollowModelLinks')
        terminateOnIncompat.Name=DAStudio.message('Slci:ui:TerminateOnIncompatibilityAll');
    else
        terminateOnIncompat.Name=DAStudio.message('Slci:ui:TerminateOnIncompatibilityOne');
    end
    terminateOnIncompat.ToolTip=DAStudio.message('Slci:ui:TerminateOnIncompatibilityTooltip');
    terminateOnIncompat.Type='checkbox';
    terminateOnIncompat.RowSpan=[1,1];
    terminateOnIncompat.ColSpan=[1,2];
    terminateOnIncompat.Tag=aObj.getTag('TerminateOnIncompatibility');
    terminateOnIncompat.WidgetId=aObj.getWidgetId('TerminateOnIncompatibility');
    terminateOnIncompat.Value=aObj.getTerminateOnIncompatibility();

    if aObj.getWidgetValue('FollowModelLinks')
        checkPushButton.Name=DAStudio.message('Slci:ui:CheckAll');
    else
        checkPushButton.Name=DAStudio.message('Slci:ui:CheckOne');
    end
    checkPushButton.ToolTip=DAStudio.message('Slci:ui:CheckTooltip',aObj.getModelName());
    checkPushButton.Type='pushbutton';
    checkPushButton.Tag=aObj.getTag('Check');
    checkPushButton.WidgetId=aObj.getWidgetId('Check');
    checkPushButton.ObjectMethod='CheckCompatibilityCB';
    checkPushButton.MethodArgs={'%dialog'};
    checkPushButton.ArgDataTypes={'handle'};
    checkPushButton.RowSpan=[2,2];
    checkPushButton.ColSpan=[1,1];

    incompatibilityGroup.Type='group';
    incompatibilityGroup.Name=DAStudio.message('Slci:ui:IncompatibilityGroup');
    incompatibilityGroup.Items={terminateOnIncompat,checkPushButton};
    incompatibilityGroup.RowSpan=[3,3];
    incompatibilityGroup.ColSpan=[1,1];
    incompatibilityGroup.ColStretch=[0,1];
    incompatibilityGroup.LayoutGrid=[2,2];

    generateCode.Name=DAStudio.message('Slci:ui:GenerateCode');
    generateCode.ToolTip=DAStudio.message('Slci:ui:GenerateCodeTooltip');
    generateCode.Type='checkbox';
    generateCode.RowSpan=[1,1];
    generateCode.ColSpan=[1,3];
    generateCode.Tag=aObj.getTag('GenerateCode');
    generateCode.WidgetId=aObj.getWidgetId('GenerateCode');
    generateCode.Value=aObj.getGenerateCode();
    generateCode.DialogRefresh=true;

    codePlacement.Name=DAStudio.message('Slci:ui:CodePlacement');
    codePlacement.ToolTip=DAStudio.message('Slci:ui:CodePlacementTooltip');
    codePlacement.Type='combobox';
    codePlacement.Entries={slci.Configuration.cEmbeddedCoderPlacement,slci.Configuration.cFlatPlacement};
    codePlacement.RowSpan=[2,2];
    codePlacement.ColSpan=[1,3];
    codePlacement.Tag=aObj.getTag('CodePlacement');
    codePlacement.WidgetId=aObj.getWidgetId('CodePlacement');
    codePlacement.Value=aObj.getCodePlacement();
    codePlacement.DialogRefresh=true;
    codePlacement.Value=aObj.getCodePlacement();
    codePlacement.Visible=~aObj.getWidgetValue('GenerateCode');

    codeFolder.Name=DAStudio.message('Slci:ui:CodeFolder');
    codeFolder.ToolTip=DAStudio.message('Slci:ui:CodeFolderTooltip');
    codeFolder.Type='edit';
    codeFolder.RowSpan=[3,3];
    codeFolder.ColSpan=[1,2];
    codeFolder.Tag=aObj.getTag('CodeFolder');
    codeFolder.WidgetId=aObj.getWidgetId('CodeFolder');
    codeFolder.Value=aObj.getCodeFolder();
    codeFolder.Visible=~aObj.getWidgetValue('GenerateCode')&&...
    strcmp(aObj.getWidgetValue('CodePlacement'),slci.Configuration.cFlatPlacement);

    codeFolderBrowse.Name=DAStudio.message('Slci:ui:Browse');
    codeFolderBrowse.ToolTip=DAStudio.message('Slci:ui:CodeFolderBrowseTooltip');
    codeFolderBrowse.Type='pushbutton';
    codeFolderBrowse.Tag=aObj.getTag('CodeFolderBrowse');
    codeFolderBrowse.WidgetId=aObj.getWidgetId('CodeFolderBrowse');
    codeFolderBrowse.ObjectMethod='CodeFolderBrowseCB';
    codeFolderBrowse.RowSpan=[3,3];
    codeFolderBrowse.ColSpan=[3,3];
    codeFolderBrowse.DialogRefresh=true;
    codeFolderBrowse.Visible=~aObj.getWidgetValue('GenerateCode')&&...
    strcmp(aObj.getWidgetValue('CodePlacement'),slci.Configuration.cFlatPlacement);

    reportFolder.Name=DAStudio.message('Slci:ui:ReportFolder');
    reportFolder.ToolTip=DAStudio.message('Slci:ui:ReportFolderTooltip');
    reportFolder.Type='edit';
    reportFolder.RowSpan=[4,4];
    reportFolder.ColSpan=[1,2];
    reportFolder.Tag=aObj.getTag('ReportFolder');
    reportFolder.WidgetId=aObj.getWidgetId('ReportFolder');
    reportFolder.Value=aObj.getReportFolder();

    reportFolderBrowse.Name=DAStudio.message('Slci:ui:Browse');
    reportFolderBrowse.ToolTip=DAStudio.message('Slci:ui:ReportFolderBrowseTooltip');
    reportFolderBrowse.Type='pushbutton';
    reportFolderBrowse.Tag=aObj.getTag('ReportFolderBrowse');
    reportFolderBrowse.WidgetId=aObj.getWidgetId('ReportFolderBrowse');
    reportFolderBrowse.ObjectMethod='ReportFolderBrowseCB';
    reportFolderBrowse.RowSpan=[4,4];
    reportFolderBrowse.ColSpan=[3,3];
    reportFolderBrowse.DialogRefresh=true;

    if aObj.getWidgetValue('GenerateCode')
        inspectPushButton.Name=DAStudio.message('Slci:ui:InspectAndGenerate');
        inspectPushButton.ToolTip=DAStudio.message('Slci:ui:InspectAndGenerateTooltip',aObj.getModelName());
    else
        inspectPushButton.Name=DAStudio.message('Slci:ui:Inspect');
        inspectPushButton.ToolTip=DAStudio.message('Slci:ui:InspectTooltip',aObj.getModelName());
    end
    inspectPushButton.Type='pushbutton';
    inspectPushButton.Tag=aObj.getTag('Inspect');
    inspectPushButton.WidgetId=aObj.getWidgetId('Inspect');
    inspectPushButton.ObjectMethod='InspectCB';
    inspectPushButton.MethodArgs={'%dialog'};
    inspectPushButton.ArgDataTypes={'handle'};
    inspectPushButton.RowSpan=[5,5];
    inspectPushButton.ColSpan=[1,1];

    inspectionGroup.Type='group';
    inspectionGroup.Name=DAStudio.message('Slci:ui:InspectionGroup');
    inspectionGroup.Items={generateCode,codePlacement,codeFolder,codeFolderBrowse,reportFolder,reportFolderBrowse,inspectPushButton};
    inspectionGroup.LayoutGrid=[5,3];
    inspectionGroup.ColStretch=[0,1,0];
    inspectionGroup.RowSpan=[4,4];
    inspectionGroup.ColSpan=[1,1];

    panel.LayoutGrid=[4,1];
    panel.Type='panel';
    panel.Items={mdlRefGroup,sharedUtilsGroup,incompatibilityGroup,inspectionGroup};

    dlg.Items={panel};
    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/toolbox/slci/helptargets.map'],'slci_gui_help'};
    dlg.PostApplyMethod='ApplyCB';
    dlg.PostApplyArgs={'%dialog','Apply'};
    dlg.PostApplyArgsDT={'handle','string'};
    dlg.CloseMethod='CloseCB';
end


