


function dlg=getSlimDialogSchema(obj,name)
    blockHandle=get(obj.blockObj,'handle');
    configJson=get_param(blockHandle,'Configuration');
    config=jsondecode(configJson);

    obj.ConfigurationJSON=configJson;

    if strcmp(name,'Simulink:Dialog:Parameters')
        dlg=obj.getBaseSlimDialogSchema();
        if isfield(config,'type')
            if strcmp(config.type,'CircularGauge')||strcmp(config.type,'LinearGauge')
                dlg=locGetSliderSlimDialogSchema(obj,blockHandle,config);
            elseif strcmp(config.type,'Button')
                if isfield(config,'settings')&&...
                    isfield(config.settings,'variant')&&...
                    strcmp(config.settings.variant,'callback')
                    dlg=locGetCallbackButtonSlimDialogSchema(obj,blockHandle,config);
                else
                    dlg=locGetPushButtonSlimDialogSchema(obj,blockHandle,config);
                end
            elseif strcmp(config.type,'Switch')||strcmp(config.type,'RotarySwitch')
                dlg=locGetSwitchSlimDialogSchema(obj,blockHandle,config);
            end
        end
    else
        dlg=locGetCustomizeSlimDialogSchema(obj,blockHandle,config);
    end
end

function dlg=locGetSliderSlimDialogSchema(obj,blockHandle,config)
    dlg=obj.getBaseSlimDialogSchema();


    connectionPanel=locGetConnectionPanel(dlg.Items);
    connectionPanel.RowSpan=[1,1];
    connectionPanel.ColSpan=[1,1];

    bounds=[];
    if isfield(config,'components')&&~isempty(config.components)
        components=config.components;
        for index=1:length(components)
            if strcmp(components(index).name,'LinearScaleComponent')||...
                strcmp(components(index).name,'CircularScaleComponent')
                if isfield(components(index).settings,'bounds')
                    bounds=components(index).settings.bounds;
                end
            end
        end
    end
    if isempty(bounds)

        bounds=struct('min',0,'max',100,'tickInterval','auto');
    end


    minimumValueLabel.Type='text';
    minimumValueLabel.Name=DAStudio.message('SimulinkHMI:dialogs:MinimumPrompt');
    minimumValueLabel.WordWrap=true;
    minimumValueLabel.RowSpan=[1,1];
    minimumValueLabel.ColSpan=[1,1];

    minimumValue.Type='edit';
    minimumValue.Tag='minimumValue';
    minimumValue.Value=bounds.min;
    minimumValue.RowSpan=[1,1];
    minimumValue.ColSpan=[2,2];
    minimumValue.MatlabMethod='customwebblocks.utils.gaugeSettingsChanged';
    minimumValue.MatlabArgs={'%dialog',obj};


    maximumValueLabel.Type='text';
    maximumValueLabel.Name=DAStudio.message('SimulinkHMI:dialogs:MaximumPrompt');
    maximumValueLabel.WordWrap=true;
    maximumValueLabel.RowSpan=[2,2];
    maximumValueLabel.ColSpan=[1,1];

    maximumValue.Type='edit';
    maximumValue.Tag='maximumValue';
    maximumValue.Value=bounds.max;
    maximumValue.RowSpan=[2,2];
    maximumValue.ColSpan=[2,2];
    maximumValue.MatlabMethod='customwebblocks.utils.gaugeSettingsChanged';
    maximumValue.MatlabArgs={'%dialog',obj};


    tickValueLabel.Type='text';
    tickValueLabel.Name=DAStudio.message('SimulinkHMI:dialogs:TickIntervalPrompt');
    tickValueLabel.WordWrap=true;
    tickValueLabel.RowSpan=[3,3];
    tickValueLabel.ColSpan=[1,1];

    tickValue.Type='edit';
    tickValue.Tag='tickInterval';
    tickValue.Value=bounds.tickInterval;
    tickValue.RowSpan=[3,3];
    tickValue.ColSpan=[2,2];
    tickValue.MatlabMethod='customwebblocks.utils.gaugeSettingsChanged';
    tickValue.MatlabArgs={'%dialog',obj};

    scaleDirectionLabel.Type='text';
    scaleDirectionLabel.Tag='scaleDirectionLabel';
    scaleDirectionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:GaugeBlockScaleDirectionPrompt');
    scaleDirectionLabel.Buddy='scaleDirection';
    scaleDirectionLabel.RowSpan=[4,4];
    scaleDirectionLabel.ColSpan=[1,1];

    scaleDirection.Type='combobox';
    scaleDirection.Tag='scaleDirection';
    scaleDirection.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionClockwise'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionCounterclockwise')
    };
    scaleDirection.Value=get_param(blockHandle,'ScaleDirection');
    scaleDirection.MatlabMethod='customwebblocks.utils.scaleDirectionCallback';
    scaleDirection.MatlabArgs={'%dialog',obj};
    scaleDirection.RowSpan=[4,4];
    scaleDirection.ColSpan=[2,2];


    [labelDropdownLabel,labelDropdown]=locGetLabelPositionDropdown(obj,blockHandle,config);
    labelDropdownLabel.RowSpan=[5,5];
    labelDropdownLabel.ColSpan=[1,1];
    labelDropdown.RowSpan=[5,5];
    labelDropdown.ColSpan=[2,2];


    aspectRatioCheckbox=locGetAspectRatioCheckbox(obj,blockHandle,config);
    aspectRatioCheckbox.RowSpan=[6,6];
    aspectRatioCheckbox.ColSpan=[1,2];


    mainPanel.Name=DAStudio.message('Simulink:dialog:Main');
    mainPanel.Type='togglepanel';
    mainPanel.Expand=true;
    mainPanel.RowSpan=[2,2];
    mainPanel.ColSpan=[1,1];
    mainPanel.Source=blockHandle;
    mainPanel.LayoutGrid=[7,2];
    mainPanel.Items={...
    minimumValueLabel,minimumValue,...
    maximumValueLabel,maximumValue,...
    tickValueLabel,tickValue,...
    scaleDirectionLabel,scaleDirection,...
    labelDropdownLabel,labelDropdown,...
    aspectRatioCheckbox};
    mainPanel.RowStretch=[0,0,0,0,0,0,1];
    mainPanel.ColStretch=[0,1];


    dlg.Items={connectionPanel,mainPanel};
    dlg.LayoutGrid=[2,1];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=1;
