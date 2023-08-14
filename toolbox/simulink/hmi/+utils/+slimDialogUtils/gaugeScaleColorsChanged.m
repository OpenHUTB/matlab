


function gaugeScaleColorsChanged(gaugeDlgSrc,widgetId,mdl,isLibWidget)
    if isa(gaugeDlgSrc,'hmiblockdlg.GaugeBlock')||...
        isa(gaugeDlgSrc,'aeroblkhmidlg.SimpleScaleColorBlock')||...
        isa(gaugeDlgSrc,'aeroblkhmidlg.RPMIndicatorBlock')
        locCoreBlockCB(gaugeDlgSrc,widgetId,mdl);
    elseif isa(gaugeDlgSrc,'customwebblocksdlgs.CustomWebBlock')
        locCustomBlockCB(gaugeDlgSrc,widgetId,mdl);
    else
        locLegacyBlockCB(gaugeDlgSrc,widgetId,mdl,isLibWidget);
    end
end


function locCustomBlockCB(dlgSrc,widgetId,mdl)
    if locValidateScaleColors(dlgSrc)
        blockHandle=get(dlgSrc.blockObj,'handle');
        scChannel='/hmi_scalecolors_controller_/';
        numScales=numel(dlgSrc.ScaleColors);
        scaleColors=[];
        for idx=1:numScales
            prop=dlgSrc.ScaleColors(idx);

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
        DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'ScaleColors',jsonencode(scaleColors),'undoable');
        gaugeScaleColorsData={};
        numStates=numel(dlgSrc.ScaleColors);
        gaugeScaleColorsData{1}=zeros(numStates,3);
        gaugeScaleColorsData{2}=cell(1,numStates);

        for idx=1:numStates
            gaugeScaleColorsData{1}(idx,:)=uint32(255.*dlgSrc.ScaleColors(idx).Color);
            gaugeScaleColorsData{2}{idx}=cell(1,2);
            gaugeScaleColorsData{2}{idx}{1}=num2str(dlgSrc.ScaleColors(idx).Min);
            gaugeScaleColorsData{2}{idx}{2}=num2str(dlgSrc.ScaleColors(idx).Max);
        end
        message.publish([scChannel,'updateProperties'],...
        {true,widgetId,mdl,gaugeScaleColorsData});
    end


end


function locCoreBlockCB(dlgSrc,widgetId,mdl)
    if locValidateScaleColors(dlgSrc)
        blockHandle=get(dlgSrc.blockObj,'handle');
        scChannel='/hmi_scalecolors_controller_/';
        set_param(blockHandle,'ScaleColors',dlgSrc.ScaleColors);
        gaugeScaleColorsData={};
        numStates=numel(dlgSrc.ScaleColors);
        gaugeScaleColorsData{1}=zeros(numStates,3);
        gaugeScaleColorsData{2}=cell(1,numStates);
        for idx=1:numStates
            gaugeScaleColorsData{1}(idx,:)=uint32(255.*dlgSrc.ScaleColors(idx).Color);
            gaugeScaleColorsData{2}{idx}=cell(1,2);
            gaugeScaleColorsData{2}{idx}{1}=num2str(dlgSrc.ScaleColors(idx).Min);
            gaugeScaleColorsData{2}{idx}{2}=num2str(dlgSrc.ScaleColors(idx).Max);
        end
        message.publish([scChannel,'updateProperties'],...
        {true,widgetId,mdl,gaugeScaleColorsData});
    end
end


function ret=locValidateScaleColors(dlgSrc)
    ret=true;

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


function locLegacyBlockCB(gaugeDlgSrc,widgetId,mdl,isLibWidget)
    scChannel='/hmi_scalecolors_controller_/';
    gaugeScaleColorsData={};

    widget=utils.getWidget(mdl,widgetId,isLibWidget);
    if~isempty(widget)
        invStateIndexes={};
        scaleColorLimits=[];

        if isempty(gaugeDlgSrc.ScaleColors)
            gaugeDlgSrc.ScaleColors=ones(0,3);
        end
        if isempty(gaugeDlgSrc.ScaleColorLimits)
            scaleColorLimits=ones(0,2);
        end

        for idx=1:length(gaugeDlgSrc.ScaleColorLimits)
            tempArr=[];
            for jdx=1:length(gaugeDlgSrc.ScaleColorLimits{idx})
                data=gaugeDlgSrc.ScaleColorLimits{idx}{jdx};
                if isequal('char',class(data))
                    data=str2double(data);
                end
                if isempty(data)||~(isreal(data))||isnan(data)||isinf(data)
                    invStateIndexes{end+1}={idx,jdx};
                    errormsg=DAStudio.message('SimulinkHMI:dialogs:NonNumberScaleColorLimitsError');
                    message.publish([scChannel,'showInvalidScaleColorLimits'],...
                    {invStateIndexes,errormsg});
                    return;
                else
                    tempArr=[tempArr,data];
                end
            end
            if tempArr(1)>tempArr(2)
                invStateIndexes{end+1}={idx,1};
                invStateIndexes{end+1}={idx,2};
                errormsg=DAStudio.message('SimulinkHMI:dialogs:ScaleColorLimitsMinGreaterThanMax');
                message.publish([scChannel,'showInvalidScaleColorLimits'],...
                {invStateIndexes,errormsg});
                return;
            end
            scaleColorLimits=[scaleColorLimits;tempArr];
        end

        widget.ScaleColors=gaugeDlgSrc.ScaleColors;
        widget.ScaleColorLimits=scaleColorLimits;

        gaugeScaleColorsData{1}=gaugeDlgSrc.ScaleColors;
        gaugeScaleColorsData{2}=gaugeDlgSrc.ScaleColorLimits;
        message.publish([scChannel,'updateProperties'],...
        {true,widgetId,mdl,gaugeScaleColorsData});

        set_param(mdl,'Dirty','on');
    end
end
