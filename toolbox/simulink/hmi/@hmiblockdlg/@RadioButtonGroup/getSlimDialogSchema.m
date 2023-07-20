function dlg=getSlimDialogSchema(obj,~)




    dlg=obj.getBaseSlimDialogSchema();
    labelPosition=obj.getBlock().LabelPosition;
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);

    useEnumDataType=strcmp(obj.getBlock().UseEnumeratedDataType,'on');


    hBlk=get(obj.getBlock(),'handle');
    model=get_param(bdroot(hBlk),'Name');

    keys=obj.propMap.keys;
    remove(obj.propMap,keys);

    opacity=obj.getBlock().Opacity;
    colorJson=obj.getBlock().BackgroundForegroundColor;
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);
    blkVals=get_param(hBlk,'Values');
    curLabels=blkVals{1};
    curValues=blkVals{2};

    initProps=utils.getDiscreteKnobInitialPropertiesStruct(model,obj.widgetId,obj.isLibWidget);
    defaultLabels=cell(size(initProps));
    defaultValues=zeros(size(initProps));
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



    enableEnumType.Type='checkbox';
    enableEnumType.Tag='UseEnumDataType';
    enableEnumType.Name=DAStudio.message('SimulinkHMI:dialogs:RadioButtonGroupUsEnumDataType');
    enableEnumType.Source=obj;
    enableEnumType.Value=useEnumDataType;
    enableEnumType.MatlabMethod='utils.slimDialogUtils.setUseEnumDataType';
    enableEnumType.MatlabArgs={'%dialog','%source','%tag','%value'};
    enableEnumType.RowSpan=[1,1];
    enableEnumType.ColSpan=[1,2];

    enumDataType.Type='edit';
    enumDataType.Tag='EnumDataType';
    enumDataType.Source=obj;
    enumDataType.Value=obj.getBlock().EnumeratedDataType;
    enumDataType.Enabled=enableEnumType.Value;
    enumDataType.MatlabMethod='utils.slimDialogUtils.setEnumDataType';
    enumDataType.MatlabArgs={'%dialog','%source','%tag','%value'};
    enumDataType.RowSpan=[1,1];
    enumDataType.ColSpan=[3,5];




    buttonGroupNameLabel.Type='text';
    buttonGroupNameLabel.Tag='buttonGroupNameLabel';
    buttonGroupNameLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:RadioButtonGroupName');
    buttonGroupNameLabel.RowSpan=[2,2];
    buttonGroupNameLabel.ColSpan=[1,2];

    buttonGroupName.Type='edit';
    buttonGroupName.Tag='RadioButtonGroupName';
    buttonGroupName.Source=obj;
    buttonGroupName.Value=obj.getBlock().ButtonGroupName;
    buttonGroupName.MatlabMethod='utils.slimDialogUtils.setRadioButtonGroupName';
    buttonGroupName.MatlabArgs={'%dialog','%source','%tag','%value'};
    buttonGroupName.RowSpan=[2,2];
    buttonGroupName.ColSpan=[3,5];



    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.RowSpan=[3,3];
    legendPositionLabel.ColSpan=[1,2];

    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Source=obj;
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    legendPosition.Value=labelPosition;
    legendPosition.MatlabMethod='utils.slimDialogUtils.setCoreBlockLabelPosition';
    legendPosition.MatlabArgs={'%dialog','%source','%tag','%value'};
    legendPosition.RowSpan=[3,3];
    legendPosition.ColSpan=[3,5];


    obj.tableState=~((Simulink.HMI.isLibrary(model))||...
    (utils.isLockedLibrary(model))||useEnumDataType);

    fp='toolbox/simulink/hmi/web/Dialogs/ParameterDialog';
    url=[fp,'/DiscreteKnobPropertiesWidget.html?widgetID=',obj.widgetId...
    ,'&model=',model,'&isLibWidget=',num2str(false),...
    '&isSlimDialog=',num2str(true)];

    propbrowser.Type='webbrowser';
    propbrowser.Tag='sl_hmi_RadioButtonGroupProperties';
    propbrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    propbrowser.DisableContextMenu=true;
    propbrowser.MatlabMethod='slDialogUtil';
    propbrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};
    propbrowser.RowSpan=[4,4];
    propbrowser.ColSpan=[1,5];
    propbrowser.Enabled=obj.tableState;


    opacityLabel.Type='text';
    opacityLabel.Tag='opacityLabel';
    opacityLabel.Name=[DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    opacityLabel.RowSpan=[1,1];
    opacityLabel.ColSpan=[1,3];

    opacityCB.Type='edit';
    opacityCB.Tag='opacity';
    opacityCB.Source=obj;
    opacityCB.Value=opacity;
    opacityCB.MatlabMethod='utils.slimDialogUtils.setDashboardBlockTransparency';
    opacityCB.MatlabArgs={'%dialog','%source','%tag','%value'};
    opacityCB.RowSpan=[1,1];
    opacityCB.ColSpan=[4,5];

    colorsHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/ForegroundBackgroundColors.html';
    colorWebbrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHtmlPath,true);
    colorWebbrowser.PreferredSize=[100,250];
    colorWebbrowser.RowSpan=[2,2];
    colorWebbrowser.ColSpan=[1,5];


    mainPanel.Type='togglepanel';
    mainPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockMainGroup');
    mainPanel.Expand=true;
    mainPanel.Items={enableEnumType,enumDataType,...
    buttonGroupNameLabel,buttonGroupName,...
    legendPositionLabel,legendPosition,propbrowser};
    numMainItems=length(mainPanel.Items);
    mainPanel.LayoutGrid=[numMainItems+1,5];
    mainPanel.RowStretch(1:numMainItems)=0;
    mainPanel.RowStretch(end+1)=1;
    mainPanel.ColStretch=[0,0,0,0,1];
    mainPanel.RowSpan=[2,2];
    mainPanel.ColSpan=[1,5];


    formatPanel.Type='togglepanel';
    formatPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockFormatGroup');
    formatPanel.Items={opacityLabel,opacityCB,colorWebbrowser};
    numColorItems=length(formatPanel.Items);
    formatPanel.LayoutGrid=[numColorItems,5];
    formatPanel.RowStretch(1:numColorItems)=0;
    formatPanel.RowStretch(numColorItems)=1;
    formatPanel.ColStretch=[0,0,0,0,1];
    formatPanel.RowSpan=[3,3];
    formatPanel.ColSpan=[1,5];
    formatPanel.Expand=true;


    signalPanel.Type='togglepanel';
    signalPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockSignalTitle');
    signalPanel.Items=dlg.Items;
    signalPanel.Expand=true;
    signalPanel.LayoutGrid=[1,5];
    signalPanel.RowStretch=[1];
    signalPanel.ColStretch=[0,0,0,0,1];
    signalPanel.RowSpan=[1,1];
    signalPanel.ColSpan=[1,5];


    dlg.LayoutGrid=[7,5];
    dlg.RowStretch=[0,0,0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];

    dlg.Items={signalPanel,mainPanel,formatPanel};
end



