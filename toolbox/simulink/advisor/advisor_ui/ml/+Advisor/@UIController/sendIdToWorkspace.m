function result=sendIdToWorkspace(this,taskId,IdType)
    result={};

    if(strcmp(taskId,'_SYSTEM'))
        taskObj=this.maObj.TaskAdvisorRoot;
    else
        taskObj=this.maObj.getTaskObj(taskId);
    end
    if strcmp(IdType,'CheckID')
        if isa(taskObj,'ModelAdvisor.Task')
            result{end+1}=taskObj.Check.ID;
        end
    elseif strcmp(IdType,'InstanceID')
        result{end+1}=taskId;
    else
        error('Wrong ID Type');
    end
    result=gatherIds(taskObj,result,IdType);
    ans=result;%#ok<NOANS>
    ans %#ok<NOANS,NOPRT>
    assignin("base",'ans',result);
end

function IdSet=gatherIds(startNode,IdSet,IdType)
    children=startNode.getChildren();
    for i=1:numel(children)
        if strcmp(IdType,'CheckID')
            if isa(children(i),'ModelAdvisor.Task')
                IdSet{end+1}=children(i).Check.ID;
            end
        elseif strcmp(IdType,'InstanceID')
            IdSet{end+1}=children(i).ID;
        else
            error('Wrong ID Type');
        end

        if~isempty(children(i).getChildren())
            IdSet=gatherIds(children(i),IdSet,IdType);
        end
    end
end