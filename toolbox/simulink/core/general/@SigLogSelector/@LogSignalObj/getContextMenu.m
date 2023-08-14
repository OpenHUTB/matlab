function cm=getContextMenu(h,nodes)





    if~isempty(nodes)||isempty(h)||isempty(h.signalInfo)
        cm=[];
        return;
    end


    me=SigLogSelector.getExplorer;
    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(me);


    action=me.getAction('CONTEXT_SIG_HIGHLIGHT');
    cm.addMenuItem(action);

    action=me.getAction('CONTEXT_SIG_UNHIGHLIGHT');
    cm.addMenuItem(action);


    if isempty(h.signalInfo.BlockPath.SubPath)
        cm.addSeparator;
        action=me.getAction('CONTEXT_SIG_PROPERTIES');
        cm.addMenuItem(action);
    end
end
