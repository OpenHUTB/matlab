


function dlg=getSlimDialogSchema(obj,name)
    blockHandle=get(obj.blockObj,'handle');
    configJson=get_param(blockHandle,'Configuration');
    config=jsondecode(configJson);
    obj.ConfigurationJSON=configJson;

    if strcmp(name,'Simulink:Dialog:Parameters')
        if isfield(config,'type')
            if strcmp(config.type,'CircularGauge')||strcmp(config.type,'LinearGauge')
                dlg=locGetGaugeSlimDialogSchema(obj,blockHandle,config);
            elseif strcmp(config.type,'Lamp')
                dlg=locGetLampSlimDialogSchema(obj,blockHandle,config);
            end
        end
    else
        dlg=locGetCustomizeSlimDialogSchema(obj,config);
    end
end

function dlg=locGetGaugeSlimDialogSchema(obj,blockHandle,config)
    model=get_param(bdroot(blockHandle),'Name');

    dlg=obj.getBaseSlimDialogSchema();

    blockOrientation=get_param(blockHandle,'Orientation');
    bounds=[];
    obj.ScaleColors=[];
    type=config.type;
    components=config.components;
    if~isempty(components)
        for index=1:length(components)
            if strcmp(components(index).name,'LinearScaleComponent')||...
                strcmp(components(index).name,'CircularScaleComponent')
                if isfield(components(index).settings,'scaleColors')
                    for scIdx=1:length(components(index).settings.scaleColors)
                        scaleColor=components(index).settings.scaleColors(scIdx);
                        scaleColor.Color=scaleColor.Color/255;
                        obj.ScaleColors=[obj.ScaleColors,scaleColor];
                    end
                end
                bounds=components(index).settings.bounds;
            end
        end
    end

    if strcmp(type,'LinearGauge')
        if strcmp(blockOrientation,'right')||strcmp(blockOrientation,'left')
            dlg.DialogTitle=DAStudio.message('CustomWebBlocks:messages:HorizontalGauge');
        else
            dlg.DialogTitle=DAStudio.message('CustomWebBlocks:messages:VerticalGauge');
        end
    elseif strcmp(type,'CircularGauge')
        dlg.DialogTitle=DAStudio.message('CustomWebBlocks:messages:CircularGauge');
    end

    if isempty(bounds)
        bounds=struct('min',0,'max',100,'tickInterval','auto');
    end

    if isempty(obj.ScaleColors)
        obj.ScaleColors=get_param(blockHandle,'ScaleColors');
    end


    minimumValueTxt.Type='text';
    minimumValueTxt.Name=DAStudio.message('SimulinkHMI:dialogs:MinimumPrompt');
    minimumValueTxt.WordWrap=true;
    minimumValueTxt.RowSpan=[2,2];
    minimumValueTxt.ColSpan=[1,3];

    minimumValue.Type='edit';
    minimumValue.Tag='minimumValue';
    minimumValue.Value=bounds.min;
    minimumValue.RowSpan=[2,2];
    minimumValue.ColSpan=[4,5];
    minimumValue.MatlabMethod='customwebblocks.utils.gaugeSettingsChanged';
    minimumValue.MatlabArgs={'%dialog',obj};


    maximumValueTxt.Type='text';
    maximumValueTxt.Name=DAStudio.message('SimulinkHMI:dialogs:MaximumPrompt');
    maximumValueTxt.WordWrap=true;
    maximumValueTxt.RowSpan=[3,3];
    maximumValueTxt.ColSpan=[1,3];

    maximumValue.Type='edit';
    maximumValue.Tag='maximumValue';
    maximumValue.Value=bounds.max;
    maximumValue.RowSpan=[3,3];
    maximumValue.ColSpan=[4,5];
    maximumValue.MatlabMethod='customwebblocks.utils.gaugeSettingsChanged';
    maximumValue.MatlabArgs={'%dialog',obj};


    tickValueTxt.Type='text';
    tickValueTxt.Name=DAStudio.message('SimulinkHMI:dialogs:TickIntervalPrompt');
    tickValueTxt.WordWrap=true;
    tickValueTxt.RowSpan=[4,4];
    tickValueTxt.ColSpan=[1,3];

    tickValue.Type='edit';
    tickValue.Tag='tickInterval';
    tickValue.Value=bounds.tickInterval;
    tickValue.RowSpan=[4,4];
    tickValue.ColSpan=[4,5];
    tickValue.MatlabMethod='customwebblocks.utils.gaugeSettingsChanged';
    tickValue.MatlabArgs={'%dialog',obj};


    scColorsBrowser.Type='webbrowser';
    scColorsBrowser.RowSpan=[8,8];
    scColorsBrowser.ColSpan=[1,5];
    htmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/GaugesScaleColors.html';
    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,...
    '&isLibWidget=',num2str(obj.isLibWidget),'&isSlimDialog=',num2str(true)];
    scColorsBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    scColorsBrowser.Tag='gauge_scalecolors_browser';
    scColorsBrowser.DisableContextMenu=true;


    lockAspectRatio=locGetAspectRatioCheckbox(obj,blockHandle,config);
    lockAspectRatio.RowSpan=[7,7];
    lockAspectRatio.ColSpan=[1,3];


    [legendPositionLabel,legendPosition]=locGetLabelPositionDropdown(obj,blockHandle,config);
    legendPositionLabel.RowSpan=[6,6];
    legendPositionLabel.ColSpan=[1,3];
    legendPosition.RowSpan=[6,6];
    legendPosition.ColSpan=[4,5];

    scaleDirectionLabel.Type='text';
    scaleDirectionLabel.Tag='scaleDirectionLabel';
    scaleDirectionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:GaugeBlockScaleDirectionPrompt');
    scaleDirectionLabel.Buddy='scaleDirection';
    scaleDirectionLabel.RowSpan=[5,5];
    scaleDirectionLabel.ColSpan=[1,3];

    scaleDirection.Type='combobox';
    scaleDirection.Tag='scaleDirection';
    scaleDirection.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionClockwise'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionCounterclockwise')
    };
    scaleDirection.Value=get_param(blockHandle,'ScaleDirection');
    scaleDirection.MatlabMethod='customwebblocks.utils.scaleDirectionCallback';
    scaleDirection.MatlabArgs={'%dialog',obj};
    scaleDirection.RowSpan=[5,5];
    scaleDirection.ColSpan=[4,5];


    dlg.Items=[dlg.Items,{minimumValueTxt,minimumValue,...
    maximumValueTxt,maximumValue,...
    tickValueTxt,tickValue,...
    scaleDirectionLabel,scaleDirection,...
    legendPositionLabel,legendPosition,...
lockAspectRatio...
    ,scColorsBrowser}];

    dlg.DialogTag=obj.getBlock.BlockType;
    dlg.DialogMode='Slim';
    dlg.LayoutGrid=[8,5];
    dlg.RowStretch=[0,0,0,0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
end

function dlg=locGetLampSlimDialogSchema(obj,blockHandle,config)
    dlg=obj.getBaseSlimDialogSchema();
    model=get_param(bdroot(blockHandle),'Name');


    signalPanel=locGetSignalPanel(dlg.Items);
    signalPanel.RowSpan=[1,1];
    signalPanel.ColSpan=[1,1];


    [labelDropdownLabel,labelDropdown]=locGetLabelPositionDropdown(obj,blockHandle,config);
    labelDropdownLabel.RowSpan=[1,1];
    labelDropdownLabel.ColSpan=[1,1];
    labelDropdown.RowSpan=[1,1];
    labelDropdown.ColSpan=[2,2];


    aspectRatioCheckbox=locGetAspectRatioCheckbox(obj,blockHandle,config);
    aspectRatioCheckbox.RowSpan=[2,2];
    aspectRatioCheckbox.ColSpan=[1,2];


    mainPanel.Name=DAStudio.message('Simulink:dialog:Main');
    mainPanel.Type='togglepanel';
    mainPanel.Expand=true;
    mainPanel.RowSpan=[2,2];
    mainPanel.ColSpan=[1,1];
    mainPanel.Source=blockHandle;
    mainPanel.LayoutGrid=[5,2];
    mainPanel.Items={...
    labelDropdownLabel,labelDropdown,...
    aspectRatioCheckbox};
    mainPanel.RowStretch=[0,0,0,0,1];
    mainPanel.ColStretch=[0,1];


    settings=customwebblocks.utils.getLampSettingsForDialog(blockHandle,config);
    stateValueType.Type='checkbox';
    stateValueType.Tag='stateValueType';
    stateValueType.Name=DAStudio.message('CustomWebBlocks:messages:SpecifyValuesAsRanges');
    stateValueType.Value=strcmpi(settings.stateValueType,'range');
    stateValueType.MatlabMethod='customwebblocks.utils.applyLampSettingsFromDialog';
    stateValueType.MatlabArgs={'%dialog',obj};
    stateValueType.RowSpan=[1,1];
    stateValueType.ColSpan=[1,1];


    debugMode=DAStudio.CustomWebBlocks.getDebugMode(blockHandle);
    if debugMode
        htmlPath='toolbox/simulink/webblocks/customwebblocks-states-table/index-debug.html';
        statesBrowser.EnableInspectorOnLoad=true;
    else
        htmlPath='toolbox/simulink/webblocks/customwebblocks-states-table/index.html';
    end
    url=[htmlPath...
    ,'?widgetId=',obj.widgetId...
    ,'&model=',model...
    ,'&blockHandle=',num2str(blockHandle,64)...
    ,'&isSlimDialog=',num2str(true)];
    statesBrowser.Type='webbrowser';
    statesBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    statesBrowser.Tag='lamp_properties_browser';
    statesBrowser.DisableContextMenu=true;
    statesBrowser.RowSpan=[2,2];
    statesBrowser.ColSpan=[1,1];
    statesBrowser.Enabled=~(customwebblocks.utils.isLibrary(model)||customwebblocks.utils.isBlockInLockedSystem(obj.blockObj));


    statesPanel.Name=DAStudio.message('CustomWebBlocks:messages:StateList');
    statesPanel.Type='togglepanel';
    statesPanel.Expand=true;
    statesPanel.RowSpan=[3,3];
    statesPanel.ColSpan=[1,1];
    statesPanel.Source=blockHandle;
    statesPanel.LayoutGrid=[2,1];
    statesPanel.Items={...
    stateValueType,...
    statesBrowser};
    statesPanel.RowStretch=[0,1];
    statesPanel.ColStretch=1;


    dlg.Items={signalPanel,mainPanel,statesPanel};
    dlg.LayoutGrid=[3,1];
    dlg.RowStretch=[0,0,1];
    dlg.ColStretch=1;
end

function signalPanel=locGetSignalPanel(baseItems)
    signalPanel.Type='togglepanel';
    signalPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockSignalTitle');
    signalPanel.Items=baseItems;
    signalPanel.Expand=true;
    signalPanel.LayoutGrid=[1,5];
    signalPanel.RowStretch=1;
    signalPanel.ColStretch=[0,0,0,0,1];
end

function[labelDropdownLabel,labelDropdown]=locGetLabelPositionDropdown(obj,blockHandle,~)


    model=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(model)
        labelPosition=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end


    labelDropdownLabel.Type='text';
    labelDropdownLabel.Tag='labelPositionLabel';
    labelDropdownLabel.Name=DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    labelDropdownLabel.Buddy='legendPosition';
    labelDropdown.Type='combobox';
    labelDropdown.Tag='labelPosition';
    labelDropdown.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    labelDropdown.Value=labelPosition;
    labelDropdown.MatlabMethod='customwebblocks.utils.labelPositionCallback';
    labelDropdown.MatlabArgs={'%dialog',obj};
end

function aspectRatioCheckbox=locGetAspectRatioCheckbox(obj,~,config)


    fixedAspectRatio='on';
    if isfield(config,'settings')&&...
        isfield(config.settings,'fixedAspectRatio')
        fixedAspectRatio=config.settings.fixedAspectRatio;
    end


    aspectRatioCheckbox.Type='checkbox';
    aspectRatioCheckbox.Tag='lockAspectRatio';
    aspectRatioCheckbox.Name=DAStudio.message('CustomWebBlocks:messages:LockAspectRatio');
    aspectRatioCheckbox.Value=strcmp(fixedAspectRatio,'on');
    aspectRatioCheckbox.MatlabMethod='customwebblocks.utils.lockAspectRatioCallback';
    aspectRatioCheckbox.MatlabArgs={'%dialog',obj};
end

function dlg=locGetCustomizeSlimDialogSchema(obj,config)
    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');
    debugMode=DAStudio.CustomWebBlocks.getDebugMode(blockHandle);
    isPanelBlock=isBlockInWebPanel(blockHandle);
    isWEMActive=false;
    isLocked=customwebblocks.utils.isBlockInLockedSystem(obj.blockObj);
    version='';
    if isfield(config.settings,'version')
        version=config.settings.version;
    end

    obj.metadata=get_param(blockHandle,'dlgMetadata');


    customizationBroswer.Type='webbrowser';
    customizationBroswer.RowSpan=[1,1];
    customizationBroswer.ColSpan=[1,5];
    if isequal(debugMode,true)
        htmlPath='toolbox/simulink/webblocks/customwebblocks-dialogs/index-debug.html';
    else
        htmlPath='toolbox/simulink/webblocks/customwebblocks-dialogs/index.html';
    end

    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,'&blockHandle=',num2str(blockHandle,64),...
    '&isLocked=',num2str(isLocked),'&isSlimDialog=',num2str(true),...
    '&isWEMActive=',num2str(isWEMActive),'&instanceName=',config.type,'&version=',version,...
    '&isPanelBlock=',num2str(isPanelBlock),'&WebBlocksPanelHistory=',num2str(slfeature('WebBlocksPanelHistory'))];
    customizationBroswer.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    customizationBroswer.Tag='customization_browser';
    customizationBroswer.DisableContextMenu=true;


    dlg.Items={customizationBroswer};
    dlg.LayoutGrid=[1,5];
    dlg.RowStretch=[1];
    dlg.ColStretch=[0,0,0,0,1];
    dlg.DialogTag=obj.getBlock.BlockType;
    dlg.DialogTitle='';
    dlg.DialogMode='Slim';
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};
    dlg.IsScrollable=false;

    dlg.CloseMethod='closeDialogCB';
    dlg.CloseMethodArgs={'%dialog','%closeaction'};
    dlg.CloseMethodArgsDT={'handle','string'};
end
