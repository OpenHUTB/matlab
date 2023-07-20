function run




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.MAExplorer;
    if~isempty(me)
        imme=DAStudio.imExplorer(me);
        selectedNode=imme.getCurrentTreeNode;
        selectedNode.runTaskAdvisor;
    end
