







function deleteObj(this)


    if this.runInBackground&&ModelAdvisor.isRunning
        parallelRun=ModelAdvisor.ParallelRun.getInstance();
        parallelRun.cancelRun();
    end

    if isa(this.ListExplorer,'DAStudio.Explorer')
        this.ListExplorer.delete;
    end

    if isa(this.RPObj,'ModelAdvisor.RestorePoint')
        this.RPObj.delete;
    end

    if isa(this.MAExplorer,'DAStudio.Explorer')

        this.closeExplorer;
        this.MAExplorer.delete();
    end

    if~isempty(this.AdvisorWindow)&&isa(this.AdvisorWindow,'Advisor.AdvisorWindow')
        this.AdvisorWindow.close();
    end

    if this.SessionDataHasBeenSaved
        modeladvisorprivate('modeladvisorutil2','SaveTaskAdvisorMiniInfo',this);
    else
        if isa(this,'Simulink.ModelAdvisor')&&isa(this.Database,'ModelAdvisor.Repository')
            if exist(this.Database.FileLocation,'file')
                this.Database.saveMASessionData;
            end
        end
    end

    if isfield(this.AtticData,'saveMAReportData')&&~isempty(this.AtticData.saveMAReportData)
        if exist(this.Database.FileLocation,'file')
            this.Database.saveMAReportData(this.AtticData.saveMAReportData);
        end
    end
    if isfield(this.AtticData,'saveMAGeninfoData')&&~isempty(this.AtticData.saveMAGeninfoData)
        if exist(this.Database.FileLocation,'file')
            this.Database.saveMAGeninfoData(this.AtticData.saveMAGeninfoData{:});
        end
    end





    if isa(this.Database,'ModelAdvisor.Repository')
        delete(this.Database);
    end

    ta=this.TaskAdvisorCellArray;
    for j=1:length(ta)
        if isvalid(ta{j})

            ta{j}.delete;
        end
    end


    ta=this.ConfigUICellArray;
    if~isempty(ta)&&~isstruct(ta{1})
        for j=1:length(ta)
            if isvalid(ta{j})

                ta{j}.MAObj=[];
            end
        end
    end

    ta=this.CheckLibrary;
    for j=1:length(ta)
        if isvalid(ta{j})

            ta{j}.MAObj=[];
        end
    end

    this.CheckCellArray={};
    this.TaskCellArray={};





    this.ConfigUIRoot={};
    this.ConfigUICellArray={};
    this.ConfigFilePath='';

    if isa(this.CheckLibraryBrowser,'DAStudio.Explorer')
        this.CheckLibraryBrowser.delete;
    end


    modeladvisorprivate('modeladvisorutil2','CleanWarnErrorDlgs',this);


    Simulink.ModelAdvisor.getActiveModelAdvisorObj([]);

end