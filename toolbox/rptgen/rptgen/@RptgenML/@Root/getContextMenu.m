function cm=getContextMenu(this,selectedHandles)




    e=this.getEditor;

    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(e);

    cm.addMenuItem(this.actions.New);
    cm.addMenuItem(this.actions.NewForm);
    cm.addMenuItem(this.actions.Open);

    cm.addSeparator;

    cm.addMenuItem(this.actions.ConvertFile);
    cm.addMenuItem(this.actions.CreateComponent);
    cm.addMenuItem(this.actions.EditStylesheet);

