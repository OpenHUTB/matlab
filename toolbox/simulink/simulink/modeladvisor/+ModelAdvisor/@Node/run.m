function run




    mdladvObj=Simulink.ModelAdvisor.getFocusModelAdvisorObj;
    if(isempty(mdladvObj))
        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    end

    if isa(mdladvObj,'Simulink.ModelAdvisor')
        me=mdladvObj.MAExplorer;
        if isa(me,'DAStudio.Explorer')
            imme=DAStudio.imExplorer(me);
            selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
            if~isempty(strfind(selectedNode.ID,'PerformanceAdvisor'))
                selectedNode.runTaskAdvisorWrapper;
            else
                selectedNode.runTaskAdvisor;
            end
        end
    end
