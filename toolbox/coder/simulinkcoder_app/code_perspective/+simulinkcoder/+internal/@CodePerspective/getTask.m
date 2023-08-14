function task=getTask(obj,id)


    task=[];
    tasks=obj.tasks;
    for i=1:length(tasks)
        t=tasks{i};
        if strcmp(id,t.ID)
            task=t;
            return;
        end
    end


