function opencsh




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.MAExplorer;
    if~isempty(me)
        imme=DAStudio.imExplorer(me);
        selectedNode=imme.getCurrentTreeNode;
        if~isempty(selectedNode.CSHParameters)
            if isfield(selectedNode.CSHParameters,'MapKey')&&...
                isfield(selectedNode.CSHParameters,'TopicID')
                mapkey=['mapkey:',selectedNode.CSHParameters.MapKey];
                topicid=selectedNode.CSHParameters.TopicID;
                helpview(mapkey,topicid,'CSHelpWindow');
            end
        end
    end
