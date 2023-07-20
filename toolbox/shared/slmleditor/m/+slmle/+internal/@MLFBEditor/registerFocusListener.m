function registerFocusListener(obj)




    obj.focusService=...
    obj.studio.getService("Studio::ActiveComponentChangedEventService");
    if isempty(obj.focusListener)
        obj.focusListener=obj.focusService.registerServiceCallback(@(f)obj.onFocusChange);
    end
end
