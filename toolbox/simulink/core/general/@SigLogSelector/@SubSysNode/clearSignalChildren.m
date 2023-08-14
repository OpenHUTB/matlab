function clearSignalChildren(h)





    if~isempty(h.signalChildren)
        for idx=1:length(h.signalChildren)
            delete(h.signalChildren(idx));
        end
        h.signalChildren=[];


        me=SigLogSelector.getExplorer;
        if~isempty(me)&&~me.getRoot.isClosing
            h.signalsPopulated=true;
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('ListChangedEvent',h);
        end
    end


    h.signalsPopulated=false;

end
