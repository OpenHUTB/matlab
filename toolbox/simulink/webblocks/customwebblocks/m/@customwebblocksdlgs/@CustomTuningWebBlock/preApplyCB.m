


function[success,errormsg]=preApplyCB(obj,dlg)
    success=true;
    errormsg='';


    blockHandle=obj.get_param('handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if customwebblocks.utils.isLibrary(mdl)
        return;
    end


    config=jsondecode(get_param(blockHandle,'Configuration'));
    if isfield(config,'type')
        if strcmp(config.type,'CircularGauge')||strcmp(config.type,'LinearGauge')
            [success,errormsg]=locApplySliderSettings(obj,dlg,blockHandle);
        elseif strcmp(config.type,'Button')
            if isfield(config,'settings')&&...
                isfield(config.settings,'variant')&&...
                strcmp(config.settings.variant,'callback')
                [success,errormsg]=locApplyCallbackButtonSettings(obj,dlg,blockHandle,config);
            else
                [success,errormsg]=locApplyPushButtonSettings(obj,dlg,blockHandle,config);
            end
        elseif strcmp(config.type,'Switch')||strcmp(config.type,'RotarySwitch')
            [success,errormsg]=locApplySwitchSettings(obj,dlg,blockHandle,config);
        end
    end
end

function[success,errormsg]=locApplySliderSettings(obj,dlg,blockHandle)


    minVal=strtrim(dlg.getWidgetValue('minimumValue'));
    maxVal=strtrim(dlg.getWidgetValue('maximumValue'));
    tickVal=strtrim(dlg.getWidgetValue('tickInterval'));
    scaleDirection=dlg.getComboBoxText('scaleDirection');
    [success,errormsg]=...
    utils.validateMinMaxTickIntervalFields(minVal,maxVal,tickVal,dlg,false);
    if~success
        return
    end

    bounds=struct;
    bounds.Min=minVal;
    bounds.Max=maxVal;
    bounds.Ticks=tickVal;

    batchedUpdate={};
    batchedUpdate.Limits=bounds;
    batchedUpdate.ScaleDirection=scaleDirection;
    batchedUpdate.LabelPosition=simulink.hmi.getLabelPosition(dlg.getComboBoxText('labelPosition'));
    batchedUpdate.fixedAspectRatio=locGetAspectRatioSetting(dlg);

    DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'batchedUndoableParamsUpdate',jsonencode(batchedUpdate),'undoable');


    bindParameter(obj);


    openDlgs=obj.getOpenDialogs(true);
    for i=1:length(openDlgs)
        if~isequal(dlg,openDlgs{i})
            props.ScaleMin=minVal;
            props.ScaleMax=maxVal;
            props.Tick=tickVal;
            utils.updateKnobSettings(openDlgs{i},props);
            utils.updateLabelPosition(openDlgs{i},batchedUpdate.LabelPosition);
            customwebblocks.utils.updateFixedAspectRatio(openDlgs{i},batchedUpdate.fixedAspectRatio);
        end
    end
end

function[success,errormsg]=locApplyPushButtonSettings(obj,dlg,blockHandle,config)


    [success,errormsg,batchedUpdate]=customwebblocks.utils.applyButtonSettingsFromDialog(dlg,obj,config);
    if~success
        return;
    end

    batchedUpdate.LabelPosition=simulink.hmi.getLabelPosition(dlg.getComboBoxText('labelPosition'));
    batchedUpdate.fixedAspectRatio=locGetAspectRatioSetting(dlg);

    DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'batchedUndoableParamsUpdate',jsonencode(batchedUpdate),'undoable');


    bindParameter(obj);
    openDlgs=obj.getOpenDialogs(true);
    for i=1:length(openDlgs)
        if~isequal(dlg,openDlgs{i})
            utils.updateLabelPosition(openDlgs{i},batchedUpdate.LabelPosition);
            customwebblocks.utils.updateFixedAspectRatio(openDlgs{i},batchedUpdate.fixedAspectRatio);
        end
    end
end

function[success,errormsg]=locApplyCallbackButtonSettings(obj,dlg,blockHandle,config)


    [success,errormsg,batchedUpdate]=customwebblocks.utils.applyButtonSettingsFromDialog(dlg,obj,config);
    if~success
        return;
    end

    batchedUpdate.fixedAspectRatio=locGetAspectRatioSetting(dlg);

    DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'batchedUndoableParamsUpdate',jsonencode(batchedUpdate),'undoable');

    openDlgs=obj.getOpenDialogs(true);
    for i=1:length(openDlgs)
        if~isequal(dlg,openDlgs{i})
            customwebblocks.utils.updateFixedAspectRatio(openDlgs{i},batchedUpdate.fixedAspectRatio);
        end
    end
end

function[success,errormsg]=locApplySwitchSettings(obj,dlg,blockHandle,config)
    supportsEnums=strcmp(config.type,'RotarySwitch');

    [success,errormsg,batchedUpdate]=customwebblocks.utils.applySwitchSettingsFromDialog(dlg,obj,supportsEnums,config);
    if~success
        return;
    end

    batchedUpdate.LabelPosition=simulink.hmi.getLabelPosition(dlg.getComboBoxText('labelPosition'));
    batchedUpdate.fixedAspectRatio=locGetAspectRatioSetting(dlg);

    DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'batchedUndoableParamsUpdate',jsonencode(batchedUpdate),'undoable');

    bindParameter(obj);

    openDlgs=obj.getOpenDialogs(true);
    for i=1:length(openDlgs)
        if~isequal(dlg,openDlgs{i})
            utils.updateLabelPosition(openDlgs{i},batchedUpdate.LabelPosition);
            customwebblocks.utils.updateFixedAspectRatio(openDlgs{i},batchedUpdate.fixedAspectRatio);
        end
    end
end

function lockAspectRatio=locGetAspectRatioSetting(dlg)
    lockAspectRatio=dlg.getWidgetValue('lockAspectRatio');
    if lockAspectRatio
        lockAspectRatio='on';
    else
        lockAspectRatio='off';
    end
end
