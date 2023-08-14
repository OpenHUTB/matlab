function cm=getContextMenu(this,selectedHandles)




    r=RptgenML.Root;
    e=r.getEditor;

    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(e);

    if isLibrary(this)





        cm.addMenuItem(am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_ComponentMakerData:addPropLabel')),...
        'Callback','exploreAction(subsref(getSelectedListNodes(DAStudio.imExplorer(getEditor(RptgenML.Root))),substruct(''()'',{1})));',...
        'StatusTip',''));
    else

        cm.addMenuItem(r.actions.Cut);
        cm.addMenuItem(r.actions.Copy);
        cm.addMenuItem(r.actions.Paste);
        cm.addMenuItem(r.actions.Delete);

        cm.addSeparator;

        cm.addMenuItem(r.actions.MoveUp);
        cm.addMenuItem(r.actions.MoveDown);

        cm.addSeparator;

        cm.addMenuItem(am.createDefaultAction(e,'CONTEXT_TREE_TO_WS'));

    end