end

function dlg=locGetPushButtonSlimDialogSchema(obj,blockHandle,config)
    dlg=obj.getBaseSlimDialogSchema();
    buttonSettings=customwebblocks.utils.getButtonSettingsForDialog(blockHandle,config);


    connectionPanel=locGetConnectionPanel(dlg.Items);
    connectionPanel.RowSpan=[1,1];
    connectionPanel.ColSpan=[1,1];


    [typeDropdownLabel,typeDropdown]=locGetButtonTypeDropdown(obj,blockHandle,config,buttonSettings);
    typeDropdownLabel.RowSpan=[1,1];
    typeDropdownLabel.ColSpan=[1,1];
    typeDropdown.RowSpan=[1,1];
    typeDropdown.ColSpan=[2,2];


    [textFieldLabel,textField,textFieldMultipleValues]=locGetButtonTextField(obj,blockHandle,config,buttonSettings);
    textFieldLabel.RowSpan=[2,2];
    textFieldLabel.ColSpan=[1,1];
    textField.RowSpan=[2,2];
    textField.ColSpan=[2,2];
    textFieldMultipleValues.RowSpan=[2,2];
    textFieldMultipleValues.ColSpan=[2,2];


    onValueLabel.Type='text';
    onValueLabel.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonOnValue');
    onValueLabel.WordWrap=true;
    onValueLabel.RowSpan=[3,3];
    onValueLabel.ColSpan=[1,1];

    onValueField.Type='edit';
    onValueField.Tag='onValue';
    onValueField.Value=buttonSettings.onValue;
    onValueField.RowSpan=[3,3];
    onValueField.ColSpan=[2,2];
    onValueField.MatlabMethod='customwebblocks.utils.buttonOnValueCallback';
    onValueField.MatlabArgs={'%dialog',obj};


    [labelDropdownLabel,labelDropdown]=locGetLabelPositionDropdown(obj,blockHandle,config);
    labelDropdownLabel.RowSpan=[4,4];
    labelDropdownLabel.ColSpan=[1,1];
    labelDropdown.RowSpan=[4,4];
    labelDropdown.ColSpan=[2,2];


    aspectRatioCheckbox=locGetAspectRatioCheckbox(obj,blockHandle,config);
    aspectRatioCheckbox.RowSpan=[5,5];
    aspectRatioCheckbox.ColSpan=[1,2];


    mainPanel.Name=DAStudio.message('Simulink:dialog:Main');
    mainPanel.Type='togglepanel';
    mainPanel.Expand=true;
    mainPanel.RowSpan=[2,2];
    mainPanel.ColSpan=[1,1];
    mainPanel.Source=blockHandle;
    mainPanel.LayoutGrid=[6,2];
    mainPanel.Items={...
    typeDropdownLabel,typeDropdown,...
    textFieldLabel,textField,textFieldMultipleValues,...
    onValueLabel,onValueField,...
    labelDropdownLabel,labelDropdown,...
    aspectRatioCheckbox};
    mainPanel.RowStretch=[0,0,0,0,0,1];
    mainPanel.ColStretch=[0,1];


    callbackPopup.Type='combobox';
    callbackPopup.Tag='callbackSwitch';
    callbackPopup.ObjectProperty='';
    callbackPopup.Graphical=1;
    callbackPopup.Value=obj.editingFcn;
    callbackPopup.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockClickFcn'),...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressFcn')
    };
    callbackPopup.RowSpan=[1,1];
    callbackPopup.ColSpan=[1,1];
    callbackPopup.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.callbackBlockFcnSelectionChangeCB';
    callbackPopup.MatlabArgs={'%dialog',obj,'%value'};


    callbackItems={callbackPopup};
    if~obj.editingFcn


        clickFcnEditor.Name='';
        clickFcnEditor.Type='matlabeditor';
        clickFcnEditor.PreferredSize=[150,200];
        clickFcnEditor.Tag='clickFcn';
        clickFcnEditor.Value=buttonSettings.clickFcn;
        clickFcnEditor.MatlabMethod='customwebblocks.utils.buttonClickFcnEditorCallback';
        clickFcnEditor.MatlabArgs={'%dialog',obj};
        clickFcnEditor.RowSpan=[2,2];
        clickFcnEditor.ColSpan=[1,1];

        callbackItems=[callbackItems,clickFcnEditor];

    else


        pressFcnEditor.Name='';
        pressFcnEditor.Type='matlabeditor';
        pressFcnEditor.PreferredSize=[150,200];
        pressFcnEditor.Tag='pressFcn';
        pressFcnEditor.Value=buttonSettings.pressFcn;
        pressFcnEditor.MatlabMethod='customwebblocks.utils.buttonPressFcnEditorCallback';
        pressFcnEditor.MatlabArgs={'%dialog',obj};
        pressFcnEditor.RowSpan=[2,2];
        pressFcnEditor.ColSpan=[1,1];


        pressDelay.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressDelay');
        pressDelay.Type='edit';
        pressDelay.Tag='pressDelay';
        pressDelay.Value=buttonSettings.pressDelay;
        pressDelay.MatlabMethod='customwebblocks.utils.buttonPressDelayCallback';
        pressDelay.MatlabArgs={'%dialog',obj};
        pressDelay.RowSpan=[3,3];
        pressDelay.ColSpan=[1,1];


        repeatInterval.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockRepeatInterval');
        repeatInterval.Type='edit';
        repeatInterval.Tag='repeatInterval';
        repeatInterval.Value=buttonSettings.repeatInterval;
        repeatInterval.MatlabMethod='customwebblocks.utils.buttonRepeatIntervalCallback';
        repeatInterval.MatlabArgs={'%dialog',obj};
        repeatInterval.RowSpan=[4,4];
        repeatInterval.ColSpan=[1,1];

        callbackItems=[callbackItems,pressFcnEditor,pressDelay,repeatInterval];
    end


    callbackPanel.Name=DAStudio.message('Simulink:dialog:callbacksLabel');
    callbackPanel.Type='togglepanel';
    callbackPanel.Expand=true;
    callbackPanel.RowSpan=[3,3];
    callbackPanel.ColSpan=[1,1];
    callbackPanel.Source=blockHandle;
    callbackPanel.LayoutGrid=[numel(callbackItems),1];
    callbackPanel.Items=callbackItems;
    callbackPanel.RowStretch=cellfun(@(item)double(strcmp(item.Type,'matlabeditor')),callbackItems);


    dlg.Items={connectionPanel,mainPanel,callbackPanel};
    dlg.LayoutGrid=[3,1];
    dlg.RowStretch=[0,0,1];
    dlg.ColStretch=1;
