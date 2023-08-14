


function dlg=getDialogSchema(obj,~)
    dlg=obj.getBaseDialogSchema();


    dlg.IsScrollable=true;


    blockHandle=obj.get_param('handle');
    config=jsondecode(get_param(blockHandle,'Configuration'));
    if isfield(config,'type')
        if strcmp(config.type,'CircularGauge')||strcmp(config.type,'LinearGauge')
            dlg=locGetSliderDialogSchema(obj,blockHandle,config);
        elseif strcmp(config.type,'Button')
            if isfield(config,'settings')&&...
                isfield(config.settings,'variant')&&...
                strcmp(config.settings.variant,'callback')
                dlg=locGetCallbackButtonDialogSchema(obj,blockHandle,config);
            else
                dlg=locGetPushButtonDialogSchema(obj,blockHandle,config);
            end
        elseif strcmp(config.type,'Switch')||strcmp(config.type,'RotarySwitch')
            dlg=locGetSwitchDialogSchema(obj,blockHandle,config);
        end
    end
end

function dlg=locGetSliderDialogSchema(obj,blockHandle,config)
    dlg=obj.getBaseDialogSchema();


    orientation=[];
    if strcmp(config.type,'LinearGauge')
        orientation=config.settings.orientation;
    end
    if strcmp(orientation,'horizontal')
        name=DAStudio.message('CustomWebBlocks:messages:HorizontalSlider');
    elseif strcmp(orientation,'vertical')
        name=DAStudio.message('CustomWebBlocks:messages:VerticalSlider');
    else
        name=DAStudio.message('CustomWebBlocks:messages:CircularSlider');
    end
    descGroup=locGetDescGroup(...
    blockHandle,...
    name,...
    DAStudio.message('CustomWebBlocks:messages:CustomSliderDialogDesc'));
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    propGroup.Type='group';
    propGroup.Items={};
    propGroup.RowSpan=[2,2];
    propGroup.ColSpan=[1,3];
    propGroup.LayoutGrid=[6,3];
    propGroup.RowStretch=[1,0,0,0,0,0];


    bindingTable=dlg.Items{1};
    bindingTable.PreferredSize=[100,160];
    bindingTable.MinimumSize=[100,160];
    bindingTable.RowSpan=[1,1];
    bindingTable.ColSpan=[1,3];
    propGroup.Items{end+1}=bindingTable;

    sc=[];
    bounds=[];
    if isfield(config,'components')&&~isempty(config.components)
        components=config.components;
        for index=1:length(components)
            if strcmp(components(index).name,'LinearScaleComponent')||...
                strcmp(components(index).name,'CircularScaleComponent')
                bounds=components(index).settings.bounds;
                sc=components(index).settings.scaleDirection;
                if strcmp(sc,'CW')||strcmp(sc,'LR')||strcmp(sc,'BT')
                    sc=0;
                else
                    sc=1;
                end
            end
        end
    end



    minimumValue.Type='edit';
    minimumValue.Tag='minimumValue';
    minimumValue.Name=DAStudio.message('SimulinkHMI:dialogs:MinimumPrompt');
    minimumValue.Value=bounds.min;
    minimumValue.RowSpan=[2,2];
    minimumValue.ColSpan=[1,3];
    propGroup.Items{end+1}=minimumValue;


    maximumValue.Type='edit';
    maximumValue.Tag='maximumValue';
    maximumValue.Name=DAStudio.message('SimulinkHMI:dialogs:MaximumPrompt');
    maximumValue.Value=bounds.max;
    maximumValue.RowSpan=[3,3];
    maximumValue.ColSpan=[1,3];
    propGroup.Items{end+1}=maximumValue;


    tickInterval.Type='edit';
    tickInterval.Tag='tickInterval';
    tickInterval.Name=DAStudio.message('SimulinkHMI:dialogs:TickIntervalPrompt');
    tickInterval.Value=bounds.tickInterval;
    tickInterval.RowSpan=[4,4];
    tickInterval.ColSpan=[1,3];
    propGroup.Items{end+1}=tickInterval;

    scaleDirection.Type='combobox';
    scaleDirection.Tag='scaleDirection';
    scaleDirection.Name=...
    DAStudio.message('SimulinkHMI:dialogs:GaugeBlockScaleDirectionPrompt');
    scaleDirection.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionClockwise'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionCounterclockwise')
    };
    scaleDirection.Value=sc;
    scaleDirection.RowSpan=[5,5];
    scaleDirection.ColSpan=[1,3];
    propGroup.Items{end+1}=scaleDirection;


    lockAspectRatio=locGetAspectRatioCheckbox(config);
    lockAspectRatio.RowSpan=[6,6];
    lockAspectRatio.ColSpan=[1,2];
    propGroup.Items{end+1}=lockAspectRatio;


    labelPositionDropdown=locGetLabelPositionDropdown(blockHandle);
    labelPositionDropdown.RowSpan=[7,7];
    labelPositionDropdown.ColSpan=[1,3];
    propGroup.Items{end+1}=labelPositionDropdown;


    dlg.Items={descGroup,propGroup};
    dlg.DialogTag=obj.getBlock.BlockType;

    dlg.LayoutGrid=[2,3];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=[0,0,0];

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};

    dlg.HelpMethod='helpview';


    if strcmp(orientation,'horizontal')
        helpTag='horizontal_slider';
    elseif strcmp(orientation,'vertical')
        helpTag='vertical_slider';
    else
        helpTag='custom_knob';
    end

    dlg.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),helpTag};
