function enableAxesDirtyListeners(hObj,trueFalse)




    if numel(hObj.AxesListenerList)>=4
        hObj.AxesListenerList(1).Enabled=trueFalse;
        hObj.AxesListenerList(4).Enabled=trueFalse;
    end

end
