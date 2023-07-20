function addElement(~)




    ed=Simulink.typeeditor.app.Editor.getInstance;
    st=ed.getStudio;
    curRoot=ed.getCurrentTreeNode{1};
    lc=ed.getListComp;
    curListNode=ed.getCurrentListNode;
    if isempty(curListNode)
        return;
    end
    elemPath=curListNode{1}.Path;
    pathStrs=split(elemPath,'.');
    parent=curRoot.find(pathStrs{1});

    ts=st.getToolStrip;
    if parent.IsConnectionType
        addElementAction=ts.getAction('addConnectionElementAction');
    else
        addElementAction=ts.getAction('addBusElementAction');
    end
    valid=addElementAction.enabled;

    readyMsg=DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg');

    if~isempty(st)&&valid
        if isempty(parent);return;end

        assert(parent.isHierarchical);

        addElementAction.enabled=false;

        addBusElementStatusMsg=DAStudio.message('Simulink:busEditor:BusEditorAddBusElementInProgressStatusMsg');
        st.setStatusBarMessage(addBusElementStatusMsg);

        childName=Simulink.typeeditor.utils.getUniqueChildName(parent);
        success=false;
        try
            parent.addChild(childName,true,false);
            success=true;
        catch ME
            Simulink.typeeditor.utils.reportError(ME.message);
        end
        if success
            lc.expand(parent,true);
            lc.view(parent.find(childName));
            curRoot.notifySLDDChanged;
            curRoot.refreshDataSourceChildren(parent.Name);
        else
            lc.view([]);
        end
        ed.update;
        st.setStatusBarMessage(readyMsg);
    end