end

function dlg=locGetPushButtonDialogSchema(obj,blockHandle,config)
    dlg=obj.getBaseDialogSchema();
    buttonSettings=customwebblocks.utils.getButtonSettingsForDialog(blockHandle,config);


    descGroup=locGetDescGroup(...
    blockHandle,...
    DAStudio.message('SimulinkHMI:dialogs:PushButton'),...
    DAStudio.message('SimulinkHMI:dialogs:PushButtonDialogDesc'));
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,1];


    mainGroup.Type='group';
    mainGroup.Items={};
    mainGroup.RowSpan=[2,2];
    mainGroup.ColSpan=[1,1];
    mainGroup.LayoutGrid=[6,1];
    mainGroup.RowStretch=[1,0,0,0,0,0];


    bindingTable=dlg.Items{1};
    bindingTable.PreferredSize=[100,160];
    bindingTable.MinimumSize=[100,160];
    bindingTable.RowSpan=[1,1];
    bindingTable.ColSpan=[1,1];
    mainGroup.Items{end+1}=bindingTable;


    typeDropdown=locGetButtonTypeDropdown(buttonSettings);
    typeDropdown.RowSpan=[2,2];
    typeDropdown.ColSpan=[1,1];
    mainGroup.Items{end+1}=typeDropdown;


    [textField,textFieldMultipleValues]=locGetButtonTextField(buttonSettings);
    textField.RowSpan=[3,3];
    textField.ColSpan=[1,1];
    textFieldMultipleValues.RowSpan=[3,3];
    textFieldMultipleValues.ColSpan=[1,1];
    mainGroup.Items{end+1}=textField;
    mainGroup.Items{end+1}=textFieldMultipleValues;


    onValueField.Type='edit';
    onValueField.Tag='onValue';
    onValueField.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonOnValue');
    onValueField.Value=buttonSettings.onValue;
    onValueField.RowSpan=[4,4];
    onValueField.ColSpan=[1,1];
    mainGroup.Items{end+1}=onValueField;


    labelPositionDropdown=locGetLabelPositionDropdown(blockHandle);
    labelPositionDropdown.RowSpan=[5,5];
    labelPositionDropdown.ColSpan=[1,1];
    mainGroup.Items{end+1}=labelPositionDropdown;


    lockAspectRatio=locGetAspectRatioCheckbox(config);
    lockAspectRatio.RowSpan=[6,6];
    lockAspectRatio.ColSpan=[1,1];
    mainGroup.Items{end+1}=lockAspectRatio;


    callbacksGroup.Type='group';
    callbacksGroup.Name='Callbacks';
    callbacksGroup.Items={};
    callbacksGroup.RowSpan=[2,2];
    callbacksGroup.ColSpan=[1,1];
    callbacksGroup.LayoutGrid=[4,1];
    callbacksGroup.RowStretch=[0,1,0,0];


    callbackDropdown.Name='';
    callbackDropdown.Type='combobox';
    callbackDropdown.Tag='callbackSwitch';
    callbackDropdown.Value=obj.editingFcn;
    callbackDropdown.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockClickFcn'),...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressFcn')
    };
    callbackDropdown.RowSpan=[1,1];
    callbackDropdown.ColSpan=[1,1];
    callbackDropdown.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.callbackBlockFcnSelectionChangeCB';
    callbackDropdown.MatlabArgs={'%dialog',obj,'%value'};
    callbacksGroup.Items{end+1}=callbackDropdown;


    clickFcnEditor.Name='';
    clickFcnEditor.Type='matlabeditor';
    clickFcnEditor.PreferredSize=[150,200];
    clickFcnEditor.Tag='clickFcn';
    clickFcnEditor.Value=buttonSettings.clickFcn;
    clickFcnEditor.Visible=~obj.editingFcn;
    clickFcnEditor.RowSpan=[2,2];
    clickFcnEditor.ColSpan=[1,1];
    callbacksGroup.Items{end+1}=clickFcnEditor;


    pressFcnEditor.Name='';
    pressFcnEditor.Type='matlabeditor';
    pressFcnEditor.PreferredSize=[150,200];
    pressFcnEditor.Tag='pressFcn';
    pressFcnEditor.Value=buttonSettings.pressFcn;
    pressFcnEditor.Visible=obj.editingFcn;
    pressFcnEditor.RowSpan=[2,2];
    pressFcnEditor.ColSpan=[1,1];
    callbacksGroup.Items{end+1}=pressFcnEditor;


    pressDelay.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressDelay');
    pressDelay.Type='edit';
    pressDelay.Tag='pressDelay';
    pressDelay.Value=buttonSettings.pressDelay;
    pressDelay.Visible=obj.editingFcn;
    pressDelay.RowSpan=[3,3];
    pressDelay.ColSpan=[1,1];
    callbacksGroup.Items{end+1}=pressDelay;


    repeatInterval.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockRepeatInterval');
    repeatInterval.Type='edit';
    repeatInterval.Tag='repeatInterval';
    repeatInterval.Visible=obj.editingFcn;
    repeatInterval.Value=buttonSettings.repeatInterval;
    repeatInterval.RowSpan=[4,4];
    repeatInterval.ColSpan=[1,1];
    callbacksGroup.Items{end+1}=repeatInterval;


    mainTab.Name=DAStudio.message('Simulink:dialog:Main');
    mainTab.Items={mainGroup};
    callbacksTab.Name=DAStudio.message('Simulink:dialog:callbacksLabel');
    callbacksTab.Items={callbacksGroup};
    tabContainer.Type='tab';
    tabContainer.Name='tabContainer';
    tabContainer.Tabs={mainTab,callbacksTab};


    dlg.Items={descGroup,tabContainer};
    dlg.DialogTag=obj.getBlock.BlockType;
    dlg.LayoutGrid=[2,1];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=1;
    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};
    dlg.HelpMethod='helpview';
    dlg.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'custom_push_button'};
