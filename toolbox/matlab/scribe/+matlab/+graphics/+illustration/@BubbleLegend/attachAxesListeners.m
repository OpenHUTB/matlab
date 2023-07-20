function attachAxesListeners(hObj,hAxes)




    function safeMarkDirty(h,e)
        if ishandle(hObj)
            hObj.MarkDirty('all')
        end
    end


    hObj.AxesListenerList=hObj.AxesListenerList(isvalid(hObj.AxesListenerList));

    hObj.AxesListenerList(end+1)=event.listener(hAxes,'MarkedDirty',@safeMarkDirty);
    hObj.AxesListenerList(end+1)=event.listener(hAxes,'ObjectBeingDestroyed',@(h,e)delete(hObj));
    hObj.AxesListenerList(end+1)=event.listener(hAxes,'ClaReset',@(h,e)delete(hObj));
    hObj.AxesListenerList(end+1)=event.listener(hAxes,'LegendableObjectsUpdated',@(h,e)matlab.graphics.illustration.BubbleLegend.autoUpdateCallback(e,hObj));
    hObj.AxesListenerList(end+1)=event.listener(hAxes.HintConsumer,'MarkedDirty',@safeMarkDirty);
end
