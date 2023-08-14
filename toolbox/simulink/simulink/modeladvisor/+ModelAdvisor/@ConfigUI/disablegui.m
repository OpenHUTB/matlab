function disablegui




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.ConfigUIWindow;
    if isa(me,'DAStudio.Explorer')
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        if~isa(selectedNode,'ModelAdvisor.ConfigUI')
            return
        end
        ModelAdvisor.ConfigUI.stackoperation('push');
        selectedNode.changeEnableStatus(false);
    end
