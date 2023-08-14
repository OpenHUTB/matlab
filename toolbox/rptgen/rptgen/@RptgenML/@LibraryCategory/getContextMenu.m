function cm=getContextMenu(this,selectedHandles)




    r=RptgenML.Root;
    e=r.getEditor;

    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(e);






    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_LibraryCategory:toggleCategoryLabel')),...
    'Callback','exploreAction(subsref(getSelectedListNodes(DAStudio.imExplorer(getEditor(RptgenML.Root))),substruct(''()'',{1})));',...
    'StatusTip',''));



