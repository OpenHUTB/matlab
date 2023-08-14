


function dlg=getDialogSchema(obj,~)
    dlg=obj.getBaseDialogSchema();


    dlg.IsScrollable=true;


    blockHandle=obj.get_param('handle');
    config=jsondecode(get_param(blockHandle,'Configuration'));
    if isfield(config,'type')
        if strcmp(config.type,'CircularGauge')||strcmp(config.type,'LinearGauge')
            dlg=locGetGaugeDialogSchema(obj,blockHandle,config);
        elseif strcmp(config.type,'Lamp')
            dlg=locGetLampDialogSchema(obj,blockHandle,config);
        end
    end
end

function dlg=locGetGaugeDialogSchema(obj,blockHandle,config)
    model=get_param(bdroot(blockHandle),'Name');
    modelHandle=get_param(bdroot(blockHandle),'handle');


    dlg=obj.getBaseDialogSchema();


    if Simulink.HMI.isLibrary(model)
        labelPosition=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end

    blockOrientation=get_param(blockHandle,'Orientation');
    sc=get_param(blockHandle,'ScaleDirection');
    if~isempty(sc)
        if strcmp(sc,'Clockwise')
            sc=0;
        elseif strcmp(sc,'CounterClockwise')
            sc=1;
        end
    end



    bounds=[];
    min=get_param(blockHandle,'ScaleMin');
    max=get_param(blockHandle,'ScaleMax');
    interval=get_param(blockHandle,'TickInterval');
    if~isempty(min)&&~isempty(max)&&~isempty(interval)
        if~isequal(interval,'auto')
            interval=str2double(interval);
            if isequal(interval,-1)
                interval='auto';
            end
        end
        bounds=struct('min',min,'max',max,'tickInterval',interval);
        if isempty(sc)
            sc=0;
        end
    else




        if isfield(config,'components')&&~isempty(config.components)
            components=config.components;
            for index=1:length(components)
                if strcmp(components(index).name,'LinearScaleComponent')||...
                    strcmp(components(index).name,'CircularScaleComponent')
                    if isfield(components(index).settings,'bounds')
                        bounds=components(index).settings.bounds;
                    end
                    if isempty(sc)&&isfield(components(index).settings,'scaleDirection')
                        sc=components(index).settings.scaleDirection;
                        if strcmp(sc,'CW')||strcmp(sc,'LR')||strcmp(sc,'BT')
                            sc=0;
                        else
                            sc=1;
                        end
                    else
                        sc=0;
                    end

                end
            end
        end
    end
    if isempty(bounds)

        bounds=struct('min',0,'max',100,'tickInterval','auto');
    end

    obj.ScaleColors=[];
    type=config.type;
    fixedAspectRatio=config.settings.fixedAspectRatio;

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
                if isempty(bounds)&&isfield(components(index).settings,'bounds')
                    bounds=components(index).settings.bounds;
                end
            end
        end
    end


    text.Type='text';
    desc=DAStudio.message('CustomWebBlocks:messages:CustomGaugeDialogDesc');
    if strcmp(type,'LinearGauge')
        if strcmp(blockOrientation,'right')||strcmp(blockOrientation,'left')
            name=DAStudio.message('CustomWebBlocks:messages:HorizontalGauge');
        else
            name=DAStudio.message('CustomWebBlocks:messages:VerticalGauge');
        end
    elseif strcmp(type,'CircularGauge')
        name=DAStudio.message('CustomWebBlocks:messages:CircularGauge');
    end
    if isempty(bounds)
        bounds=struct('min',0,'max',100,'tickInterval','auto');
    end

    if isempty(obj.ScaleColors)
        obj.ScaleColors=get_param(blockHandle,'ScaleColors');
    end


    text.Type='text';
    text.WordWrap=true;
    text.Name=desc;
    text.RowSpan=[1,1];
    text.ColSpan=[1,3];

    editText.Type='text';
    editText.WordWrap=true;
    editText.Name=DAStudio.message('CustomWebBlocks:messages:EditDescription');
    editText.RowSpan=[2,2];
    editText.ColSpan=[1,3];


    editButton.Type='pushbutton';
    editButton.Tag='editButton';
    editButton.Name=DAStudio.message('CustomWebBlocks:messages:EditVisualDesign');
    editButton.MatlabMethod='customwebblocks.utils.openDesignTab';
    editButton.MatlabArgs={modelHandle,blockHandle,true};
    editButton.RowSpan=[3,3];
    editButton.ColSpan=[2,2];

    descGroup.Type='group';
    descGroup.Name=name;
    descGroup.Items={text,editText,editButton};
    descGroup.LayoutGrid=[3,3];
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    propGroup.Type='group';
    propGroup.Items={};
    propGroup.RowSpan=[2,2];
    propGroup.ColSpan=[1,3];
    propGroup.LayoutGrid=[7,3];
    propGroup.RowStretch=[1,0,0,0,0,0,0];


    bindingTable=dlg.Items{1};
    bindingTable.PreferredSize=[100,160];
    bindingTable.MinimumSize=[100,160];
    bindingTable.RowSpan=[1,1];
    bindingTable.ColSpan=[1,3];
    propGroup.Items{end+1}=bindingTable;


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


    scColorsBrowser=dlg.Items{1};
    scColorsBrowser.PreferredSize=[100,160];
    scColorsBrowser.MinimumSize=[100,160];
    scColorsBrowser.RowSpan=[5,5];
    scColorsBrowser.ColSpan=[1,3];
    htmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/GaugesScaleColors.html';
    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,...
    '&isLibWidget=',num2str(obj.isLibWidget),'&isSlimDialog=',num2str(false)];
    scColorsBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    scColorsBrowser.Tag='gauge_scalecolors_browser';
    scColorsBrowser.DisableContextMenu=true;
    if Simulink.HMI.isLibrary(model)||utils.isLockedLibrary(model)
        scColorsBrowser.Enabled=false;
    else
        scColorsBrowser.Enabled=true;
    end
    propGroup.Items{end+1}=scColorsBrowser;

    scaleDirection.Type='combobox';
    scaleDirection.Tag='scaleDirection';
    scaleDirection.Name=...
    DAStudio.message('SimulinkHMI:dialogs:GaugeBlockScaleDirectionPrompt');
    scaleDirection.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionClockwise'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionCounterclockwise')
    };
    scaleDirection.Value=sc;
    scaleDirection.RowSpan=[6,6];
    scaleDirection.ColSpan=[1,3];
    propGroup.Items{end+1}=scaleDirection;

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};



    lockAspectRatio.Type='checkbox';
    lockAspectRatio.Tag='lockAspectRatio';
    lockAspectRatio.Name=DAStudio.message('CustomWebBlocks:messages:LockAspectRatio');
    isLocked=strcmp(fixedAspectRatio,'on');
    lockAspectRatio.Value=isLocked;
    lockAspectRatio.RowSpan=[7,7];
    lockAspectRatio.ColSpan=[1,2];
    propGroup.Items{end+1}=lockAspectRatio;


    labelPositionDropdown.Type='combobox';
    labelPositionDropdown.Tag='labelPosition';
    labelPositionDropdown.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    labelPositionDropdown.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    labelPositionDropdown.Value=labelPosition;
    labelPositionDropdown.RowSpan=[8,8];
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


    if strcmp(type,'LinearGauge')
        if strcmp(blockOrientation,'right')||strcmp(blockOrientation,'left')
            helpTag='horizontal_gauge';
        else
            helpTag='vertical_gauge';
        end
    elseif strcmp(type,'CircularGauge')
        helpTag='circular_gauge';
    end
    dlg.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),helpTag};
