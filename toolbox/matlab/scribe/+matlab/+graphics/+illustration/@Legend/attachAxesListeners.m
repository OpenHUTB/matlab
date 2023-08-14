function attachAxesListeners(hObj,hAxes)



    function safeMarkDirty(h,e)
        if ishandle(hObj)
            hObj.MarkDirty('all')
        end
    end
    hObj.AxesListenerList(end+1)=event.listener(hAxes,'MarkedDirty',@safeMarkDirty);
    hObj.AxesListenerList(end+1)=event.listener(hAxes,'ObjectBeingDestroyed',@(h,e)delete(hObj));
    hObj.AxesListenerList(end+1)=event.listener(hAxes,'ClaReset',@(h,e)delete(hObj));


    hObj.AxesListenerList(end+1)=event.listener(hAxes,'LegendableObjectsUpdated',@matlab.graphics.illustration.Legend.autoUpdateCallback);
end




























































































