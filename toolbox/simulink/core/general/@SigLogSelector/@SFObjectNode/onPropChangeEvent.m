function wasProcessed=onPropChangeEvent(h,~,e)






    if isequal(e.Source,h.daobject)
        h.firePropertyChange;
        wasProcessed=true;
    else
        wasProcessed=false;
    end

    h.hParent.refreshSignals;
end
