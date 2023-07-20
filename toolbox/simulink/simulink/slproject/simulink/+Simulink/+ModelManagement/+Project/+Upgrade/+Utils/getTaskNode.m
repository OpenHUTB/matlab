function node=getTaskNode(tasks,taskID)

    for n=1:length(tasks)
        if strcmp(tasks{n}.ID,taskID)
            node=tasks{n};
            return
        end
    end
    node=[];
end