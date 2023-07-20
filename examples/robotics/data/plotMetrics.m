function plotMetrics(f1,f2,f3,agentData,taskData)
    persistent oldTaskStatusTable oldAgentStatusTable oldAssignedTaskTable
    if isempty(oldTaskStatusTable)
        oldTaskStatusTable=strings(length(taskData),2);
    end
    if isempty(oldAgentStatusTable)
        oldAgentStatusTable=strings(length(agentData),2);
    end
    if isempty(oldAssignedTaskTable)
        oldAssignedTaskTable=strings(length(agentData),2);
    end

    taskIds=(1:length(taskData))';
    statusEntries=strings(size(taskData));
    for ii=1:length(taskData)
        switch taskData(ii).Status
        case TaskStatus.Unassigned
            statusEntries(ii)="Unassigned";
        case TaskStatus.Assigned
            statusEntries(ii)="Assigned";
        case TaskStatus.InProgress
            statusEntries(ii)="In Progress";
        case TaskStatus.Complete
            statusEntries(ii)="Complete";
        case TaskStatus.Cancelled
            statusEntries(ii)="Cancelled";
        end
    end
    taskStatusTable=table(taskIds,statusEntries,'VariableNames',{'Task Id','Task Status'});
    agentIds=(1:length(agentData))';
    statusEntries=strings(size(agentData));
    for ii=1:length(agentData)
        switch agentData(ii).Status
        case AgentStatus.Available
            statusEntries(ii)="Available";
        case AgentStatus.Busy
            statusEntries(ii)="Busy";
        case AgentStatus.Idle
            statusEntries(ii)="Idle";
        case AgentStatus.Broken
            statusEntries(ii)="Broken";
        end
    end
    agentStatusTable=table(agentIds,statusEntries,'VariableNames',{'Agent Id','Agent Status'});
    assignedTaskIds=strings(size(agentData));
    for ii=1:length(agentData)
        if agentData(ii).TaskId~=0
            assignedTaskIds(ii)=num2str(agentData(ii).TaskId);
        else
            assignedTaskIds(ii)="Unassigned";
        end
    end
    assignedTaskTable=table(agentIds,assignedTaskIds,'VariableNames',{'Agent Id','Assigned Task Id'});
    if any(taskStatusTable.Variables~=oldTaskStatusTable,'all')
        h=heatmap(taskStatusTable,'Task Id','Task Status','Parent',f1,'Title','Task Status Metrics');
        statusNames={'Unassigned','Assigned','In Progress','Complete','Cancelled'};
        h.SourceTable.("Task Status")=categorical(h.SourceTable.("Task Status"));
        h.SourceTable.("Task Status")=addcats(h.SourceTable.("Task Status"),statusNames);
        h.SourceTable.("Task Status")=reordercats(h.SourceTable.("Task Status"),statusNames);
        h.ColorbarVisible=false;
        h.CellLabelColor='none';
        drawnow;
        oldTaskStatusTable=taskStatusTable.Variables;
    end
    if any(agentStatusTable.Variables~=oldAgentStatusTable,'all')
        h=heatmap(agentStatusTable,'Agent Id','Agent Status','Parent',f2,'Title','Agent Status Metrics');
        statusNames={'Available','Busy','Idle','Broken'};
        h.SourceTable.("Agent Status")=categorical(h.SourceTable.("Agent Status"));
        h.SourceTable.("Agent Status")=addcats(h.SourceTable.("Agent Status"),statusNames);
        h.SourceTable.("Agent Status")=reordercats(h.SourceTable.("Agent Status"),statusNames);
        h.ColorbarVisible=false;
        h.CellLabelColor='none';
        drawnow;
        oldAgentStatusTable=agentStatusTable.Variables;
    end
    if any(assignedTaskTable.Variables~=oldAssignedTaskTable,'all')
        h=heatmap(assignedTaskTable,'Agent Id','Assigned Task Id','Parent',f3,'Title','Task Assignment Map');
        taskIds=flip(["Unassigned",num2cell(1:length(taskData))]);
        h.SourceTable.("Assigned Task Id")=categorical(h.SourceTable.("Assigned Task Id"));
        h.SourceTable.("Assigned Task Id")=addcats(h.SourceTable.("Assigned Task Id"),taskIds);
        h.SourceTable.("Assigned Task Id")=reordercats(h.SourceTable.("Assigned Task Id"),taskIds);
        h.ColorbarVisible=false;
        h.CellLabelColor='none';
        drawnow;
        oldAssignedTaskTable=agentStatusTable.Variables;
    end
end