end

function dlg=locGetCallbackButtonDialogSchema(obj,blockHandle,config)
    dlg=obj.getBaseDialogSchema();
    buttonSettings=customwebblocks.utils.getButtonSettingsForDialog(blockHandle,config);


    descGroup=locGetDescGroup(...
    blockHandle,...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlock'),...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockDesc'));
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,1];


    propGroup.Type='group';
    propGroup.Items={};
    propGroup.RowSpan=[2,2];
    propGroup.ColSpan=[1,1];
    propGroup.LayoutGrid=[6,1];
    propGroup.RowStretch=[0,0,0,1,0,0];


    typeDropdown=locGetButtonTypeDropdown(buttonSettings);
    typeDropdown.RowSpan=[1,1];
    typeDropdown.ColSpan=[1,1];
    propGroup.Items{end+1}=typeDropdown;


    [textField,textFieldMultipleValues]=locGetButtonTextField(buttonSettings);
    textField.RowSpan=[2,2];
    textField.ColSpan=[1,1];
    textFieldMultipleValues.RowSpan=[2,2];
    textFieldMultipleValues.ColSpan=[1,1];
    propGroup.Items{end+1}=textField;
    propGroup.Items{end+1}=textFieldMultipleValues;


    lockAspectRatio=locGetAspectRatioCheckbox(config);
    lockAspectRatio.RowSpan=[3,3];
    lockAspectRatio.ColSpan=[1,1];
    propGroup.Items{end+1}=lockAspectRatio;


    callbackDropdown.Name='';
    callbackDropdown.Type='combobox';
    callbackDropdown.Tag='callbackSwitch';
    callbackDropdown.Value=obj.editingFcn;
    callbackDropdown.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockClickFcn'),...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressFcn')
    };
    callbackDropdown.RowSpan=[4,4];
    callbackDropdown.ColSpan=[1,1];
    callbackDropdown.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.callbackBlockFcnSelectionChangeCB';
    callbackDropdown.MatlabArgs={'%dialog',obj,'%value'};
    propGroup.Items{end+1}=callbackDropdown;


    clickFcnEditor.Name='';
    clickFcnEditor.Type='matlabeditor';
    clickFcnEditor.PreferredSize=[150,200];
    clickFcnEditor.Tag='clickFcn';
    clickFcnEditor.Value=buttonSettings.clickFcn;
    clickFcnEditor.Visible=~obj.editingFcn;
    clickFcnEditor.RowSpan=[5,5];
    clickFcnEditor.ColSpan=[1,1];
    propGroup.Items{end+1}=clickFcnEditor;


    pressFcnEditor.Name='';
    pressFcnEditor.Type='matlabeditor';
    pressFcnEditor.PreferredSize=[150,200];
    pressFcnEditor.Tag='pressFcn';
    pressFcnEditor.Value=buttonSettings.pressFcn;
    pressFcnEditor.Visible=obj.editingFcn;
    pressFcnEditor.RowSpan=[5,5];
    pressFcnEditor.ColSpan=[1,1];
    propGroup.Items{end+1}=pressFcnEditor;


    pressDelay.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressDelay');
    pressDelay.Type='edit';
    pressDelay.Tag='pressDelay';
    pressDelay.Value=buttonSettings.pressDelay;
    pressDelay.Visible=obj.editingFcn;
    pressDelay.RowSpan=[6,6];
    pressDelay.ColSpan=[1,1];
    propGroup.Items{end+1}=pressDelay;


    repeatInterval.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockRepeatInterval');
    repeatInterval.Type='edit';
    repeatInterval.Tag='repeatInterval';
    repeatInterval.Visible=obj.editingFcn;
    repeatInterval.Value=buttonSettings.repeatInterval;
    repeatInterval.RowSpan=[7,7];
    repeatInterval.ColSpan=[1,1];
    propGroup.Items{end+1}=repeatInterval;


    dlg.Items={descGroup,propGroup};
    dlg.DialogTag=obj.getBlock.BlockType;
    dlg.LayoutGrid=[2,1];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=0;
    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};
    dlg.HelpMethod='helpview';
    dlg.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'custom_callback_button'};
