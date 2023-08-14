function out=getConfigSetRefDialogSchema(hController,schemaName)




    hSrc=hController.getSourceObject;
    inModelExplorer=schemaName~="simprm";
    showLocalConfigSet=slfeature('ConfigSetRefOverride')&&~inModelExplorer;

    openSource_Name=message('RTW:configSet:refOpenSourceName').getString;
    sourceName_ToolTip=message('RTW:configSet:refSourceToolTip').getString;
    openSource_ToolTip=message('RTW:configSet:refOpenSourceToolTip').getString;

    iconPath=fullfile(matlabroot,'toolbox','shared','dastudio','resources');






    if~isempty(hController.DataDictionary)
        if isempty(hSrc.DDName)
            [~,name,ext]=fileparts(hController.DataDictionary);
            hSrc.DDName=[name,ext];
        end
    end

    cleanupTask=[];

    if showLocalConfigSet
        if~isempty(hSrc.LocalConfigSet)
            hSrc.LocalConfigSet.lock;
            cleanupTask=onCleanup(@()hSrc.LocalConfigSet.unlock);
        end
    end


    me=[];
    errorMessage='';
    try
        hSrc.getRefConfigSet;
        if showLocalConfigSet&&isempty(hSrc.LocalConfigSet)
            hSrc.refresh('LocalConfigSet');
        end
    catch me

        errorMessage=me.message;
    end


    delete(cleanupTask);


    position=hSrc.ConfigPrmDlgPosition;
    if~any(position)

        if isa(hSrc.LocalConfigSet,'Simulink.ConfigSet')
            position=get_param(hSrc.LocalConfigSet,'ConfigPrmDlgPosition');
            if any(position)

                hSrc.ConfigPrmDlgPosition=position-[20,20,0,0];
            end
        end
    end


    configSetList=configset.internal.util.getReferenceableConfigSets(hSrc);

    tag='Tag_ConfigSetRef_';
    widgetId='Simulink.ConfigSetRef.';


    sourceName_tag='SourceName';
    sourceName.Type='combobox';
    sourceName.Tag=[tag,sourceName_tag];
    sourceName.WidgetId=['Simulink.ConfigSetME.',sourceName_tag];
    sourceName.Editable=true;
    sourceName.Source=hSrc;
    sourceName.ObjectProperty='SourceName';
    sourceName.Entries=configSetList;
    sourceName.Mode=true;
    if slfeature('ConfigSetRefOverride')
        sourceName.MatlabMethod='configset.internal.util.sourceNameChange';
        sourceName.MatlabArgs={hSrc,1};
    end
    sourceName.DialogRefresh=true;
    sourceName.ToolTip=sourceName_ToolTip;
    sourceName.Enabled=~hSrc.isReadonlyProperty('SourceName');

    widget=[];
    widget.Type='text';
    widget.Name=getString(message('RTW:configSet:refOverview'));
    overview=widget;

    widget=[];
    widget.Type='text';
    if showLocalConfigSet
        widget.Name=getString(message('RTW:configSet:refSourceName'));
    else
        widget.Name=getString(message('RTW:configSet:SourceNameLbl'));
    end
    widget.Buddy=sourceName.Tag;
    sourceNameLabel=widget;


    widget=[];
    widget.Type='image';
    widget.FilePath=fullfile(iconPath,'warning_16.png');
    widget.Alignment=7;
    widget.Visible=~isempty(me);
    widget.ToolTip=errorMessage;
    warningIcon=widget;

    if showLocalConfigSet

        try

            refObject=hSrc.getRefObject;
        catch
            refObject=[];
        end
        if isa(refObject,'Simulink.ConfigSetRef')
            widget=[];
            widget.Type='combobox';
            widget.Tag=[tag,'SourceName2'];
            widget.WidgetId=[widgetId,'SourceName2'];
            widget.Editable=true;

            widget.Value=refObject.SourceName;
            widget.Entries=configset.internal.util.getReferenceableConfigSets(refObject);
            widget.Enabled=~isReadonlyProperty(refObject,'SourceName');
            widget.Mode=true;
            widget.DialogRefresh=true;
            widget.Source=refObject;
            widget.ObjectProperty='SourceName';
            widget.ToolTip=sourceName_ToolTip;
            if slfeature('ConfigSetRefOverride')
                widget.MatlabMethod='configset.internal.util.sourceNameChange';
                widget.MatlabArgs={hSrc,2};
            end
            sourceName2=widget;
        else
            sourceName2=[];
        end


        widget=[];
        widget.Tag=[tag,'SplitButton'];
        widget.WidgetId=[widgetId,'SplitButton'];
        widget.Type='splitbutton';
        widget.ActionCallback=@actionCallback;
        widget.ActionEntries={...
        configset.internal.util.ActionEntry('RTW:configSet:refOpenSourceDescription',...
        [tag,'OpenSourceAction'],...
        fullfile(iconPath,'Configuration.png'),...
        hSrc.SourceResolved=="on",...
        'RTW:configSet:refOpenSourceToolTip'),...
        configset.internal.util.ActionEntry('RTW:configSet:refRefreshName',[tag,'RefreshAction'],...
        fullfile(iconPath,'refresh_16.png'),true,...
        'RTW:configSet:refRefreshName'),...
        };
        if slfeature('ConfigSetRefOverride')==2

            override=hSrc.SourceResolved=="on"&&isa(hSrc.LocalConfigSet,'Simulink.ConfigSetRoot')&&...
            ~hSrc.isObjectLocked&&~isempty(hSrc.ParameterOverrides);
            widget.ActionEntries{end+1}=...
            configset.internal.util.ActionEntry('RTW:configSet:refRestoreAllName',...
            [tag,'RestoreAllAction'],...
            fullfile(iconPath,'previous.png'),...
            override,...
            'RTW:configSet:refRestoreAllToolTip');
        end

        if widget.ActionEntries{1}.getEnabled
            defaultAction=widget.ActionEntries{1};
        else
            defaultAction=widget.ActionEntries{2};
        end
        widget.DefaultAction=defaultAction.getTag;
        widget.FilePath=defaultAction.getDisplayIcon;
        widget.ToolTip=defaultAction.ToolTip;
        if~isempty(defaultAction.DisplayIcon)
            widget.ButtonStyle='IconOnly';
            widget.UseButtonStyleForDefaultAction=true;
        else
            widget.ButtonStyle='TextOnly';
        end
        widget.Enabled=true;
        splitButton=widget;
    else
        widget=[];
        widget.Name=openSource_Name;
        widget.ToolTip=openSource_ToolTip;
        widget.Type='pushbutton';
        widget.Source=hController;
        widget.Tag=[tag,'OpenSource'];
        widget.WidgetId=[widgetId,'OpenSource'];
        widget.ObjectMethod='dialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.Enabled=hSrc.SourceResolved=="on";
        openSource=widget;
    end


    widget=[];
    widget.Type='text';
    widget.Name=getString(message('RTW:configSet:SourceLocationLbl'));
    widget.Tag=[tag,'SourceLocationLbl'];
    widget.WidgetId=[widgetId,'SourceLocationLbl'];
    sourceLocationLabel=widget;

    sourceLocation_tag='SourceLocation';
    sourceLocation.Type='hyperlink';
    if~isempty(hSrc.DDName)&&hSrc.SourceResolvedInBaseWorkspace=="off"
        sourceLocation.Name=hSrc.DDName;
        sourceLocation.MatlabMethod='configset.internal.util.showConfigSetInDataDictionary';
        sourceLocation.MatlabArgs={hSrc.DDName};
    else
        sourceLocation.Name=getString(message('Simulink:dialog:WorkspaceLocation_Base'));
        sourceLocation.MatlabMethod='configset.internal.util.showConfigSetInBaseWorkspace';
        sourceLocation.MatlabArgs={};
    end
    sourceLocation.Tag=[tag,sourceLocation_tag];
    sourceLocation.WidgetId=[widgetId,sourceLocation_tag];
    sourceLocation.Alignment=1;
    sourceLocation.Buddy=[tag,'SourceLocationLbl'];


    widget=[];
    widget.Type='text';
    widget.Name=configset.internal.util.getConfigSetRefDiagnosticMessage(me,false);
    widget.Italic=1;
    widget.WordWrap=true;
    widget.Visible=~isempty(me);
    widget.WidgetId=[widgetId,'refreshErrorMessage'];
    widget.Tag=[tag,'refreshErrorMessage'];
    refreshErrorMessage=widget;

    widget=[];
    widget.Type='text';
    widget.Name='>';
    bracket=widget;

    if showLocalConfigSet
        bracket2=bracket;
        bracket2.Visible=~isempty(sourceName2);

        warningIcon2=warningIcon;
        warningIcon2.Visible=showLocalConfigSet&&warningIcon.Visible&&~isempty(sourceName2);
        if warningIcon2.Visible

            warningIcon.Visible=false;
        end
    end


    widget=[];
    widget.Type='group';
    if~isempty(hSrc.getModel)
        modelName=get_param(hSrc.getModel,'Name');
        widget.Name=getString(message('RTW:configSet:configSetRefPropertiesShortDescription',modelName));
    else
        widget.Name=getString(message('RTW:configSet:ReferencedConfigurationGroupLbl'));
    end
    widget.WidgetId=[widgetId,'ReferencedConfigurationGroup'];
    widget.Tag=[tag,'ReferencedConfigurationGroup'];
    if showLocalConfigSet
        overview.RowSpan=[2,2];
        overview.ColSpan=[1,10];
        if isempty(sourceName2)
            widget.Items={...
            sourceNameLabel,sourceLocation,bracket,warningIcon,sourceName,...
            bracket2,warningIcon2,...
            splitButton,...
            overview};
        else
            widget.Items={...
            sourceNameLabel,sourceLocation,bracket,warningIcon,sourceName,...
            bracket2,warningIcon2,sourceName2,...
            splitButton,...
            overview};
        end
        widget.LayoutGrid=[2,10];
        widget.ColStretch=[0,0,0,0,0,0,0,0,0,1];
    else
        sourceNameLabel.RowSpan=[1,1];
        sourceNameLabel.ColSpan=[1,1];
        warningIcon.RowSpan=[1,1];
        warningIcon.ColSpan=[2,2];
        sourceName.RowSpan=[1,1];
        sourceName.ColSpan=[3,3];
        openSource.RowSpan=[1,1];
        openSource.ColSpan=[4,4];
        sourceLocationLabel.RowSpan=[3,3];
        sourceLocationLabel.ColSpan=[1,2];
        sourceLocation.RowSpan=[3,3];
        sourceLocation.ColSpan=[3,3];
        refreshErrorMessage.RowSpan=[2,2];
        refreshErrorMessage.ColSpan=[3,4];
        widget.Items={...
        sourceNameLabel,sourceName,openSource,...
        sourceLocationLabel,sourceLocation,...
        warningIcon,refreshErrorMessage};
        widget.LayoutGrid=[3,4];
        widget.ColStretch=[0,0,1,0];
    end
    out={widget};

    if~isempty(me)

        localConfigSet.Type='textbrowser';
        localConfigSet.Tag=[tag,'DiagnosticMessage'];
        localConfigSet.Text=configset.internal.util.getConfigSetRefDiagnosticMessage(me,true);
        localConfigSet.Alignment=0;
        out=[out,localConfigSet];
    end

    function actionCallback(dlg,~,tag)



        dlg.setEnabled('Tag_ConfigSetRef_SplitButton',false);
        cleanup=onCleanup(@()dlg.setEnabled('Tag_ConfigSetRef_SplitButton',true));

        controller=dlg.getDialogSource;
        csr=controller.Source.Source;


        lock=configset.internal.util.getConfigSetAdapterLockGuard(csr);%#ok<NASGU>

        switch tag
        case 'Tag_ConfigSetRef_RefreshAction'
            configset.internal.reference.refresh(csr);
            dlg.refresh;
        case 'Tag_ConfigSetRef_EditAction'
            csr.enableOverrides;
            controller.refresh;
        case 'Tag_ConfigSetRef_RestoreAllAction'
            dlg.getDialogSource.enableApplyButton(false);
            if csr.IsCache=="on"
                csr.getConfigSetSource.restoreAll;
            else
                csr.restoreAll;
            end
        case 'Tag_ConfigSetRef_OpenSourceAction'

            configset.internal.reference.openSource(csr,true,dlg);
        otherwise
            error(getString(message('RTW:configSet:unknownActionForTag',tag)));
        end


