function result=openCSH(this,taskID)
    result=[];
    if isempty(taskID)||strcmp(taskID,'_SYSTEM')
        modeladvisor('help');
        return;
    end

    selectedNode=this.maObj.getTaskObj(taskID);



    if isempty(selectedNode.CSHParameters)&&~isempty(selectedNode.check)
        selectedNode.CSHParameters=selectedNode.check.CSHParameters;
    end

    if isa(selectedNode,'ModelAdvisor.Node')&&~isempty(selectedNode.CSHParameters)
        if isfield(selectedNode.CSHParameters,'MapKey')&&...
            isfield(selectedNode.CSHParameters,'TopicID')
            mapkey=['mapkey:',selectedNode.CSHParameters.MapKey];
            topicid=selectedNode.CSHParameters.TopicID;
            helpview(mapkey,topicid,'CSHelpWindow');


            Simulink.DDUX.logData('TASK_HELP','mapkey',mapkey,'topicid',topicid);
        elseif isfield(selectedNode.CSHParameters,'webpage')
            selectedNode.launchCustomHelp;
        end
    end

end