end

function typeDropdown=locGetButtonTypeDropdown(buttonSettings)
    typeIndex=0;
    if strcmpi(buttonSettings.buttonType,'latch')
        typeIndex=1;
    end
    typeDropdown.Type='combobox';
    typeDropdown.Tag='buttonType';
    typeDropdown.Name=...
    DAStudio.message('CustomWebBlocks:messages:ButtonTypePrompt');
    typeDropdown.Entries={...
    DAStudio.message('CustomWebBlocks:messages:ButtonTypeMomentary'),...
    DAStudio.message('CustomWebBlocks:messages:ButtonTypeLatch')...
    };
    typeDropdown.Value=typeIndex;
end

function[textField,textFieldMultipleValues]=locGetButtonTextField(buttonSettings)


    textField.Visible=~buttonSettings.buttonTextHasMultipleValues;
    textField.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonText');
    textField.Type='edit';
    textField.Tag='buttonText';
    textField.Value=buttonSettings.buttonText;






    textFieldMultipleValues.Visible=buttonSettings.buttonTextHasMultipleValues;
    textFieldMultipleValues.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonText');
    textFieldMultipleValues.Type='edit';
    textFieldMultipleValues.Tag='buttonTextMultipleValues';
    textFieldMultipleValues.PlaceholderText=DAStudio.message('CustomWebBlocks:messages:ButtonTextMultipleValues');
    textFieldMultipleValues.Value='';
