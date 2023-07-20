function cm=getContextMenu(this,selectedHandles)




    r=RptgenML.Root;
    e=r.getEditor;

    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(e);



    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_LibraryComponent:addComponentLabel')),...
    'Icon',fullfile(matlabroot,'toolbox/rptgen/resources/Component_unparentable.png'),...
    'Callback','acceptDrop(getCurrentComponent(RptgenML.Root),getSelectedListNodes(RptgenML.Root));',...
    'StatusTip',''));


    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_LibraryComponent:helpLabelAccelerator')),...
    'Callback','viewHelp(getSelectedListNodes(RptgenML.Root));',...
    'StatusTip',sprintf(getString(message('rptgen:RptgenML_LibraryComponent:helpTooltip')))));

    cm.addSeparator;

    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_LibraryComponent:sendToWSLabel')),...
    'Callback','ans = makeComponent(getSelectedListNodes(RptgenML.Root,true))',...
    'StatusTip',getString(message('rptgen:RptgenML_LibraryComponent:sendCompToWSLabel'))));



