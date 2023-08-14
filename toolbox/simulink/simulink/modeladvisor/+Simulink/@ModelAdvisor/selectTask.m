function success=selectTask(this,taskNameArray)








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

        found=loc_findAndSelectNode(this,taskName);

        if~found
            newID=ModelAdvisor.internal.resolveModelAdvisorTreeNodeID(taskName);

            if~isempty(newID)
                found=loc_findAndSelectNode(this,newID);
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

function success=loc_findAndSelectNode(this,taskName)
    success=false;
    for j=1:length(this.TaskCellarray)
        if strcmp(taskName,this.TaskCellArray{j}.ID)||strcmp(['_SYSTEM_By Task_',taskName],this.TaskCellArray{j}.ID)
            if this.updateTask(j,true)
                success=true;
            end
            break
        end
    end
end