end

function dlg=locGetSwitchDialogSchema(obj,blockHandle,config)
    dlg=obj.getBaseDialogSchema();
    switchSettings=customwebblocks.utils.getSwitchSettingsFromDialog(config);

    showEnumSettings=false;
    if strcmp(config.type,'RotarySwitch')
        anchor='custom_rotary_switch';
        showEnumSettings=true;
        blockName=DAStudio.message('SimulinkHMI:dialogs:DiscreteKnob');
        blockDescription=DAStudio.message('SimulinkHMI:dialogs:DiscreteKnobDialogDesc');
    else
        if isfield(config.settings,'variant')
            if strcmp(config.settings.variant,'slider')
                anchor='custom_slider_switch';
            elseif strcmp(config.settings.variant,'rocker')
                anchor='custom_rocker_switch';
            else
                anchor='custom_toggle_switch';
            end
        else
            anchor='custom_switch';
        end
        blockName=DAStudio.message('SimulinkHMI:dialogs:Switch');
        blockDescription=DAStudio.message('SimulinkHMI:dialogs:SwitchDialogDesc');
    end

    hBlk=get(obj.getBlock(),'handle');
    model=get_param(bdroot(hBlk),'Name');

    labelPosition=get_param(blockHandle,'LabelPosition');
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);

    keys=obj.propMap.keys;
    remove(obj.propMap,keys);

    for idx=1:length(switchSettings.states)
        newProp.index=idx;
        newProp.states=switchSettings.states(idx).Value;
        newProp.stateLabels=switchSettings.states(idx).Label.text.content;
        obj.propMap(idx)=newProp;
    end

    obj.tableState=~((Simulink.HMI.isLibrary(model))||...
    (utils.isLockedLibrary(model))||switchSettings.useEnumeratedType);


    descGroup=locGetDescGroup(...
    blockHandle,...
    blockName,...
    blockDescription);
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    bindingTable=dlg.Items{1};
    bindingTable.PreferredSize=[100,160];
    bindingTable.MinimumSize=[100,160];
    bindingTable.RowSpan=[1,1];
    bindingTable.ColSpan=[1,3];

    fp='toolbox/simulink/hmi/web/Dialogs/ParameterDialog';
    url=[fp,'/DiscreteKnobPropertiesWidget.html?widgetID=',obj.widgetId...
    ,'&model=',model,'&isLibWidget=',num2str(false),'&isCustomWebBlock=',num2str(true)];

    propbrowser.Type='webbrowser';
    propbrowser.Tag='sl_hmi_DiscretKnobProperties';
    propbrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    propbrowser.DisableContextMenu=true;
    propbrowser.MatlabMethod='slDialogUtil';
    propbrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};
    propbrowser.PreferredSize=[100,160];
    propbrowser.MinimumSize=[100,160];
    propbrowser.RowSpan=[2,2];
    propbrowser.ColSpan=[1,3];
    propbrowser.Enabled=obj.tableState;

    if showEnumSettings

        enableEnumType.Type='checkbox';
        enableEnumType.Tag='EnableEnumDataType';
        enableEnumType.Name=DAStudio.message('SimulinkHMI:dialogs:RadioButtonGroupUsEnumDataType');
        enableEnumType.Value=switchSettings.useEnumeratedType;
        enableEnumType.MatlabMethod='utils.enableEnumTypeChanged';
        enableEnumType.MatlabArgs={'%dialog','%source',false};
        enableEnumType.RowSpan=[3,3];
        enableEnumType.ColSpan=[1,1];

        enumDataType.Type='edit';
        enumDataType.Tag='EnumDataTypeName';
        enumDataType.Value=switchSettings.enumeratedType;
        enumDataType.Enabled=switchSettings.useEnumeratedType;
        enumDataType.RowSpan=[3,3];
        enumDataType.ColSpan=[2,3];
    end


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
    legendPosition.RowSpan=[4,4];
    legendPosition.ColSpan=[1,3];


    lockAspectRatio=locGetAspectRatioCheckbox(config);
    lockAspectRatio.RowSpan=[5,5];
    lockAspectRatio.ColSpan=[1,2];


    propGroup.Type='group';
    if showEnumSettings
        propGroup.Items={bindingTable,propbrowser,enableEnumType,enumDataType,legendPosition,lockAspectRatio};
        propGroup.RowSpan=[2,3];
        propGroup.ColSpan=[1,3];
        propGroup.LayoutGrid=[5,3];
        propGroup.RowStretch=[1,0,0,0,0];
        propGroup.ColStretch=[0,0,1];
    else
        propGroup.Items={bindingTable,propbrowser,legendPosition,lockAspectRatio};
        propGroup.RowSpan=[2,3];
        propGroup.ColSpan=[1,3];
        propGroup.LayoutGrid=[4,3];
        propGroup.RowStretch=[1,0,0,0];
        propGroup.ColStretch=[0,0,1];
    end

    dlg.Items={descGroup,propGroup};
    dlg.DialogTag=obj.getBlock.BlockType;
    dlg.LayoutGrid=[2,1];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=0;
    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};
    dlg.HelpMethod='helpview';
    dlg.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),anchor};
