




function analyzeDependencies(this)

    if isempty(this.AnalysisRoot)
        DAStudio.error('Advisor:base:Components_AnalysisRootNotSet');
    else

        modelName=this.AbstractRootID;
        if isstring(modelName)
            modelName=char(modelName);
        end
        if Simulink.harness.isHarnessBD(modelName)&&...
            ~this.SingleComponentMode
            DAStudio.error('Advisor:base:Components_HarnessRootNotSupported');
        end
    end


    if this.CloseModels
        openModelsBefore=find_system('type','block_diagram');
    end



    mergeRequired=false;

    if~isempty(this.ExternalPropertyNames)&&this.Templates.length>0
        mergeRequired=true;
        extProperties=this.ExternalProperties;
    end


    this.Templates=containers.Map('KeyType','char','ValueType','any');
    this.ComponentGraph.clear();
    this.ByTypeCache=containers.Map('KeyType','double','ValueType','any');


    try
        PerfTools.Tracer.logMATLABData('ComponentManager','Dependency engine Analyze()',true);

        analyzer=Advisor.component.internal.ComponentAnalyzer();
        analyzer.KeepModelsLoaded=~this.CloseModels;


        if(this.ModelReferencesSimulationMode=="AllModes")
            analyzer.AnalysisOptions.ModelReferencesSimulationMode="AllModes";
        elseif(this.ModelReferencesSimulationMode=="NormalModeOnly")
            analyzer.AnalysisOptions.ModelReferencesSimulationMode="NormalModeOnly";
        else
            analyzer.AnalysisOptions.ModelReferencesSimulationMode="None";
        end
        analyzer.AnalysisOptions.AnalyzeLibraries=this.AnalyzeLibraries;

        analyzer.CreateSubHierarchy=this.CreateSubHierarchy;

        root=Advisor.component.internal.AnalysisRoot();

        root.ComponentID=this.AnalysisRootComponentID;
        root.Name=this.AnalysisRoot;
        root.ComponentType=this.AnalysisRootType;
        root.File=this.AnalysisRootFile;

        analyzer.setAnalysisRoot(root);

        analyzer.analyze();

        PerfTools.Tracer.logMATLABData('ComponentManager','Dependency engine Analyze()',false);

        if this.CloseModels
            openModelsAfter=find_system('type','block_diagram');
            modelsToClose=setdiff(openModelsAfter,openModelsBefore);

            for n=1:length(modelsToClose)
                if bdIsLoaded(modelsToClose{n})
                    close_system(modelsToClose{n});
                end
            end
        end

        this.ComponentGraph=analyzer.getComponentGraph();
        this.Templates=analyzer.getTemplatesMap();


        PerfTools.Tracer.logMATLABData('ComponentManager','loc_createCaches',true);
        createCaches(this);
        PerfTools.Tracer.logMATLABData('ComponentManager','loc_createCaches',false);


        initExternalProperties(this);


        if mergeRequired
            oldNumComps=size(extProperties,1);
            oldCompIDs=extProperties.Properties.RowNames;

            for n=1:oldNumComps
                if this.existComponent(oldCompIDs{n})
                    this.ExternalProperties(oldCompIDs{n},:)=extProperties(oldCompIDs{n},:);
                end
            end
        end


        this.IsInitialized=true;
        this.IsDirty=false;

    catch except

        this.Templates=containers.Map('KeyType','char','ValueType','any');
        this.ComponentGraph.clear();
        this.ByTypeCache=containers.Map('KeyType','double','ValueType','any');

        this.IsInitialized=false;
        this.IsDirty=false;

        except.rethrow();
    end

end


