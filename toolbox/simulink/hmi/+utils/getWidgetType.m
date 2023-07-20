

function widgetType=getWidgetType(blockHandle)
    if(strcmp(get_param(blockHandle,'isCoreWebBlock'),'on'))
        widgetType=get_param(blockHandle,'BlockType');
    else
        try
            widgetType=get_param(blockHandle,'webBlockType');
        catch ME
            if(strcmp(ME.identifier,'Simulink:Commands:ParamUnknown'))
                widgetType='None';
            end
        end
    end
end