end

function descGroup=locGetDescGroup(blockHandle,blockName,blockDesc)
    text.Type='text';
    text.WordWrap=true;
    text.Name=blockDesc;
    text.RowSpan=[1,1];
    text.ColSpan=[1,3];

    editText.Type='text';
    editText.WordWrap=true;
    editText.Name=DAStudio.message('CustomWebBlocks:messages:EditDescription');
    editText.RowSpan=[2,2];
    editText.ColSpan=[1,3];

    modelHandle=get_param(bdroot(blockHandle),'handle');
    editButton.Type='pushbutton';
    editButton.Tag='editButton';
    editButton.Name=DAStudio.message('CustomWebBlocks:messages:EditVisualDesign');
    editButton.MatlabMethod='customwebblocks.utils.openDesignTab';
    editButton.MatlabArgs={modelHandle,blockHandle,true};
    editButton.RowSpan=[3,3];
    editButton.ColSpan=[2,2];

    descGroup.Type='group';
    descGroup.Name=blockName;
    descGroup.LayoutGrid=[3,3];
    descGroup.Items={text,editText,editButton};
end

function dropdown=locGetLabelPositionDropdown(blockHandle)
    model=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(model)
        labelPosition=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end
    dropdown.Type='combobox';
    dropdown.Tag='labelPosition';
    dropdown.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    dropdown.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    dropdown.Value=labelPosition;
end

function checkbox=locGetAspectRatioCheckbox(config)
    fixedAspectRatio='on';
    if isfield(config,'settings')&&...
        isfield(config.settings,'fixedAspectRatio')
        fixedAspectRatio=config.settings.fixedAspectRatio;
    end
    checkbox.Type='checkbox';
    checkbox.Tag='lockAspectRatio';
    checkbox.Name=DAStudio.message('CustomWebBlocks:messages:LockAspectRatio');
    checkbox.Value=strcmp(fixedAspectRatio,'on');
end
