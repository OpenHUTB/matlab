function varargout=deselect





    success=false;

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.MAExplorer;
    if isa(me,'DAStudio.Explorer')
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        success=changeSelectionStatus(selectedNode,false);
        selectedNode.updateStates('refreshME');
        modeladvisorprivate('modeladvisorutil2','UpdateMEMenuToolbar',me);
    end

    if nargout>0
        varargout{1}=success;
    end
