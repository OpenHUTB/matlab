function success=deselect





    success=false;

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.MAExplorer;
    if~isempty(me)
        imme=DAStudio.imExplorer(me);
        selectedNode=imme.getCurrentTreeNode;
        success=changeSelectionStatus(selectedNode,false);
        selectedNode.updateStates('refreshME');
        modeladvisorprivate('modeladvisorutil2','UpdateMEMenuToolbar',me);
    end
