

function handleTicksChanged(dialog,obj)

    MinMaxTickIntervalPropertiesToUpdate={};

    minimumValue=dialog.getWidgetValue('minimumValue');
    maximumValue=dialog.getWidgetValue('maximumValue');
    tickInterval=dialog.getWidgetValue('tickInterval');
    scaleType=dialog.getWidgetValue('scaleType');
    scaleTypeStr=utils.getScaleTypeAsString(scaleType);

    [success,~,ticks]=...
    utils.validateMinMaxTickIntervalFields(minimumValue,maximumValue,...
    tickInterval,dialog,true,scaleTypeStr);
    if~success
        return;
    end

    MinMaxTickIntervalPropertiesToUpdate{1}=scaleType;
    MinMaxTickIntervalPropertiesToUpdate{2}=minimumValue;
    MinMaxTickIntervalPropertiesToUpdate{3}=maximumValue;
    MinMaxTickIntervalPropertiesToUpdate{4}=tickInterval;

    minimumValue=eval(minimumValue);
    maximumValue=eval(maximumValue);
    isTickIntervalAuto=false;
    if strcmpi(tickInterval,'auto')
        isTickIntervalAuto=true;
    end

    tickInterval=utils.getTickInterval(minimumValue,maximumValue,...
    tickInterval,scaleTypeStr);



    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');

    widget=utils.getWidget(mdl,obj.widgetId,obj.isLibWidget);

    if~isempty(widget)

        if~(minimumValue<=widget.Value&&widget.Value<=maximumValue)
            if(minimumValue<=0&&0<=maximumValue)
                widget.Value=0;
            else
                widget.Value=minimumValue;
            end
        end

        prevNumericTickInterval=widget.MajorTicks(2)-widget.MajorTicks(1);
        if(~isequal([minimumValue,maximumValue],widget.ScaleLimits)||...
            ~isequal(scaleType,widget.ScaleType)||...
            ~isequal(tickInterval,prevNumericTickInterval)||...
            (widget.AutoTickInterval~=isTickIntervalAuto))








            widget.AutoTickInterval=isTickIntervalAuto;
            widget.MajorTicks=ticks;
            tickLabels=cell(size(ticks));
            for idx=1:length(ticks)
                tickLabels{idx}=num2str(ticks(idx));
            end
            widget.ScaleLimits=[minimumValue,maximumValue];
            widget.MajorTickLabels=tickLabels;
            widget.MinorTicks=utils.getMinorTicks(ticks,scaleTypeStr);
        end


        set_param(mdl,'Dirty','on');


        paramDlgs=obj.getOpenDialogs(true);
        for j=1:length(paramDlgs)
            if~isequal(dialog,paramDlgs{j})
                utils.updateMinMaxTickIntervalFields(paramDlgs{j},MinMaxTickIntervalPropertiesToUpdate);
            end
        end
        dialog.enableApplyButton(false,false);
    end

end
