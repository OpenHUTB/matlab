







function success=loadConfiguration(this,configFile)





















    if strcmp(this.AnalysisRoot,'empty')
        DAStudio.error('Advisor:base:App_NotInitialized');
    end



    success=true;

    if~isempty(configFile)
        if~ischar(configFile)
            success=false;
        end

        [~,~,ext]=fileparts(configFile);

        if isempty(ext)
            configFile=[configFile,'.mat'];
        end

        if~exist(configFile,'file')
            success=false;
        end
    end



    if success
        if this.TaskManager.IsInitialized

            this.TaskManager.clearResults();

            this.TaskManager.initialize(...
            this.AnalysisRootComponentId,configFile);


            if~isempty(this.RootMAObj)
                this.deleteMAObjs();
                this.MAObjs=[];
            end

            this.updateModelAdvisorObj(this.AnalysisRootComponentId,true);
        else


            this.TaskManager.initialize(...
            this.AnalysisRootComponentId,configFile);
        end
    else
        DAStudio.error('Simulink:tools:MAInvalidConfigFile',configFile);
    end
end