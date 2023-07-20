function l=createCallback(data,sourceObject,property,callbackType,callbackTarget,callback)





















    prop_handle=findprop(sourceObject,property);
    l=handle.listener(...
    sourceObject,...
    prop_handle,...
    callbackType,...
    callback);

    if~isempty(callbackTarget)
        l.CallbackTarget=callbackTarget;
    end

    listeners=data.listeners;
    data.listeners=[listeners;l];