end

function dlg=locGetCallbackButtonSlimDialogSchema(obj,blockHandle,config)
    dlg=obj.getBaseSlimDialogSchema();
    buttonSettings=customwebblocks.utils.getButtonSettingsForDialog(blockHandle,config);


    [typeDropdownLabel,typeDropdown]=locGetButtonTypeDropdown(obj,blockHandle,config,buttonSettings);
    typeDropdownLabel.RowSpan=[1,1];
    typeDropdownLabel.ColSpan=[1,1];
    typeDropdown.RowSpan=[1,1];
    typeDropdown.ColSpan=[2,2];


    [textFieldLabel,textField,textFieldMultipleValues]=locGetButtonTextField(obj,blockHandle,config,buttonSettings);
    textFieldLabel.RowSpan=[2,2];
    textFieldLabel.ColSpan=[1,1];
    textField.RowSpan=[2,2];
    textField.ColSpan=[2,2];
    textFieldMultipleValues.RowSpan=[2,2];
    textFieldMultipleValues.ColSpan=[2,2];


    aspectRatioCheckbox=locGetAspectRatioCheckbox(obj,blockHandle,config);
    aspectRatioCheckbox.RowSpan=[3,3];
    aspectRatioCheckbox.ColSpan=[1,2];


    mainPanel.Name=DAStudio.message('Simulink:dialog:Main');
    mainPanel.Type='togglepanel';
    mainPanel.Expand=true;
    mainPanel.RowSpan=[1,1];
    mainPanel.ColSpan=[1,1];
    mainPanel.Source=blockHandle;
    mainPanel.LayoutGrid=[5,2];
    mainPanel.Items={...
    typeDropdownLabel,typeDropdown,...
    textFieldLabel,textField,textFieldMultipleValues,...
    aspectRatioCheckbox};
    mainPanel.RowStretch=[0,0,0,0,1];
    mainPanel.ColStretch=[0,1];


    callbackPopup.Type='combobox';
    callbackPopup.Tag='callbackSwitch';
    callbackPopup.ObjectProperty='';
    callbackPopup.Graphical=1;
    callbackPopup.Value=obj.editingFcn;
    callbackPopup.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockClickFcn'),...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressFcn')
    };
    callbackPopup.RowSpan=[1,1];
    callbackPopup.ColSpan=[1,1];
    callbackPopup.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.callbackBlockFcnSelectionChangeCB';
    callbackPopup.MatlabArgs={'%dialog',obj,'%value'};


    callbackItems={callbackPopup};
    if~obj.editingFcn


        clickFcnEditor.Name='';
        clickFcnEditor.Type='matlabeditor';
        clickFcnEditor.PreferredSize=[150,200];
        clickFcnEditor.Tag='clickFcn';
        clickFcnEditor.Value=buttonSettings.clickFcn;
        clickFcnEditor.MatlabMethod='customwebblocks.utils.buttonClickFcnEditorCallback';
        clickFcnEditor.MatlabArgs={'%dialog',obj};
        clickFcnEditor.RowSpan=[2,2];
        clickFcnEditor.ColSpan=[1,1];

        callbackItems=[callbackItems,clickFcnEditor];

    else


        pressFcnEditor.Name='';
        pressFcnEditor.Type='matlabeditor';
        pressFcnEditor.PreferredSize=[150,200];
        pressFcnEditor.Tag='pressFcn';
        pressFcnEditor.Value=buttonSettings.pressFcn;
        pressFcnEditor.MatlabMethod='customwebblocks.utils.buttonPressFcnEditorCallback';
        pressFcnEditor.MatlabArgs={'%dialog',obj};
        pressFcnEditor.RowSpan=[2,2];
        pressFcnEditor.ColSpan=[1,1];


        pressDelay.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressDelay');
        pressDelay.Type='edit';
        pressDelay.Tag='pressDelay';
        pressDelay.Value=buttonSettings.pressDelay;
        pressDelay.MatlabMethod='customwebblocks.utils.buttonPressDelayCallback';
        pressDelay.MatlabArgs={'%dialog',obj};
        pressDelay.RowSpan=[3,3];
        pressDelay.ColSpan=[1,1];


        repeatInterval.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockRepeatInterval');
        repeatInterval.Type='edit';
        repeatInterval.Tag='repeatInterval';
        repeatInterval.Value=buttonSettings.repeatInterval;
        repeatInterval.MatlabMethod='customwebblocks.utils.buttonRepeatIntervalCallback';
        repeatInterval.MatlabArgs={'%dialog',obj};
        repeatInterval.RowSpan=[4,4];
        repeatInterval.ColSpan=[1,1];

        callbackItems=[callbackItems,pressFcnEditor,pressDelay,repeatInterval];
    end


    callbackPanel.Name=DAStudio.message('Simulink:dialog:callbacksLabel');
    callbackPanel.Type='togglepanel';
    callbackPanel.Expand=true;
    callbackPanel.RowSpan=[2,2];
    callbackPanel.ColSpan=[1,1];
    callbackPanel.Source=blockHandle;
    callbackPanel.LayoutGrid=[numel(callbackItems),1];
    callbackPanel.Items=callbackItems;
    callbackPanel.RowStretch=cellfun(@(item)double(strcmp(item.Type,'matlabeditor')),callbackItems);


    dlg.Items={mainPanel,callbackPanel};
    dlg.LayoutGrid=[2,1];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=1;
