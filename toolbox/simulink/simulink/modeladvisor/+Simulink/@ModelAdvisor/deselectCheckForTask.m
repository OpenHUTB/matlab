function success=deselectCheckForTask(this,taskNameArray)




    if ischar(taskNameArray)

        taskNameArray={taskNameArray};
    end

    try
        success=true;

        allTaskNameArray=this.getTaskAll;
        if~isempty(setdiff(taskNameArray,allTaskNameArray))
            success=false;
        end


        for i=1:length(this.TaskCellArray)
            if ismember(this.TaskCellArray{i}.ID,taskNameArray)
                for j=1:length(this.TaskCellArray{i}.CheckIndex)
                    recordSerialNum=str2double(this.TaskCellArray{i}.CheckIndex{j});

                    if~this.updateCheckForTask(recordSerialNum,false)
                        success=false;
                    end
                end
            end
        end
    catch E
        success=false;
        rethrow(E);
    end

