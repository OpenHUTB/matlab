function addType(objType,~)





    ed=Simulink.typeeditor.app.Editor.getInstance;

    switch objType
    case 'Bus'
        actionName='addBusAction';
    case 'ConnectionBus'
        actionName='addConnectionBusAction';
    case 'AliasType'
        actionName='addAliasTypeAction';
    case 'NumericType'
        actionName='addNumericTypeAction';
    case 'ValueType'
        actionName='addValueTypeAction';
    case 'data.dictionary.EnumTypeDefinition'
        actionName='addEnumTypeAction';
    otherwise
        assert(false);
        return;
    end
    classType=['Simulink.',objType];

    st=ed.getStudio;


    ts=st.getToolStrip;
    addTypeAction=ts.getAction(actionName);
    valid=addTypeAction.enabled;

    readyMsg=DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg');

    if~isempty(st)&&valid
        addTypeAction.enabled=false;
        newParent=ed.getCurrentTreeNode{1};
        try
            childName=Simulink.typeeditor.utils.getUniqueChildName({newParent,classType});
            newParent.NodeDataAccessor.createVariableAsLocalData(childName,eval(classType));%#ok<EVLDOT>
            addBusStatusMsg=DAStudio.message('Simulink:busEditor:BusEditorAddBusInProgressStatusMsg',childName,['''',newParent.Name,'''']);
            st.setStatusBarMessage(addBusStatusMsg);
            newParent.insertNode({childName});
            nodeToSelect=Simulink.typeeditor.utils.getNodeFromPath(newParent,childName);
            newParent.notifySLDDChanged;
            ed.getListComp.update(true);
            ed.getListComp.view(nodeToSelect);
            st.setStatusBarMessage(readyMsg);
            addTypeAction.enabled=true;
            ed.update;
        catch ME
            ed.getTreeComp.setSource(ed.getSource);
            ed.getTreeComp.view(ed.getBaseRoot);
            st.setStatusBarMessage(readyMsg);
            rethrow(ME);
        end
    end