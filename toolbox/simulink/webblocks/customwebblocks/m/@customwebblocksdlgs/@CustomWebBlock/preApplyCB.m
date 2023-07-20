


function[success,errormsg]=preApplyCB(obj,dlg)
    success=true;
    errormsg='';


    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if customwebblocks.utils.isLibrary(mdl)
        return
    end


    config=jsondecode(get_param(blockHandle,'Configuration'));
    if isfield(config,'type')
        if strcmp(config.type,'CircularGauge')||strcmp(config.type,'LinearGauge')
            [success,errormsg]=locApplyGaugeSettings(obj,dlg,blockHandle,config);
        elseif strcmp(config.type,'Lamp')
            [success,errormsg]=locApplyLampSettings(obj,dlg,blockHandle,config);
        end
    end
end

function[success,errormsg]=locApplyGaugeSettings(obj,dlg,blockHandle,config)

    minVal=strtrim(dlg.getWidgetValue('minimumValue'));
    maxVal=strtrim(dlg.getWidgetValue('maximumValue'));
    tickVal=strtrim(dlg.getWidgetValue('tickInterval'));
    scaleDirection=dlg.getComboBoxText('scaleDirection');
    [success,errormsg]=...
    utils.validateMinMaxTickIntervalFields(minVal,maxVal,tickVal,dlg,false);
    if~success
        return
    end
    [success,errormsg,scaleColors]=locValidateScaleColors(obj);
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
    batchedUpdate.ScaleColors=scaleColors;
    batchedUpdate.LabelPosition=simulink.hmi.getLabelPosition(dlg.getComboBoxText('labelPosition'));
    batchedUpdate.fixedAspectRatio=locGetAspectRatioSetting(dlg);

    DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'batchedUndoableParamsUpdate',jsonencode(batchedUpdate),'undoable');


    bindSignal(obj);


    signalDlgs=obj.getOpenDialogs(true);
    for j=1:length(signalDlgs)
        signalDlgs{j}.enableApplyButton(false,false);
        if~isequal(dlg,signalDlgs{j})
            props{1}=[];
            props{2}=minVal;
            props{3}=maxVal;
            props{4}=tickVal;
            utils.updateMinMaxTickIntervalFields(signalDlgs{j},props);
            utils.updateLabelPosition(signalDlgs{j},batchedUpdate.LabelPosition);
            utils.updateScaleColors(obj,dlg);
            customwebblocks.utils.updateFixedAspectRatio(signalDlgs{j},batchedUpdate.fixedAspectRatio);
        end
    end
end

function[ret,err,scaleColors]=locValidateScaleColors(dlgSrc)
    ret=true;
    err='';
    scaleColors=[];

    scChannel='/hmi_scalecolors_controller_/';
    numScales=numel(dlgSrc.ScaleColors);
    for idx=1:numScales
        prop=dlgSrc.ScaleColors(idx);


        invIdx={};
        if isempty(prop.Min)||~isreal(prop.Min)||~isfinite(prop.Min)
            invIdx{1}={idx,1};
        elseif isempty(prop.Max)||~isreal(prop.Max)||~isfinite(prop.Max)
            invIdx{1}={idx,2};
        end
        if~isempty(invIdx)
            ret=false;
            err=DAStudio.message('SimulinkHMI:dialogs:NonNumberScaleColorLimitsError');
            message.publish(...
            [scChannel,'showInvalidScaleColorLimits'],...
            {invIdx,err});
        end


        if prop.Min>prop.Max
            ret=false;
            invIdx{1}={idx,1};
            invIdx{2}={idx,2};
            err=DAStudio.message('SimulinkHMI:dialogs:ScaleColorLimitsMinGreaterThanMax');
            message.publish(...
            [scChannel,'showInvalidScaleColorLimits'],...
            {invIdx,err});
        end
        scaleColor=struct;
        scaleColor.Min=prop.Min;
        scaleColor.Max=prop.Max;
        if any(prop.Color>=0&prop.Color<=1)
            scaleColor.Color=round(prop.Color*255);
        else
            scaleColor.Color=prop.Color;
        end
        scaleColors=[scaleColors,scaleColor];
    end
end

function[success,errormsg]=locApplyLampSettings(obj,dlg,blockHandle,config)
    success=true;
    errormsg='';
    batchedUpdate={};
    updatedSettings=[];

    newStateValueTypeIndex=dlg.getWidgetValue('stateValueType');
    switch newStateValueTypeIndex
    case 0
        newStateValueType='Discrete';
    case 1
        newStateValueType='Range';
    end
    currentStateValueType=get_param(blockHandle,'StateValueType');

    if~strcmp(currentStateValueType,newStateValueType)
        batchedUpdate.StateValueType=newStateValueType;
        updatedSettings.stateValueType=newStateValueTypeIndex;
    end
    dlg.clearWidgetDirtyFlag('stateValueType');



    if~isempty(obj.CachedStates)
        batchedUpdate.States=obj.CachedStates;
        obj.CachedStates='';
    end

    batchedUpdate.LabelPosition=simulink.hmi.getLabelPosition(dlg.getComboBoxText('labelPosition'));
    batchedUpdate.fixedAspectRatio=locGetAspectRatioSetting(dlg);

    DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'batchedUndoableParamsUpdate',jsonencode(batchedUpdate),'undoable');


    bindSignal(obj);


    signalDlgs=obj.getOpenDialogs(true);
    for j=1:length(signalDlgs)
        signalDlgs{j}.enableApplyButton(false,false);
        if~isequal(dlg,signalDlgs{j})
            utils.updateLabelPosition(signalDlgs{j},batchedUpdate.LabelPosition);
            customwebblocks.utils.updateFixedAspectRatio(signalDlgs{j},batchedUpdate.fixedAspectRatio);
            customwebblocks.utils.updateDialogSettings(signalDlgs{j},updatedSettings);
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
