function resetall




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if isa(mdladvObj,'Simulink.ModelAdvisor')
        me=mdladvObj.MAExplorer;
        if isa(me,'DAStudio.Explorer')
            imme=DAStudio.imExplorer(me);
            selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
            modeladvisorprivate('modeladvisorutil2','ResetRoot',selectedNode);
        end
    end