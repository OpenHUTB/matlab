



function initComponentManager(this)
    if isempty(this.ComponentManager)
        this.ComponentManager=Advisor.component.ComponentManager(...
        'Selected',false,'NumFailures',0,'NumWarnings',0);


        this.ComponentManager.CloseModels=false;
        this.ComponentManager.ModelReferencesSimulationMode="AllModes";

        this.ComponentManager.AnalyzeLibraries=this.AnalyzeLibraries;
    end


    if this.AnalysisRootType==Advisor.component.Types.SubSystem
        this.ComponentManager.CreateSubHierarchy=true;
    else
        this.ComponentManager.CreateSubHierarchy=false;
    end


    this.ComponentManager.setAnalysisRoot(this.AnalysisRoot,this.AnalysisRootType);
end