end

function[typeDropdownLabel,typeDropdown]=locGetButtonTypeDropdown(obj,~,~,buttonSettings)


    typeDropdownLabel.Type='text';
    typeDropdownLabel.Name=DAStudio.message('CustomWebBlocks:messages:ButtonTypePrompt');
    typeDropdownLabel.WordWrap=true;


    typeIndex=0;
    if strcmpi(buttonSettings.buttonType,'latch')
        typeIndex=1;
    end
    typeDropdown.Type='combobox';
    typeDropdown.Tag='buttonType';
    typeDropdown.Entries={...
    DAStudio.message('CustomWebBlocks:messages:ButtonTypeMomentary'),...
    DAStudio.message('CustomWebBlocks:messages:ButtonTypeLatch')...
    };
    typeDropdown.Value=typeIndex;
    typeDropdown.MatlabMethod='customwebblocks.utils.buttonTypeCallback';
    typeDropdown.MatlabArgs={'%dialog',obj};
end

function[textFieldLabel,textField,textFieldMultipleValues]=locGetButtonTextField(obj,~,~,buttonSettings)


    textFieldLabel.Type='text';
    textFieldLabel.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockButtonText');
    textFieldLabel.WordWrap=true;


    textField.Visible=~buttonSettings.buttonTextHasMultipleValues;
    textField.Type='edit';
    textField.Tag='buttonText';
    textField.Value=buttonSettings.buttonText;
    textField.MatlabMethod='customwebblocks.utils.buttonTextMultipleValuesCallback';
    textField.MatlabArgs={'%dialog',obj};






    textFieldMultipleValues.Visible=buttonSettings.buttonTextHasMultipleValues;
    textFieldMultipleValues.Type='edit';
    textFieldMultipleValues.Tag='buttonTextMultipleValues';
    textFieldMultipleValues.PlaceholderText=DAStudio.message('CustomWebBlocks:messages:ButtonTextMultipleValues');
    textFieldMultipleValues.Value='';
    textFieldMultipleValues.MatlabMethod='customwebblocks.utils.buttonTextMultipleValuesCallback';
    textFieldMultipleValues.MatlabArgs={'%dialog',obj};
