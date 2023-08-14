

function gaugeTicksChanged(dialog,obj)


    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');

    widget=utils.getWidget(mdl,obj.widgetId,obj.isLibWidget);

    MinMaxTickIntervalPropertiesToUpdate={};

    minimumValue=dialog.getWidgetValue('minimumValue');
    maximumValue=dialog.getWidgetValue('maximumValue');
    tickInterval=dialog.getWidgetValue('tickInterval');
    [success,errormsg,ticks]=...
    utils.validateMinMaxTickIntervalFields(minimumValue,...
    maximumValue,tickInterval,dialog,true);

    if~success
        return;
    end

    MinMaxTickIntervalPropertiesToUpdate{1}=[];
    MinMaxTickIntervalPropertiesToUpdate{2}=minimumValue;
    MinMaxTickIntervalPropertiesToUpdate{3}=maximumValue;
    MinMaxTickIntervalPropertiesToUpdate{4}=tickInterval;

    minimumValue=eval(minimumValue);
    maximumValue=eval(maximumValue);
    isTickIntervalAuto=false;
    if strcmpi(tickInterval,'auto')
        isTickIntervalAuto=true;
    end


    diffBetweenMaxAndMin=maximumValue-minimumValue;
    if isTickIntervalAuto
        tickInterval=diffBetweenMaxAndMin/10;
    else
        tickInterval=eval(tickInterval);
    end

    if~isempty(widget)

        if~(minimumValue<=widget.Value&&widget.Value<=maximumValue)
            if(minimumValue<=0&&0<=maximumValue)
                widget.Value=0;
            else
                widget.Value=minimumValue;
            end
        end





        if(~isequal([minimumValue,maximumValue],widget.ScaleLimits)||...
            ~isequal(tickInterval,obj.NumericTickInterval)||...
            (widget.AutoTickInterval~=isTickIntervalAuto))








            widget.AutoTickInterval=isTickIntervalAuto;
            obj.NumericTickInterval=tickInterval;
            widget.MajorTicks=ticks;
            tickLabels=cell(size(ticks));
            for idx=1:length(ticks)
                tickLabels{idx}=num2str(ticks(idx));
            end
            widget.MajorTickLabels=tickLabels;
            widget.MinorTicks=utils.getMinorTicks(ticks);
        end

        widget.ScaleLimits=[minimumValue,maximumValue];

        set_param(mdl,'Dirty','on');


        signalDlgs=obj.getOpenDialogs(true);
        for j=1:length(signalDlgs)
            if~isequal(dialog,signalDlgs{j})
                utils.updateMinMaxTickIntervalFields(signalDlgs{j},MinMaxTickIntervalPropertiesToUpdate);
            end
        end
        dialog.enableApplyButton(false,false);
    end

end
