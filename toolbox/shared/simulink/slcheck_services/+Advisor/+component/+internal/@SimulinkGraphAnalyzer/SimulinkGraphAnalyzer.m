classdef SimulinkGraphAnalyzer<handle



    properties

    end

    properties(SetAccess=private)
        AnalysisRoot=Advisor.component.internal.AnalysisRoot;
        AbstractAnalysisRoot=Advisor.component.internal.AnalysisRoot;
        AnalysisOptions=Advisor.component.internal.AnalysisOptions;
        CreateSubHierarchy=true;
        CreateChecksumScopes=false;
        IsDemoModelRoot=false;
    end

    properties(Access=private)
        ComponentGraph;
        TemplatesMap=containers.Map();
        ChecksumScope=struct('ChecksumScopeID',{},'Checksum',{},'RootComponentID',{});
        DG;
        NodeHandles;
        ChecksumStack={};
        ComponentStack={};
        ChildModels=struct('ParentComponentID',{},'SimulationMode',{},...
        'ModelName',{},'IsProtected',{});

    end

    methods
        function this=SimulinkGraphAnalyzer(cg,tm,ao,ar,aar,...
            isDemoModelRoot,...
            createChecksumScopes,createSubHierarchy)

            this.ComponentGraph=cg;
            this.TemplatesMap=tm;
            this.AnalysisOptions=ao;
            this.AnalysisRoot=ar;
            this.AbstractAnalysisRoot=aar;
            this.CreateSubHierarchy=createSubHierarchy;
            this.CreateChecksumScopes=createChecksumScopes;
            this.IsDemoModelRoot=isDemoModelRoot;
        end

        function tm=getTemplateMap(this)
            tm=this.TemplatesMap;
        end

        function cs=getChecksumScopes(this)
            cs=this.ChecksumScope;
        end

        function cg=getComponentGraph(this)
            cg=this.ComponentGraph;
        end

        function cm=getChildModels(this)
            cm=this.ChildModels;
        end

        function analyze(this,graphRootHandle)
            this.ChecksumStack={};
            this.ComponentStack={};

            rootHandle=bdroot(graphRootHandle);
            dg=Advisor.component.internal.extractBDHierarchyGraph(rootHandle,this.IsDemoModelRoot);
            nodeHandles=dg.Nodes.Handle;

            if~isempty(nodeHandles)
                this.DG=dg;
                this.NodeHandles=this.DG.Nodes.Handle;

                startnode=find(this.NodeHandles==graphRootHandle);
                visit(this,startnode);
            else


                assert(rootHandle==graphRootHandle);
                obj=get_param(rootHandle,'Object');

                [stopTraversal,~,component]=this.preOrderVisit(obj,[]);

                if~stopTraversal
                    this.postOrderVisit(component);
                end
            end
        end
    end

    methods(Access=private)
        function visit(this,nodeID)
            blkHandle=this.NodeHandles(nodeID);
            slObj=get_param(blkHandle,'Object');

            if isa(slObj,'Simulink.BlockDiagram')||...
                (isa(slObj,'Simulink.SubSystem')&&strcmpi(slObj.Commented,'off'))

                [compObj,context]=...
                Advisor.component.internal.Object2ComponentID.resolveObject(slObj);

                if Advisor.component.internal.Object2ComponentID.isComponent(compObj)&&...
                    ~Advisor.component.internal.SimulinkGraphAnalyzer.isCommented(compObj,context)

                    [stopTraversal,skip,component]=this.visitComponentObj(compObj,context);

                    if~stopTraversal

                        [~,endNodesIDs]=this.DG.outedges(nodeID);

                        for N=1:size(endNodesIDs,1)
                            this.visit(endNodesIDs(N,1));
                        end
                    end


                    if~(stopTraversal||skip)




                        this.postOrderVisit(component);
                    end
                end

            elseif isa(slObj,'Simulink.ModelReference')&&strcmpi(slObj.Commented,'off')

                if(this.AnalysisOptions.ModelReferencesSimulationMode=="AllModes"||...
                    this.AnalysisOptions.ModelReferencesSimulationMode=="NormalModeOnly")
                    this.collectChildModelInfo(slObj);
                end
            end
        end

        function[stopTraversal,skip,component]=visitComponentObj(this,slCompObj,context)

            [stopTraversal,skip,component]=this.preOrderVisit(slCompObj,context);

            if~stopTraversal



                if isa(slCompObj,'Stateflow.Chart')
                    mlFuncts=slCompObj.find('-isa','Stateflow.EMFunction',...
                    '-and','Chart',slCompObj);

                    for N=1:length(mlFuncts)
                        if~mlFuncts(N).IsExplicitlyCommented&&~mlFuncts(N).IsImplicitlyCommented
                            [stopMLFctTraversal,~,mlFctComponent]=this.visitComponentObj(mlFuncts(N),context);

                            if~stopMLFctTraversal
                                this.postOrderVisit(mlFctComponent);
                            end
                        end
                    end
                end
            end
        end






        function[stopTraversal,skip,component]=preOrderVisit(this,slCompObj,context)


            stopTraversal=false;
            skip=false;
            component=[];

            if isa(slCompObj,'Simulink.SubSystem')&&~isempty(slCompObj.TemplateBlock)
                skip=true;

            else
                component=Advisor.component.internal.ComponentFactory.createSlComponent(slCompObj,context);

                if isempty(component)
                    stopTraversal=true;
                else

                    if component.isChecksumScopeRoot()

                        if component.IsLinked&&~this.AnalysisOptions.AnalyzeLibraries
                            stopTraversal=true;
                        else


                            template=this.getTemplate(component);

                            if isempty(template)
                                stopTraversal=true;
                            elseif this.CreateChecksumScopes
                                this.createChecksumScope(template,component);
                            end
                        end

                    elseif~this.CreateSubHierarchy


                        skip=true;

                    elseif strcmp(component.ID,this.AnalysisRoot.ComponentID)


                        template=this.TemplatesMap(this.AbstractAnalysisRoot.ComponentID);
                        component.TemplateID=template.ID;
                        template.addInstance(component.ID);

                        if this.CreateChecksumScopes
                            this.createSubHierarchyRootChecksumScope(template,component);
                        end
                    end
                end
            end

            if~stopTraversal&&~skip
                this.ComponentGraph.addComponent(component);

                if~isempty(this.ComponentStack)
                    relType=Advisor.component.RelationshipType.ObjectReference;
                    rel=Advisor.component.Relationship(this.ComponentStack{end}.ID,component.ID,relType);
                    this.ComponentGraph.addComponentRelationship(rel);
                end

                if this.CreateChecksumScopes
                    component.ChecksumScopeID=this.ChecksumStack{end};
                end

                this.ComponentStack{end+1}=component;
            end
        end

        function postOrderVisit(this,component)


            if component==this.ComponentStack{end}
                assert(~isempty(this.ComponentStack),'Cannot pop empty stack.');
                this.ComponentStack(end)=[];
            end

            if this.CreateChecksumScopes&&component.isChecksumScopeRoot()
                this.ChecksumStack(end)=[];
            end
        end

        function templateObj=getTemplate(this,component)

            templateID=Advisor.component.internal.TemplateFactory.getTemplateID(component);

            if~this.TemplatesMap.isKey(templateID)

                templateObj=Advisor.component.internal.TemplateFactory.createTemplate(component);

                if Advisor.component.isMWFile(templateObj.File)&&~this.IsDemoModelRoot


                    templateObj=[];
                    return
                end

                if this.CreateChecksumScopes
                    Advisor.component.internal.populateFileChecksum(templateObj);
                end

                this.TemplatesMap(templateID)=templateObj;
            else
                templateObj=this.TemplatesMap(templateID);
            end

            component.TemplateID=templateObj.ID;
            templateObj.addInstance(component.ID);
        end

        function collectChildModelInfo(this,modelBlockObj)
            parentComponentID=this.ComponentStack{end}.ID;

            if strcmp(modelBlockObj.Variant,'off')
                isProtected=strcmp(modelBlockObj.ProtectedModel,'on');

                simulationMode=Advisor.component.internal.getSimulationMode(...
                modelBlockObj.SimulationMode);

                analyzeFlag=true;
                if this.AnalysisOptions.ModelReferencesSimulationMode=="NormalModeOnly"
                    if(strcmp(simulationMode,'Normal')==0)
                        analyzeFlag=false;
                    end
                end

                if(analyzeFlag)
                    if~isProtected
                        this.ChildModels(end+1).ModelName=modelBlockObj.ModelName;
                    else
                        [~,name]=fileparts(modelBlockObj.ModelFile);
                        this.ChildModels(end+1).ModelName=name;
                    end

                    this.ChildModels(end).SimulationMode=simulationMode;

                    this.ChildModels(end).ParentComponentID=parentComponentID;
                    this.ChildModels(end).IsProtected=isProtected;
                end

            else




                for n=1:length(modelBlockObj.Variants)
                    variant=modelBlockObj.Variants(n);

                    simulationMode=Advisor.component.internal.getSimulationMode(...
                    variant.SimulationMode);

                    analyzeFlag=true;
                    if this.AnalysisOptions.ModelReferencesSimulationMode=="NormalModeOnly"
                        if(strcmp(simulationMode,'Normal')==0)
                            analyzeFlag=false;
                        end
                    end

                    if(analyzeFlag)

                        if isprop(variant,'ProtectedModel')&&strcmp(variant.ProtectedModel,'on')
                            isProtected=true;
                            [~,modelName,~]=fileparts(variant.ModelFile);
                        else
                            isProtected=false;
                            [~,modelName,~]=fileparts(variant.ModelName);
                        end

                        this.ChildModels(end+1).ModelName=modelName;
                        this.ChildModels(end).SimulationMode=simulationMode;


                        this.ChildModels(end).ParentComponentID=parentComponentID;
                        this.ChildModels(end).IsProtected=isProtected;
                    end
                end
            end
        end

        function createChecksumScope(this,template,component)

            cs=...
            Advisor.component.internal.ChecksumScopeFactory.createChecksumScope(template,component);

            this.ChecksumScope(end+1)=cs;
            this.ChecksumStack{end+1}=cs.ChecksumScopeID;
        end

        function createSubHierarchyRootChecksumScope(this,template,component)

            checksumScopeID=...
            Advisor.component.internal.ChecksumScopeFactory.getChecksumScopeID(...
            template,this.AbstractAnalysisRoot.ComponentID,this.AbstractAnalysisRoot.ComponentType);

            this.ChecksumScope(end+1).ChecksumScopeID=checksumScopeID;
            this.ChecksumScope(end).Checksum=template.FileChecksum;
            this.ChecksumScope(end).RootComponentID=component.ID;

            this.ChecksumStack{end+1}=checksumScopeID;
        end
    end

    methods(Static,Access=private)

        function status=isCommented(slCompObj,context)

            if isempty(context)

                if isa(slCompObj,'Simulink.BlockDiagram')
                    status=false;
                elseif strncmp(class(slCompObj),'Stateflow',9)
                    status=~strcmpi(get_param(slCompObj.Path,'Commented'),'off');
                else
                    status=~strcmpi(slCompObj.Commented,'off');
                end
            else
                if strncmp(class(slCompObj),'Stateflow',9)
                    status=~strcmpi(get_param(context.Path,'Commented'),'off');
                else
                    status=~strcmpi(context.Commented,'off');
                end
            end
        end
    end
end