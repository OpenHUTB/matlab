function objectRemoved(h,~,e)




    if~h.isRemoveable
        return;
    end



    child=e.Child;
    if h.signalsPopulated&&~isempty(h.signalChildren)
        if isa(child,'Simulink.Line')||isa(child,'Simulink.Port')
            h.clearSignalChildren;
            h.fireListChanged;
            return;
        end
    end


    child=SigLogSelector.filter(child);
    if isempty(child)
        return;
    end

    if~h.childNodes.isKey(child.Name)
        return
    end
    blk=h.childNodes.getDataByKey(child.Name);
    h.childNodes.deleteDataByKey(child.Name);
    if~ishandle(blk)
        return
    end



    bContainsMdlRef=blk.containsModelReference;
    blk.unpopulate;
    blk.signalsPopulated=true;


    h.clearSignalChildren;
    h.fireListChanged;


    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('ChildRemovedEvent',h,blk);



    if bContainsMdlRef
        me=SigLogSelector.getExplorer;
        me.getRoot.modelBlockAddedOrRemoved;
    end

end
