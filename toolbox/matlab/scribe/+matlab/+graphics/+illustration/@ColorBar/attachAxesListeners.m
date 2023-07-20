function attachAxesListeners(hObj,hAxes)





    addlistener(hObj,'ObjectBeingDestroyed',@(h,e)hObj.doDelete);


    hObj.AxesListenerList{end+1}=event.listener(hAxes,'MarkedDirty',@(h,e)hObj.MarkDirty('all'));
    hObj.AxesListenerList{end+1}=event.listener(hAxes,'ObjectBeingDestroyed',@(h,e)delete(hObj));
    hObj.AxesListenerList{end+1}=event.listener(hAxes,'ClaReset',@(h,e)delete(hObj));


    hObj.AxesListenerList{end+1}=event.proplistener(hAxes,findprop(hAxes,'Colormap'),'PostSet',@(h,e)changedColorSpace(hObj));
    hObj.AxesListenerList{end+1}=event.listener(hAxes.ColorSpace,'MarkedDirty',@(h,e)updateLimits(h,hObj));

    function changedColorSpace(hObj)
        if isvalid(hObj)
            hObj.MarkDirty('all');
            for i=1:numel(hObj.AxesListenerList)
                delete(hObj.AxesListenerList{i});
            end
            hObj.AxesListenerList=[];
            attachAxesListeners(hObj,hObj.Axes);
        end
    end

    function updateLimits(colorspace,colorbar)
        if isvalid(colorbar)&&strcmp(colorbar.LimitsMode,'auto')
            ax=ancestor(colorspace,'Axes');
            if~isempty(ax)
                hObj.MarkDirty('all')
            end
        end
    end
end