end

function dlg=locGetLampDialogSchema(obj,blockHandle,config)
    dlg=obj.getBaseDialogSchema();
    model=get_param(bdroot(blockHandle),'Name');


    descGroup=locGetDescGroup(...
    blockHandle,...
    DAStudio.message('SimulinkHMI:dialogs:Lamp'),...
    DAStudio.message('SimulinkHMI:dialogs:LampDialogDesc'));
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,1];


    mainGroup.Type='group';
    mainGroup.Items={};
    mainGroup.RowSpan=[2,2];
    mainGroup.ColSpan=[1,1];
    mainGroup.LayoutGrid=[6,1];
    mainGroup.RowStretch=[0,0,0,0,0,1];


    bindingTable=dlg.Items{1};
    bindingTable.PreferredSize=[100,160];
    bindingTable.MinimumSize=[100,160];
    bindingTable.RowSpan=[1,1];
    bindingTable.ColSpan=[1,1];
    mainGroup.Items{end+1}=bindingTable;


    labelPositionDropdown=locGetLabelPositionDropdown(blockHandle);
    labelPositionDropdown.RowSpan=[2,2];
    labelPositionDropdown.ColSpan=[1,1];
    mainGroup.Items{end+1}=labelPositionDropdown;


    lockAspectRatio=locGetAspectRatioCheckbox(config);
    lockAspectRatio.RowSpan=[3,3];
    lockAspectRatio.ColSpan=[1,1];
    mainGroup.Items{end+1}=lockAspectRatio;


    settings=customwebblocks.utils.getLampSettingsForDialog(blockHandle,config);
    stateValueType.Type='checkbox';
    stateValueType.Tag='stateValueType';
    stateValueType.Name=DAStudio.message('CustomWebBlocks:messages:SpecifyValuesAsRanges');
    stateValueType.Value=strcmpi(settings.stateValueType,'range');
    stateValueType.MatlabMethod='customwebblocks.utils.toggleCachedValueType';
    stateValueType.MatlabArgs={'%dialog','%source','%tag','%value'};
    stateValueType.RowSpan=[4,4];
    stateValueType.ColSpan=[1,1];
    mainGroup.Items{end+1}=stateValueType;


    statesLabel.Type='text';
    statesLabel.Name=DAStudio.message('CustomWebBlocks:messages:StateSettingsTitle');
    statesLabel.RowSpan=[5,5];
    statesLabel.ColSpan=[1,1];
    mainGroup.Items{end+1}=statesLabel;


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
    ,'&blockHandle=',num2str(blockHandle,64)];
    statesBrowser.Type='webbrowser';
    statesBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    statesBrowser.Tag='lamp_properties_browser';
    statesBrowser.DisableContextMenu=true;
    statesBrowser.RowSpan=[6,6];
    statesBrowser.ColSpan=[1,1];
    statesBrowser.Enabled=~(Simulink.HMI.isLibrary(model)||utils.isLockedLibrary(model));
    mainGroup.Items{end+1}=statesBrowser;


    dlg.Items={descGroup,mainGroup};
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
    dlg.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'custom_lamp'};
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