end

function connectionPanel=locGetConnectionPanel(baseItems)
    connectionPanel.Type='togglepanel';
    connectionPanel.Name=DAStudio.message('CustomWebBlocks:messages:ConnectionPanel');
    connectionPanel.Items=baseItems;
    connectionPanel.Expand=true;
    connectionPanel.LayoutGrid=[1,5];
    connectionPanel.RowStretch=1;
    connectionPanel.ColStretch=[0,0,0,0,1];
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

function dlg=locGetCustomizeSlimDialogSchema(obj,blockHandle,config)
    model=get_param(bdroot(blockHandle),'Name');
    debugMode=DAStudio.CustomWebBlocks.getDebugMode(blockHandle);
    isPanelBlock=isBlockInWebPanel(blockHandle);
    isWEMActive=false;
    isLocked=customwebblocks.utils.isBlockInLockedSystem(obj.blockObj);

    obj.metadata=get_param(blockHandle,'dlgMetadata');

    variant='none';

    if isfield(config,'settings')&&...
        isfield(config.settings,'variant')
        variant=config.settings.variant;
    end


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
    '&isWEMActive=',num2str(isWEMActive),'&instanceName=',config.type,...
    '&variant=',variant,...
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

function dlg=locGetSwitchSlimDialogSchema(obj,blockHandle,config)
    dlg=obj.getBaseSlimDialogSchema();
    switchSettings=customwebblocks.utils.getSwitchSettingsFromDialog(config);

    showEnumSettings=false;
    if strcmp(config.type,'RotarySwitch')
        showEnumSettings=true;
    end

    keys=obj.propMap.keys;
    remove(obj.propMap,keys);

    for idx=1:length(switchSettings.states)
        newProp.index=idx;
        newProp.states=switchSettings.states(idx).Value;
        newProp.stateLabels=switchSettings.states(idx).Label.text.content;
        obj.propMap(idx)=newProp;
    end


    connectionPanel=locGetConnectionPanel(dlg.Items);
    connectionPanel.RowSpan=[1,1];
    connectionPanel.ColSpan=[1,1];


    [labelDropdownLabel,labelDropdown]=locGetLabelPositionDropdown(obj,blockHandle,config);
    labelDropdownLabel.RowSpan=[1,1];
    labelDropdownLabel.ColSpan=[1,1];
    labelDropdown.RowSpan=[1,1];
    labelDropdown.ColSpan=[2,2];


    aspectRatioCheckbox=locGetAspectRatioCheckbox(obj,blockHandle,config);
    aspectRatioCheckbox.RowSpan=[2,2];
    aspectRatioCheckbox.ColSpan=[1,2];

    if showEnumSettings

        enableEnumType.Type='checkbox';
        enableEnumType.Tag='UseEnumDataType';
        enableEnumType.Name=DAStudio.message('SimulinkHMI:dialogs:RadioButtonGroupUsEnumDataType');
        enableEnumType.Source=obj;
        enableEnumType.Value=switchSettings.useEnumeratedType;
        enableEnumType.MatlabMethod='customwebblocks.utils.switchEnumCallback';
        enableEnumType.MatlabArgs={'%dialog','%source'};
        enableEnumType.RowSpan=[3,3];
        enableEnumType.ColSpan=[1,1];

        enumDataType.Type='edit';
        enumDataType.Tag='EnumDataType';
        enumDataType.Source=obj;
        enumDataType.Value=switchSettings.enumeratedType;
        enumDataType.Enabled=enableEnumType.Value;
        enumDataType.MatlabMethod='customwebblocks.utils.switchEnumCallback';
        enumDataType.MatlabArgs={'%dialog','%source'};
        enumDataType.RowSpan=[3,3];
        enumDataType.ColSpan=[2,2];
    end



    hBlk=get(obj.getBlock(),'handle');
    model=get_param(bdroot(hBlk),'Name');

    obj.tableState=~((Simulink.HMI.isLibrary(model))||...
    (utils.isLockedLibrary(model))||switchSettings.useEnumeratedType);

    fp='toolbox/simulink/hmi/web/Dialogs/ParameterDialog';
    url=[fp,'/DiscreteKnobPropertiesWidget.html?widgetID=',obj.widgetId...
    ,'&model=',model,'&isLibWidget=',num2str(obj.isLibWidget),...
    '&isSlimDialog=',num2str(true),'&isCustomWebBlock=',num2str(true)];
    propbrowser.Type='webbrowser';
    propbrowser.Tag='sl_hmi_DiscretKnobProperties';
    propbrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    propbrowser.DisableContextMenu=true;
    propbrowser.MatlabMethod='slDialogUtil';
    propbrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};
    propbrowser.RowSpan=[4,4];
    propbrowser.ColSpan=[1,2];
    propbrowser.Enabled=obj.tableState;


    mainPanel.Name=DAStudio.message('Simulink:dialog:Main');
    mainPanel.Type='togglepanel';
    mainPanel.Expand=true;
    mainPanel.RowSpan=[2,2];
    mainPanel.ColSpan=[1,1];
    mainPanel.Source=blockHandle;

    if showEnumSettings
        mainPanel.LayoutGrid=[4,2];
        mainPanel.Items={...
        enableEnumType,enumDataType,labelDropdownLabel,labelDropdown,...
        aspectRatioCheckbox,propbrowser};
        mainPanel.RowStretch=[0,0,0,1];
        mainPanel.ColStretch=[0,1];
    else
        mainPanel.LayoutGrid=[3,2];
        mainPanel.Items={...
        labelDropdownLabel,labelDropdown,...
        aspectRatioCheckbox,propbrowser};
        mainPanel.RowStretch=[0,0,0];
        mainPanel.ColStretch=[0,1];
    end


    dlg.Items={connectionPanel,mainPanel};
    dlg.LayoutGrid=[2,1];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=1;
end
