function varargout=select





    success=false;

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.MAExplorer;
    if isa(me,'DAStudio.Explorer')
        imme=DAStudio.imExplorer(me);
        currentlySelectedTreeNode=imme.getCurrentTreeNode();

        if~isempty(currentlySelectedTreeNode)
            selectedNode=Advisor.Utils.convertMCOS(currentlySelectedTreeNode);



            success=changeSelectionStatus(selectedNode,true);
            selectedNode.updateStates('refreshME');
            modeladvisorprivate('modeladvisorutil2','UpdateMEMenuToolbar',me);
        end
    end

    if nargout>0
        varargout{1}=success;
    end
