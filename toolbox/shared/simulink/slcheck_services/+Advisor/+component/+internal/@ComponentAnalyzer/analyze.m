function analyze(this)



    assert(strcmp(this.AbstractAnalysisRoot.File,this.AnalysisRoot.File),...
    'Abstract root and actual root have to point to the same file.');

    this.TemplatesMap=containers.Map();
    this.ComponentGraph=Advisor.component.ComponentGraph();
    this.IsDemoModelRoot=false;
    this.ChecksumScope=struct('ChecksumScopeID',{},'Checksum',{},'RootComponentID',{});


    if Advisor.component.isMWFile(this.AnalysisRoot.File)
        this.IsDemoModelRoot=true;
    end

    if this.AnalysisRoot.isSubHierarchyRoot()

        mdlObj=get_param(this.AbstractAnalysisRoot.ComponentID,'Object');

        this.AbstractRootComponent=...
        Advisor.component.internal.ComponentFactory.createSlComponent(mdlObj,[]);

        rootTemplate=Advisor.component.internal.TemplateFactory.createTemplate(this.AbstractRootComponent);

        if this.CreateChecksumScopes
            Advisor.component.internal.populateFileChecksum(rootTemplate);
        end

        this.TemplatesMap(rootTemplate.ID)=rootTemplate;

        this.AbstractRootComponent.TemplateID=rootTemplate.ID;




    end




    rootHandle=Advisor.component.internal.ComponentAnalyzer.getRootHandle(this.AnalysisRoot);

    if((this.AnalysisOptions.ModelReferencesSimulationMode~="None")&&...
        ~this.AnalysisOptions.AnalyzeLibraries&&...
        ~this.CreateSubHierarchy)

        this.analyzeModelsOnly(rootHandle);
    else
        this.analyzeSlGraph(rootHandle);
    end

    this.ComponentGraph.detectCycles();

    if~this.AnalysisRoot.isSubHierarchyRoot()
        this.AbstractRootComponent=this.ComponentGraph.getComponent(this.AnalysisRoot.ComponentID);
    end
end