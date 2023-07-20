function cutgui




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.ConfigUIWindow;
    if isa(me,'DAStudio.Explorer')
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        if~isa(selectedNode,'ModelAdvisor.ConfigUI')
            return
        end
        mdladvObj.ConfigUICopyObj=copytree(selectedNode);
        modeladvisorprivate('modeladvisorutil2','UpdatePasteMenuToolbar');
        ModelAdvisor.ConfigUI.stackoperation('push');
        selectedNode.deletetree;
    end
