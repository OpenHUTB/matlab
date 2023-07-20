function success=deselectTask(this,taskNameArray)




    success=false;

    selectCount=0;
    if ischar(taskNameArray)
        if isempty(taskNameArray)
            taskNameArray={};
        else

            taskNameArray={taskNameArray};
        end
    end

    for i=1:length(taskNameArray)
        taskName=taskNameArray{i};

        found=loc_findAndDeselectNode(this,taskName);

        if~found
            newID=ModelAdvisor.internal.resolveModelAdvisorTreeNodeID(taskName);

            if~isempty(newID)
                found=loc_findAndDeselectNode(this,newID);
            end
        end

        if found
            selectCount=selectCount+1;
        end
    end

    if selectCount==length(taskNameArray)
        success=true;
    end
end

function success=loc_findAndDeselectNode(this,taskName)
    success=false;
    for j=1:length(this.TaskCellarray)
        if strcmp(taskName,this.TaskCellarray{j}.ID)||strcmp(['_SYSTEM_By Task_',taskName],this.TaskCellarray{j}.ID)
            if this.updateTask(j,false)
                success=true;
            end
            break
        end
    end
end