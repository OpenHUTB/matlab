function continuerun




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if isa(mdladvObj,'Simulink.ModelAdvisor')
        me=mdladvObj.MAExplorer;
        if isa(me,'DAStudio.Explorer')
            imme=DAStudio.imExplorer(me);
            selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
            selectedNode.runContinue;
        end
    end