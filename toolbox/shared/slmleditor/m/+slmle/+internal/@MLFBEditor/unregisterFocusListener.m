function unregisterFocusListener(obj)




    if~isempty(obj.focusService)&&~isempty(obj.focusListener)
        obj.focusService.unRegisterServiceCallback(obj.focusListener);
    end
    obj.focusListener=[];
end
