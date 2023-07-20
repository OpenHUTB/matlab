classdef ComponentAnalyzer<handle



    properties
        AnalysisOptions Advisor.component.internal.AnalysisOptions;
        CreateSubHierarchy=true;
        CreateChecksumScopes=false;
        KeepModelsLoaded=true;
    end

    properties(SetAccess=private)
        AnalysisRoot Advisor.component.internal.AnalysisRoot;

        AbstractAnalysisRoot Advisor.component.internal.AnalysisRoot;
    end

    properties(Access=private)

        ComponentGraph Advisor.component.ComponentGraph;

        TemplatesMap containers.Map;
        ChecksumScope=struct('ChecksumScopeID',{},'Checksum',{},'RootComponentID',{});
        AbstractRootComponent;

        IsDemoModelRoot=false;
    end

    methods
        function this=ComponentAnalyzer()

            this.AnalysisOptions=Advisor.component.internal.AnalysisOptions();
            this.AnalysisOptions.ModelReferencesSimulationMode='AllModes';
            this.AnalysisOptions.AnalyzeLibraries=false;
            this.AnalysisRoot=Advisor.component.internal.AnalysisRoot();
            this.AbstractAnalysisRoot=Advisor.component.internal.AnalysisRoot();
            this.ComponentGraph=Advisor.component.ComponentGraph();
            this.TemplatesMap=containers.Map();
        end

        function templatesMap=getTemplatesMap(this)
            templatesMap=this.TemplatesMap;
        end



        function t=getTemplates(this,varargin)
            if isempty(varargin)
                tcell=this.TemplatesMap.values;
                t=[tcell{:}];
            else
                ids=varargin{1};

                if isstring(ids)
                    ids=ids.char;
                end
                if ischar(ids)
                    ids={ids};
                end

                t=Advisor.component.Template.empty(length(ids),0);

                for n=1:length(ids)
                    t(n)=this.TemplatesMap(ids{n});
                end
            end
        end

        function g=getComponentGraph(this)
            g=this.ComponentGraph;
        end

        function[checksumScopeIDs,checksums,rootComponentIDs]=getChecksumScope(this)
            if~isempty(this.ChecksumScope)
                checksumScope=this.ChecksumScope;
                checksumScopeIDs=cell(size(checksumScope));
                checksums=int64.empty(length(checksumScope),0);
                rootComponentIDs=cell(size(checksumScope));

                for n=1:length(checksumScope)
                    checksumScopeIDs{n}=checksumScope(n).ChecksumScopeID;
                    checksums(n)=checksumScope(n).Checksum;
                    rootComponentIDs{n}=checksumScope(n).RootComponentID;
                end
            else
                checksumScopeIDs={};
                checksums=[];
                rootComponentIDs={};
            end
        end
    end


    methods(Access=private)


        function analyzeSlGraph(this,rootHandle)
            sga=Advisor.component.internal.SimulinkGraphAnalyzer(...
            this.ComponentGraph,...
            this.TemplatesMap,...
            this.AnalysisOptions,...
            this.AnalysisRoot,...
            this.AbstractAnalysisRoot,...
            this.IsDemoModelRoot,...
            this.CreateChecksumScopes,...
            this.CreateSubHierarchy);

            sga.analyze(rootHandle);

            if this.CreateChecksumScopes
                this.ChecksumScope=[this.ChecksumScope,sga.getChecksumScopes()];
            end

            if this.AnalysisOptions.ModelReferencesSimulationMode~="None"
                childModels=sga.getChildModels();

                for N=1:length(childModels)
                    closeModel=false;
                    modelName=childModels(N).ModelName;

                    try
                        if this.ComponentGraph.isValidComponentID(modelName)

                        elseif~childModels(N).IsProtected
                            if~bdIsLoaded(modelName)
                                closeModel=true;
                                load_system(modelName);
                            end
                            this.analyzeSlGraph(get_param(modelName,'Handle'));

                        else
                            this.anaylzeProtectedModel(modelName);
                        end

                        this.linkModelComponent(childModels(N).ParentComponentID,...
                        modelName,childModels(N).SimulationMode);

                    catch E
                        if strcmp(E.identifier,'Simulink:utility:InvalidBlockDiagramName')||...
                            strcmp(E.identifier,'Simulink:Commands:OpenSystemUnknownSystem')








                        else
                            rethrow(E);
                        end
                    end

                    if closeModel&&~this.KeepModelsLoaded
                        close_system(modelName,0);
                    end
                end
            end
        end

        function component=anaylzeProtectedModel(this,modelName)
            component=...
            Advisor.component.internal.ComponentFactory.createProtectedModelComponent(modelName);

            this.ComponentGraph.addComponent(component);


            templateObj=Advisor.component.internal.TemplateFactory.createTemplate(component);

            if this.CreateChecksumScopes
                Advisor.component.internal.populateFileChecksum(templateObj);
                checksumScope=Advisor.component.internal.ChecksumScopeFactory.createChecksumScope(templateObj,component);
                component.ChecksumScopeID=checksumScope.ChecksumScopeID;
                this.ChecksumScope(end+1)=checksumScope;
            end

            this.TemplatesMap(templateObj.ID)=templateObj;

            component.TemplateID=templateObj.ID;
            templateObj.addInstance(component.ID);
        end


        function analyzeModelsOnly(this,rootHandle)
            [models,modelBlocks]=find_mdlrefs(rootHandle,'MatchFilter',@Simulink.match.allVariants,...
            'KeepModelsLoaded',this.KeepModelsLoaded,'IncludeProtectedModels',true);

            assert(iscell(modelBlocks));
            assert(iscell(models));

            isSubHierarchyRoot=this.AnalysisRoot.isSubHierarchyRoot();


            for N=1:length(models)
                if isSubHierarchyRoot&&strcmp(models{N},this.AbstractAnalysisRoot.ComponentID)


                else


                    [~,modelName,ext]=fileparts(models{N});

                    if isempty(ext)
                        component=Advisor.component.internal.ComponentFactory.createSlComponent(get_param(modelName,'Object'),[]);
                        template=Advisor.component.internal.TemplateFactory.createTemplate(component);

                        if Advisor.component.isMWFile(template.File)&&~this.IsDemoModelRoot
                            continue
                        end

                        if this.CreateChecksumScopes
                            Advisor.component.internal.populateFileChecksum(template);
                            checksumScope=Advisor.component.internal.ChecksumScopeFactory.createChecksumScope(template,component);
                            component.ChecksumScopeID=checksumScope.ChecksumScopeID;
                            this.ChecksumScope(end+1)=checksumScope;
                        end

                        this.TemplatesMap(template.ID)=template;

                        component.TemplateID=template.ID;
                        template.addInstance(component.ID);

                        this.ComponentGraph.addComponent(component);
                    else
                        this.anaylzeProtectedModel(modelName);
                    end
                end
            end


            for N=1:length(modelBlocks)
                parentModelName=strtok(modelBlocks{N},'/');

                if isSubHierarchyRoot&&strcmp(parentModelName,this.AbstractAnalysisRoot.ComponentID)
                    parentComponentID=this.AnalysisRoot.ComponentID;
                else
                    parentComponentID=parentModelName;
                end

                modelBlockObj=get_param(modelBlocks{N},'Object');

                if strcmp(modelBlockObj.Variant,'off')
                    isProtected=strcmp(modelBlockObj.ProtectedModel,'on');

                    if~isProtected
                        childModelName=modelBlockObj.ModelName;
                    else
                        [~,childModelName]=fileparts(modelBlockObj.ModelFile);
                    end

                    simulationMode=...
                    Advisor.component.internal.getSimulationMode(...
                    modelBlockObj.SimulationMode);

                    analyzeFlag=true;

                    if this.AnalysisOptions.ModelReferencesSimulationMode=="NormalModeOnly"
                        if(strcmp(simulationMode,'Normal')==0)
                            analyzeFlag=false;
                        end
                    end


                    if analyzeFlag
                        this.linkModelComponent(parentComponentID,...
                        childModelName,simulationMode);
                    end

                else
                    for n=1:length(modelBlockObj.Variants)
                        variant=modelBlockObj.Variants(n);

                        if isprop(variant,'ProtectedModel')&&strcmp(variant.ProtectedModel,'on')
                            [~,childModelName,~]=fileparts(variant.ModelFile);
                        else
                            [~,childModelName,~]=fileparts(variant.ModelName);
                        end

                        simulationMode=...
                        Advisor.component.internal.getSimulationMode(...
                        modelBlockObj.SimulationMode);

                        analyzeFlag=true;

                        if this.AnalysisOptions.ModelReferencesSimulationMode=="NormalModeOnly"
                            if(strcmp(simulationMode,'Normal')==0)
                                analyzeFlag=false;
                            end
                        end

                        if analyzeFlag
                            this.linkModelComponent(parentComponentID,...
                            childModelName,simulationMode);
                        end
                    end
                end
            end
        end

        function linkModelComponent(this,parentComponentID,childComponentID,simMode)
            rel=Advisor.component.Relationship(...
            parentComponentID,childComponentID,...
            Advisor.component.RelationshipType.ObjectReference);

            rel.SimulationMode=simMode;

            this.ComponentGraph.addComponentRelationship(rel);
        end
    end

    methods(Static)
        function handle=getRootHandle(root)
            switch root.ComponentType
            case Advisor.component.Types.Model
                handle=Simulink.ID.getHandle(root.ComponentID);

            case{Advisor.component.Types.SubSystem,...
                Advisor.component.Types.Chart,...
                Advisor.component.Types.MATLABFunction}

                if Advisor.component.internal.isStateflowLibraryInstanceComponentID(root.ComponentID)
                    handle=Simulink.ID.getHandle(...
                    Advisor.component.internal.getContextSID(root.ComponentID));
                else
                    handle=Simulink.ID.getHandle(root.ComponentID);
                end
            otherwise
                error('Unsupported root type');
            end

        end
    end
end

