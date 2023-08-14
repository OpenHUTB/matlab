

function dlg=getDialogSchema(obj,~)



    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');


    dlg=obj.getBaseDialogSchema();

    keys=obj.propMap.keys;
    remove(obj.propMap,keys);

    blkVals=get_param(blockHandle,'Values');
    curLabels=blkVals{1};
    curValues=blkVals{2};

    initProps=utils.getDiscreteKnobInitialPropertiesStruct(model,obj.widgetId,obj.isLibWidget);
    defaultLabels=cell(1,length(initProps));
    defaultValues=zeros(1,length(initProps));
    for idx=1:length(initProps)
        defaultLabels{idx}=initProps(idx).stateLabels;
        defaultValues(idx)=str2double(initProps(idx).states);
    end

    if~isequal(defaultLabels,curLabels)||~isequal(defaultValues,curValues)
        for idx=1:length(curLabels)
            newProps.index=idx;
            newProps.states=curValues(idx);
            newProps.stateLabels=curLabels{idx};
            obj.propMap(idx)=newProps;
        end
    else
        for idx=1:length(initProps)
            obj.propMap(idx)=initProps(idx);
        end
    end


    labelPosition=get_param(blockHandle,'LabelPosition');
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    groupName=get_param(blockHandle,'ButtonGroupName');
    enableEnumTypeValue=get_param(blockHandle,'UseEnumeratedDataType');
    enumDataTypeValue=get_param(blockHandle,'EnumeratedDataType');
    opacity=get_param(blockHandle,'Opacity');
    colorJson=get_param(blockHandle,'BackgroundForegroundColor');
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);


    text.Type='text';
    desc=DAStudio.message('SimulinkHMI:dialogs:RadioButtonGroupDialogDesc');
    text.Name=desc;
    text.WordWrap=true;
    descGroup.Type='group';
    descGroup.Name=DAStudio.message('SimulinkHMI:dialogs:RadioButtonGroup');
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    webbrowser=dlg.Items{1};
    webbrowser.RowSpan=[2,2];
    webbrowser.ColSpan=[1,3];




    obj.tableState=~((Simulink.HMI.isLibrary(model))||...
    (utils.isLockedLibrary(model))||strcmp(enableEnumTypeValue,'on'));

    fp='toolbox/simulink/hmi/web/Dialogs/ParameterDialog';
    url=[fp,'/DiscreteKnobPropertiesWidget.html?widgetID=',obj.widgetId...
    ,'&model=',model,'&isLibWidget=',num2str(false)];

    propbrowser.Type='webbrowser';
    propbrowser.Tag='sl_hmi_RadioButtonGroupProperties';
    propbrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    propbrowser.DisableContextMenu=true;
    propbrowser.MatlabMethod='slDialogUtil';
    propbrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};
    propbrowser.RowSpan=[4,4];
    propbrowser.ColSpan=[1,3];
    propbrowser.Enabled=obj.tableState;


    enableEnumType.Type='checkbox';
    enableEnumType.Tag='EnableEnumDataType';
    enableEnumType.Name=DAStudio.message('SimulinkHMI:dialogs:RadioButtonGroupUsEnumDataType');
    enableEnumType.Value=strcmp(enableEnumTypeValue,'on');
    enableEnumType.MatlabMethod='utils.enableEnumTypeChanged';
    enableEnumType.MatlabArgs={'%dialog','%source',false};
    enableEnumType.RowSpan=[1,1];
    enableEnumType.ColSpan=[1,1];

    enumDataType.Type='edit';
    enumDataType.Tag='EnumDataTypeName';
    enumDataType.Value=enumDataTypeValue;
    enumDataType.Enabled=strcmp(enableEnumTypeValue,'on');
    enumDataType.RowSpan=[1,1];
    enumDataType.ColSpan=[2,3];

    buttonGroupName.Type='edit';
    buttonGroupName.Tag='groupname';
    buttonGroupName.Name=DAStudio.message('SimulinkHMI:dialogs:RadioButtonGroupName');
    buttonGroupName.Value=groupName;
    buttonGroupName.RowSpan=[2,2];
    buttonGroupName.ColSpan=[1,3];


    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    legendPosition.Value=labelPosition;
    legendPosition.RowSpan=[3,3];
    legendPosition.ColSpan=[1,3];


    opacityField.Type='edit';
    opacityField.Tag='opacity';
    opacityField.Name=[DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    opacityField.Value=opacity;
    opacityField.RowSpan=[1,1];
    opacityField.ColSpan=[1,3];

    colorsHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/ForegroundBackgroundColors.html';
    colorWebbrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHtmlPath,false);
    colorWebbrowser.RowSpan=[2,2];
    colorWebbrowser.ColSpan=[1,3];


    mainGroup.Type='group';
    mainGroup.Items={enableEnumType,enumDataType,...
    buttonGroupName,legendPosition,propbrowser};
    numMainItems=length(mainGroup.Items);
    mainGroup.LayoutGrid=[numMainItems+1,3];
    mainGroup.RowStretch(1:numMainItems)=0;
    mainGroup.RowStretch(end+1)=1;
    mainGroup.ColStretch=[0,0,1];


    formatGroup.Type='group';
    formatGroup.Items={};
    formatGroup.RowSpan=[2,3];
    formatGroup.ColSpan=[1,3];
    formatGroup.LayoutGrid=[7,3];
    formatGroup.RowStretch=[0,0,0,0,0,0,0];
    formatGroup.ColStretch=[0,0,1];


    mainTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockMainGroup');
    mainTab.Items={mainGroup};


    formatGroup.Type='group';
    formatGroup.Items={opacityField,colorWebbrowser};
    numFormatItems=length(formatGroup.Items);
    formatGroup.LayoutGrid=[numFormatItems+1,3];
    formatGroup.RowStretch(1:numFormatItems)=0;
    formatGroup.RowStretch(end+1)=1;
    formatGroup.ColStretch=[0,0,1];


    formatTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockFormatGroup');
    formatTab.Items={formatGroup};


    tabContainer.Type='tab';
    tabContainer.Name='tabContainer';
    tabContainer.Tabs={mainTab,formatTab};

    dlg.Items={descGroup,webbrowser,tabContainer};
    dlg.LayoutGrid=[3,3];

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};
    dlg.DialogRefresh=true;

    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],'hmi_radio_button'};
end



