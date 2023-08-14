function wasProcessed=onPropChangeEvent(h,~,e)






    if~isa(h.daobject,'Simulink.SubSystem')||...
        ~isequal(h.daobject,e.Source)
        wasProcessed=false;
        return;
    end


    h.refreshSignals;
    wasProcessed=true;

end
