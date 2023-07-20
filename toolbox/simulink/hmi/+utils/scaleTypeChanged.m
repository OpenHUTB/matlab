

function scaleTypeChanged(dlgH,obj,isSlimDialog)
    blockHandle=get(obj.blockObj,'handle');
    if strcmpi(get_param(blockHandle,'BlockType'),'SubSystem')
        locScaleTypeChangedLegacy(dlgH,obj,isSlimDialog);
    else
        locScaleTypeChangedCoreBlock(dlgH,obj,isSlimDialog);
    end
end


function locScaleTypeChangedCoreBlock(dlgH,obj,isSlimDialog)

    scaleType=logical(dlgH.getWidgetValue('scaleType'));
    isLogScale=(scaleType==1);
    blockHandle=get(obj.blockObj,'handle');
    curScaleType=get_param(blockHandle,'ScaleType');
    wasLogScale=strcmpi(curScaleType,'Log');
    if isLogScale==wasLogScale
        return
    end


    if isLogScale
        tickIntervalPrompt=DAStudio.message('SimulinkHMI:dialogs:LogTickIntervalPrompt');
        min='1';
        max='10000';
    else
        tickIntervalPrompt=DAStudio.message('SimulinkHMI:dialogs:TickIntervalPrompt');
        min='0';
        max='100';
    end

    dlgH.setWidgetPrompt('tickInterval',tickIntervalPrompt);
    dlgH.setWidgetValue('maximumValue',max);
    dlgH.setWidgetValue('minimumValue',min);
    dlgH.setWidgetValue('tickInterval','auto');

    if isSlimDialog
        utils.slimDialogUtils.knobSettingsChanged(dlgH,obj);
    end
end


function locScaleTypeChangedLegacy(dlgH,obj,isSlimDialog)
    scaleType=logical(dlgH.getWidgetValue('scaleType'));
    isLogScale=(scaleType==1);
    defaultMin='0';
    defaultMax='100';
    defaultLogMin='1';
    defaultLogMax='10000';
    tickInterval='auto';

    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');

    widget=utils.getWidget(mdl,obj.widgetId,obj.isLibWidget);

    if(isLogScale)


        tickIntervalPrompt=DAStudio.message('SimulinkHMI:dialogs:LogTickIntervalPrompt');
        min=defaultLogMin;
        max=defaultLogMax;
        if(strcmp(utils.getScaleTypeAsString(widget.ScaleType),'Log'))
            min=num2str(widget.ScaleLimits(1));
            max=num2str(widget.ScaleLimits(2));

            tickInterval=num2str(log10(widget.MajorTicks(2)/widget.MajorTicks(1)));
        end
    else


        tickIntervalPrompt=DAStudio.message('SimulinkHMI:dialogs:TickIntervalPrompt');
        min=defaultMin;
        max=defaultMax;
        if(strcmp(utils.getScaleTypeAsString(widget.ScaleType),'Linear'))
            min=num2str(widget.ScaleLimits(1));
            max=num2str(widget.ScaleLimits(2));
            tickInterval=num2str(widget.MajorTicks(2)-widget.MajorTicks(1));
        end
    end
    dlgH.setWidgetPrompt('tickInterval',tickIntervalPrompt);
    if~strcmp(dlgH.getWidgetValue('maximumValue'),max)
        dlgH.setWidgetValue('maximumValue',max);
    end

    if~strcmp(dlgH.getWidgetValue('minimumValue'),min)
        dlgH.setWidgetValue('minimumValue',min);
    end

    if(widget.AutoTickInterval)
        tickInterval='auto';
    end

    if~strcmp(dlgH.getWidgetValue('tickInterval'),tickInterval)
        dlgH.setWidgetValue('tickInterval',tickInterval);
    end

    if isSlimDialog

        widget.ScaleType=scaleType;
        utils.slimDialogUtils.handleTicksChanged(dlgH,obj);
    end
end
