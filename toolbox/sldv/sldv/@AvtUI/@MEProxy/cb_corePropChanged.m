function cb_corePropChanged(h,src,evnt)



    lh=h.propProxyListeners(src.Name);
    lh.Enabled='off';


    h.(src.Name)=evnt.AffectedObject.(src.Name);


    lh.Enabled='on';


    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyChangedEvent',h);
end

