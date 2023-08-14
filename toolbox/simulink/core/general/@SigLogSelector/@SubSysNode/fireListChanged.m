function fireListChanged(h)








    if isa(h,'SigLogSelector.BdNode')&&~isempty(h.hParent)
        h.hParent.fireListChanged();
        return;
    end


    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('ListChangedEvent',h);



    curNode=h;
    while~isempty(curNode)


        if strcmp(curNode.cachedHasSignals,'unknown')
            break;
        end


        curNode.cachedHasSignals='unknown';



        if isa(curNode,'SigLogSelector.MdlRefNode')||...
            isa(curNode,'SigLogSelector.SFChartNode')
            break;
        end


        curNode=curNode.hParent;

    end



    clz=class(h);
    if~strcmp(clz,'SigLogSelector.SubSysNode')
        return;
    end


    me=SigLogSelector.getExplorer;
    act=me.getAction('VIEW_ALL_SUBSYS');
    if strcmpi(act.on,'on')
        return;
    end


    me.getRoot.fireHierarchyChanged;

end
