function enableAxesDirtyListeners(hObj,trueFalse)







    axDirtyListener=hObj.AxesListenerList{1};
    if(isvalid(axDirtyListener))
        axDirtyListener.Enabled=trueFalse;
    end
