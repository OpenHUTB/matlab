function result=setSelectionStatus(this,instanceID,newValue)

    if strcmp(instanceID,'_SYSTEM')
        result=this.maObj.TaskAdvisorRoot.changeSelectionStatus(newValue);
        return;
    end

    taskObj=this.maObj.getTaskObj(instanceID);
    if isempty(taskObj)
        result=false;
        return;
    end

    result=taskObj.changeSelectionStatus(newValue);

end