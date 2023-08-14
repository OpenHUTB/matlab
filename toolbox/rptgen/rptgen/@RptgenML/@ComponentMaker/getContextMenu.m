function cm=getContextMenu(this,selectedHandles)




    r=RptgenML.Root;
    e=r.getEditor;

    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(e);







    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_ComponentMaker:addNewPropertyTextLabel')),...
    'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','ComponentMakerData.png'),...
    'Callback',['addProperty(getCurrentTreeNode(RptgenML.Root),',...
    '''PropertyName'',''NewProperty'',',...
    '''DataTypeString'',''String'',',...
    '''FactoryValueString'',''''''default value'''''');'],...
    'StatusTip',getString(message('rptgen:RptgenML_ComponentMaker:addAsStringLabel'))));

    cm.addSeparator;

    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_ComponentMaker:buildComponentLabel')),...
    'Callback','build(getCurrentTreeNode(RptgenML.Root));',...
    'StatusTip',getString(message('rptgen:RptgenML_ComponentMaker:createCodeFilesLabel'))));

    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_ComponentMaker:editFilesLabel')),...
    'Enabled',locOnOff(viewAllFiles(this,-1)),...
    'Callback','viewAllFiles(getCurrentTreeNode(RptgenML.Root));',...
    'StatusTip',getString(message('rptgen:RptgenML_ComponentMaker:editAllCodeFilesLabel'))));

    cm.addMenuItem(r.actions.Close);

    cm.addSeparator;

    cm.addMenuItem(am.createDefaultAction(e,'CONTEXT_TREE_TO_WS'));


    function strVal=locOnOff(logVal)

        if logVal
            strVal='on';
        else
            strVal='off';
        end

