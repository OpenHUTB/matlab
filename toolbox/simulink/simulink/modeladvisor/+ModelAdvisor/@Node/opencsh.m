function opencsh




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.MAExplorer;
    if isa(me,'DAStudio.Explorer')
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        if isa(selectedNode,'ModelAdvisor.Node')&&~isempty(selectedNode.CSHParameters)
            if isfield(selectedNode.CSHParameters,'MapKey')&&...
                isfield(selectedNode.CSHParameters,'TopicID')
                mapkey=['mapkey:',selectedNode.CSHParameters.MapKey];
                topicid=selectedNode.CSHParameters.TopicID;
                helpview(mapkey,topicid,'CSHelpWindow');
            end
        end
    end
