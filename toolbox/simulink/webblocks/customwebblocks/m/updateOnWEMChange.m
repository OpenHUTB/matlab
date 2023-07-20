function updateOnWEMChange(modelHandle,widgetId,blockHandle,flag)
    if(~isnumeric(modelHandle))
        modelHandle=str2double(modelHandle);
    end
    modelName=get_param(modelHandle,'Name');
    channel=['/customwebblocks/',widgetId];
    msg='disableWEM';
    if isequal(flag,'true')
        msg='enableWEM';
    end
    message.publish(channel,msg);
    if isequal(flag,'true')
        flag=true;
    else
        flag=false;
        blockHandle=-1;
    end
    toggleWidgetEditMode(modelName,blockHandle,flag);
end