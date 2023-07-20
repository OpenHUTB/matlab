



function initializeExternally(this,root,abstractRoot,options,createSubHierarchy,...
    graph,templates)

    this.CloseModels=false;
    this.CreateSubHierarchy=createSubHierarchy;

    this.AnalyzeLibraries=options.AnalyzeLibraries;
    this.ModelReferencesSimulationMode=options.ModelReferencesSimulationMode;
    this.AnalyzeMFiles=false;

    this.AnalysisRoot=root.Name;
    this.AnalysisRootFile=root.File;
    this.AnalysisRootComponentID=root.ComponentID;
    this.AnalysisRootType=root.ComponentType;

    this.AbstractRootID=abstractRoot.ComponentID;
    this.AbstractRootIDType=abstractRoot.ComponentType;


    this.Templates=containers.Map();
    for t=templates
        this.Templates(t.ID)=t;
    end

    this.ComponentGraph=graph;

    this.createCaches();


    this.initExternalProperties();

    this.IsDirty=false;

    this.IsInitialized=true;

end