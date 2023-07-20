function dlg=getDialogSchema(hObj,schema)




    if schema=="rename"
        dlg=getConfigSetRenameDialogSchema(hObj,schema);
        return
    end

    tag='Tag_ConfigSetME_';
    widgetId='Simulink.ConfigSetME.';
    if isempty(schema)
        schema='convertToCSRef';
    end

    if isa(hObj.node,'Simulink.BlockDiagram')
        mdl=hObj.node.handle;
    else
        mdl=hObj.node.getModel;
    end
    ddname=get_param(mdl,'DataDictionary');
    if isempty(ddname)
        dd=false;
    else
        dd=true;
    end




    descr.Type='text';
    switch schema
    case 'convertToCSRef'
        descr.Name=getString(message('Simulink:ConfigSet:ConfigSetMECase1Descr'));
    case 'addCSRefOnly'
        descr.Name=getString(message('Simulink:ConfigSet:ConfigSetMECase2Descr'));
    case 'propagateCSRef'
        descr.Name=getString(message('Simulink:ConfigSet:ConfigSetMECase3Descr'));
    end
    descr.WordWrap=true;
    descr.RowSpan=[1,1];
    descr.ColSpan=[1,2];

    descrGrp.Type='group';
    descrGrp.Name=getString(message('RTW:configSet:configSetObjectivesGroupName'));
    descrGrp.Items={descr};
    descrGrp.RowSpan=[1,1];
    descrGrp.ColSpan=[1,2];


    sourceLocation_tag='sourceLocation';
    sourceLocation_str=getString(message('RTW:configSet:SourceLocationLbl'));
    baseWorkSpace_str='Base Workspace';
    dataDictionary_str='Data Dictionary';

    sourceLocation.Type='text';
    if dd
        sourceLocation.Name=[sourceLocation_str,' ',ddname,' (',dataDictionary_str,')'];
    else
        sourceLocation.Name=[sourceLocation_str,' ',baseWorkSpace_str];
    end

    sourceLocation.Tag=[tag,sourceLocation_tag];
    sourceLocation.WidgetId=[widgetId,sourceLocation_tag];
    sourceLocation.RowSpan=[1,1];
    sourceLocation.ColSpan=[1,2];

    configSetList=[configset.internal.util.getConfigSetList(ddname,'Simulink.ConfigSetRef')...
    ,configset.internal.util.getConfigSetList(ddname)];

    sourceName_tag='SourceName';
    sourceName_str=getString(message('RTW:configSet:SourceNameLbl'));
    sourceName.Type='combobox';
    sourceName.Name=sourceName_str;
    sourceName.Tag=[tag,sourceName_tag];
    sourceName.WidgetId=['Simulink.ConfigSetME.',sourceName_tag];
    sourceName.Editable=true;
    sourceName.Entries=configSetList;
    sourceName.RowSpan=[2,2];
    sourceName.ColSpan=[1,2];
    sourceName.Mode=true;
    sourceName.ToolTip=getString(message('Simulink:ConfigSet:ConfigSetMECSNameInWSToolTip'));
    sourceName.MinimumSize=[200,25];
    if strcmp(schema,'convertToCSRef')
        sourceName.Value=hObj.node.Name;
    end
    if strcmp(schema,'addCSRefOnly')
        if isempty(sourceName.Entries)
            sourceName.Value='ConfigSet';
        end
    end


    sourceGroup.Type='panel';
    sourceGroup.LayoutGrid=[2,1];
    sourceGroup.ColStretch=1;
    sourceGroup.Items={sourceLocation,sourceName};


    saveToFile.Name=getString(message('Simulink:ConfigSet:ConfigSetMESaveCSToFileName'));
    saveToFile.ToolTip=getString(message('Simulink:ConfigSet:ConfigSetMESaveCSToFileToolTip'));
    saveToFile.Type='checkbox';
    saveToFile.ObjectProperty='saveToFile';
    saveToFile.RowSpan=[2,2];
    saveToFile.ColSpan=[1,1];
    saveToFile.Enabled=1;
    saveToFile.Visible=(hObj.sourceLocation==0);
    saveToFile.Mode=1;
    saveToFile.Tag=[tag,saveToFile.ObjectProperty];
    saveToFile.WidgetId=['Simulink.ConfigSetME.',saveToFile.ObjectProperty];
    saveToFile.ObjectMethod='dialogCallback';
    saveToFile.MethodArgs={'%dialog',saveToFile.Tag,schema};
    saveToFile.ArgDataTypes={'handle','string','string'};

    fileName.Name=getString(message('Simulink:ConfigSet:ConfigSetMESaveCSFileNameName'));
    fileName.ToolTip=getString(message('Simulink:ConfigSet:ConfigSetMESaveCSFileNameToolTip'));
    fileName.Type='edit';
    fileName.ObjectProperty='fileName';
    fileName.RowSpan=[1,1];
    fileName.ColSpan=[1,1];
    fileName.Enabled=1;
    fileName.Mode=1;
    fileName.Tag=[tag,fileName.ObjectProperty];
    fileName.WidgetId=['Simulink.ConfigSetME.',fileName.ObjectProperty];


    Browse.Name=getString(message('Simulink:ConfigSet:ConfigSetMESaveCSBrowseButtonName'));
    Browse.Type='pushbutton';
    Browse.Tag=[tag,'BrowseButton'];
    Browse.ObjectMethod='dialogCallback';
    Browse.RowSpan=[1,1];
    Browse.ColSpan=[2,2];
    Browse.MethodArgs={'%dialog',Browse.Tag,schema};
    Browse.ArgDataTypes={'handle','string','string'};
    Browse.Source=hObj;



    saveFileGrp.Type='panel';
    saveFileGrp.Tag=[tag,'saveFileGroup'];
    saveFileGrp.LayoutGrid=[1,2];
    saveFileGrp.RowSpan=[3,3];
    saveFileGrp.ColSpan=[1,2];
    saveFileGrp.Enabled=hObj.saveToFile;
    saveFileGrp.Items={fileName,Browse};

    questionGrp.Type='group';

    switch schema
    case 'convertToCSRef'
        if~dd
            questionGrp.Items={sourceGroup,saveToFile,saveFileGrp};
        else
            questionGrp.Items={sourceGroup};
        end
    case 'addCSRefOnly'
        questionGrp.Items={sourceGroup};
    case 'propagateCSRef'
        questionGrp.Items={};
        questionGrp.Visible=0;
    end

    questionGrp.LayoutGrid=[3,2];
    questionGrp.RowSpan=[2,2];
    questionGrp.ColSpan=[1,2];
    questionGrp.Enabled=1;


    OK.Name=getString(message('RTW:configSet:configSetObjectivesFinishButtonName'));
    OK.Type='pushbutton';
    OK.Tag=[tag,'OKButton'];
    OK.ObjectMethod='dialogCallback';
    OK.MethodArgs={'%dialog',OK.Tag,schema};
    OK.ArgDataTypes={'handle','string','string'};
    OK.Source=hObj;
    OK.RowSpan=[1,1];
    OK.ColSpan=[2,2];


    cancel.Name=getString(message('RTW:configSet:configSetObjectivesCancelButtonName'));
    cancel.Type='pushbutton';
    cancel.Tag=[tag,'CancelButton'];
    cancel.ObjectMethod='dialogCallback';
    cancel.MethodArgs={'%dialog',cancel.Tag,schema};
    cancel.ArgDataTypes={'handle','string','string'};
    cancel.Source=hObj;
    cancel.RowSpan=[1,1];
    cancel.ColSpan=[3,3];


    help.Name=getString(message('RTW:configSet:configSetObjectivesHelpButtonName'));
    help.Type='pushbutton';
    switch schema
    case 'convertToCSRef'
        helptag=[tag,'ConvertToCSRef_Help'];
    case 'addCSRefOnly'
        helptag=[tag,'AddCSRef_Help'];
    case 'propagateCSRef'
        helptag=[tag,'propagetCSRef_Help'];
    end
    help.Tag=helptag;
    help.ObjectMethod='dialogCallback';
    help.MethodArgs={'%dialog',help.Tag,schema};
    help.ArgDataTypes={'handle','string','string'};
    help.Source=hObj;
    help.RowSpan=[1,1];
    help.ColSpan=[4,4];

    buttonGrp.Type='panel';
    buttonGrp.LayoutGrid=[1,4];
    buttonGrp.ColStretch=[1,0,0,0];
    buttonGrp.Items={OK,cancel,help};
    buttonGrp.RowSpan=[3,3];
    buttonGrp.ColSpan=[1,1];

    LGroup.LayoutGrid=[4,1];
    LGroup.RowStretch=[0,0,0,0];
    LGroup.Type='panel';
    LGroup.Items={descrGrp,questionGrp,buttonGrp};


    switch schema
    case 'convertToCSRef'
        dialogTitle=getString(message('Simulink:ConfigSet:ConfigSetMECase1Title'));

    case 'addCSRefOnly'
        dialogTitle=getString(message('Simulink:ConfigSet:ConfigSetMECase2Title'));

    case 'propagateCSRef'
        dialogTitle=getString(message('Simulink:ConfigSet:ConfigSetMECase3Title'));
    end

    dlg.DialogTitle=dialogTitle;
    dlg.DialogTag=[tag,'Dialog_',schema];
    dlg.LayoutGrid=[3,2];
    dlg.Items={LGroup};
    dlg.StandaloneButtonSet={''};
end




