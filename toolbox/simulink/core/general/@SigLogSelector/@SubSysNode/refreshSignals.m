function refreshSignals(h,bSleep)







    if nargin<2||bSleep
        me=SigLogSelector.getExplorer;
        me.sleep;
    end




    if~isempty(h.childNodes)
        numChildren=h.childNodes.getCount();
        for idx=1:numChildren
            child=h.childNodes.getDataByIndex(idx);
            child.refreshSignals(false);
        end
    end


    h.clearSignalChildren;
    h.fireListChanged;


    if nargin<2||bSleep
        me=SigLogSelector.getExplorer;
        me.wake;
    end

end
