function resetgui




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if isa(mdladvObj,'Simulink.ModelAdvisor')
        me=mdladvObj.MAExplorer;
        if isa(me,'DAStudio.Explorer')
            imme=DAStudio.imExplorer(me);
            selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
            if isempty(selectedNode.getParent)
                modeladvisorprivate('modeladvisorutil2','ResetRoot',selectedNode);
            else
                selectedNode.reset;
            end
        end
    end