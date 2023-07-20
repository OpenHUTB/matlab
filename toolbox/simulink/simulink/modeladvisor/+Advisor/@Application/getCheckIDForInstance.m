function checkID=getCheckIDForInstance(this,checkInstanceID)




    checkID='';


    if strcmp(this.AnalysisRoot,'empty')
        DAStudio.error('Advisor:base:App_NotInitialized');
    end


    if~this.TaskManager.IsInitialized
        this.TaskManager.initialize(this.AnalysisRootComponentId);
    end

    if isempty(this.RootMAObj)

        [~,status]=this.updateModelAdvisorObj(this.AnalysisRootComponentId,true);

        if status==1

            return;
        end
    end

    task=this.RootMAObj.getTaskObj(checkInstanceID);
    checkID=task.Check.ID;
end

