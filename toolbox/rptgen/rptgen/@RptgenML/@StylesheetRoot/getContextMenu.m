function cm=getContextMenu(this,selectedHandles)




    r=RptgenML.Root;

    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(r.Editor);

    cm.addMenuItem(r.actions.Save)
    cm.addMenuItem(r.actions.Close)

    cm.addSeparator;

    cm.addMenuItem(r.actions.MoveUp);
    cm.addMenuItem(r.actions.MoveDown);

