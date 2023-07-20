function[status,systemSIDs]=getStatusForTask(this,taskID)






    maObjs=this.getMAObjs();






    status=repmat(uint8(3),size(maObjs,1),size(maObjs,2));
    systemSIDs=cell(size(maObjs));

    if~isempty(maObjs)
        taskObj=maObjs{1}.getTaskObj(taskID);
        if isempty(taskObj)
            return
        else
            taskIndex=taskObj.Index;
        end

        for i=1:length(maObjs)
            task=maObjs{i}.TaskAdvisorCellArray{taskIndex};

            if task.RunTime~=0
                checkobj=task.Check;

                if checkobj.status<ModelAdvisor.CheckStatus.Warning
                    status(i)=uint8(1);
                elseif checkobj.status==ModelAdvisor.CheckStatus.Warning
                    status(i)=uint8(2);
                else
                    status(i)=uint8(3);
                end
            end
            systemSIDs{i}=Simulink.ID.getSID(maObjs{i}.SystemName);
        end
    end
end

