


function[success,errormsg]=preApplyCB(obj,dlg)
    success=true;
    errormsg='';

    blockHandle=get(obj.blockObj,'handle');
    type=get_param(blockHandle,'BlockType');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return
    end

    opacity='';
    fontColor='';
    backgroundColor='';
    foregroundColor='';
    scaleColors=obj.ScaleColors;
    fontColor=obj.FontColor;
    opacity=dlg.getWidgetValue('opacity');
    backgroundColor=obj.BackgroundColor;
    foregroundColor=obj.ForegroundColor;


    minVal=strtrim(dlg.getWidgetValue('minimumValue'));
    maxVal=strtrim(dlg.getWidgetValue('maximumValue'));
    tickVal=strtrim(dlg.getWidgetValue('tickInterval'));
    [success,errormsg]=...
    utils.validateMinMaxTickIntervalFields(minVal,maxVal,tickVal,dlg,false);
    if~success
        return
    end
    [success,errormsg]=locValidateScaleColors(obj);
    if~success
        return
    end


    labelPosition=simulink.hmi.getLabelPosition(dlg.getComboBoxText('labelPosition'));
    set_param(blockHandle,'FontColor',jsondecode(fontColor),...
    'BackgroundColor',backgroundColor,...
    'ForegroundColor',foregroundColor,...
    'Opacity',opacity);
    if strcmp(type,'LinearGaugeBlock')
        scaleDirection=0;
    else
        scaleDirection=dlg.getWidgetValue('scaleDirection');
    end


    set_param(blockHandle,'ScaleMin',minVal,...
    'ScaleMax',maxVal,...
    'TickInterval',tickVal,...
    'LabelPosition',labelPosition,...
    'ScaleDirection',scaleDirection,...
    'ScaleColors',scaleColors);


    bindSignal(obj);



    scChannel='/hmi_displayblock_colors_controller_/';
    signalDlgs=obj.getOpenDialogs(true);
    for j=1:length(signalDlgs)
        signalDlgs{j}.enableApplyButton(false,false);
        if~isequal(dlg,signalDlgs{j})
            props{1}=[];
            props{2}=minVal;
            props{3}=maxVal;
            props{4}=tickVal;
            utils.updateMinMaxTickIntervalFields(signalDlgs{j},props);
            utils.updateScaleColors(obj,dlg);
            message.publish([scChannel,'updateColors'],...
            {false,obj.widgetId,mdl,obj.BackgroundColor,obj.ForegroundColor,fontColor});
            utils.updateOpacity(signalDlgs{j},opacity);
        end
    end
end


function[ret,err]=locValidateScaleColors(dlgSrc)
    ret=true;
    err='';

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
    end
end
