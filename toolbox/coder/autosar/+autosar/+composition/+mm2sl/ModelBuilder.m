classdef ModelBuilder<m3i.Visitor





    properties(Access=private)
        M3IModel;
        M3IComposition;
        SchemaVersion;
        SLModelBuilder;
        ModelName;
        msgStream;
        ChangeLogger;
        XmlOptsGetter;
        UpdateMode;
        SlModelBlockToM3ICompPrototypeMap;
        ComponentModelBuilder;
        ShareAUTOSARProperties;
    end

    methods(Access=public)




        function this=ModelBuilder(m3iModel,shareAUTOSARProperties,schemaVer,...
            changeLogger,xmlOptsGetter,updateMode)
            assert(isa(m3iModel,'Simulink.metamodel.foundation.Domain'),'Expected m3i model');
            this.M3IModel=m3iModel;
            this.ShareAUTOSARProperties=shareAUTOSARProperties;
            this.SchemaVersion=schemaVer;
            this.ChangeLogger=changeLogger;
            this.XmlOptsGetter=xmlOptsGetter;
            this.UpdateMode=updateMode;
            this.ComponentModelBuilder=[];
            this.SlModelBlockToM3ICompPrototypeMap=containers.Map();


            this.registerVisitor('mmVisit','mmVisit');
            this.bind('Simulink.metamodel.arplatform.composition.CompositionComponent',@mmWalkCompositionComponent,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.composition.ComponentPrototype',@mmWalkComponentPrototype,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.composition.AssemblyConnector',@mmWalkAssemblyConnector,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.composition.DelegationConnector',@mmWalkDelegationConnector,'mmVisit');


            this.msgStream=autosar.mm.util.MessageStreamHandler.instance();
        end


        function sysHandle=createComposition(this,m3iComposition,...
            modelName,dataDictionary,existingComponentModels)

            this.M3IComposition=m3iComposition.asDeviant(this.M3IModel.asImmutable.getRootDeviant());

            this.ModelName=modelName;


            [m3iComponents,layoutLayers]=this.getOrderedComponents(m3iComposition);



            layoutManager=autosar.mm.mm2sl.layout.LayoutManagerFactory.getLayoutManager(this.ModelName,...
            'TopModel',this.UpdateMode,'ModelReference','LayoutLayers',layoutLayers);


            this.ComponentModelBuilder=this.visitCompositionPorts(dataDictionary);
            addedSlPorts=this.ComponentModelBuilder.SLModelBuilder.getAddedBlks();
            slMatcher=this.ComponentModelBuilder.SLModelBuilder.getSLMatcher();


            this.SLModelBuilder=autosar.composition.mm2sl.SLModelBuilder(...
            this.ModelName,this.ChangeLogger,slMatcher,addedSlPorts,this.UpdateMode,...
            layoutManager,existingComponentModels,this.ShareAUTOSARProperties);





            this.apply('mmVisit',this.M3IComposition,m3iComponents);


            if~isempty(dataDictionary)
                set_param(this.ModelName,'DataDictionary',dataDictionary);
            end


            autosar.api.Utils.setM3iModelDirty(this.ModelName);
            if this.ShareAUTOSARProperties
                assert(~isempty(dataDictionary),'DataDictionary must be set for sharing AUTOSAR properties.');
                autosar.dictionary.Utils.updateModelMappingWithDictionary(this.ModelName,dataDictionary);
                Simulink.AutosarDictionary.ModelRegistry.setAutosarPartDirty(dataDictionary);
            end

            sysHandle=get_param(this.ModelName,'Handle');
        end




        function ret=mmVisitM3IObject(~,~,varargin)
            ret=[];
        end




        function ret=visitM3IObject(~,~,varargin)
            ret=[];
        end


        function ret=mmWalkCompositionComponent(this,m3iComposition,...
            orderedM3IComponents)
            ret=[];


            this.applySeq('mmVisit',orderedM3IComponents);


            this.populateMapping();



            this.SLModelBuilder.createSLConnector(m3iComposition,this.SlModelBlockToM3ICompPrototypeMap);
            this.applySeq('mmVisit',m3iComposition.Connectors);


            this.SLModelBuilder.finalizeCompositionModel(this.SchemaVersion);
        end


        function ret=mmWalkComponentPrototype(this,m3iComponentPrototype)
            ret=[];



            m3iComponent=m3iComponentPrototype.Type;
            if~autosar.composition.mm2sl.ModelBuilder.isComponentImportedAsSimulinkModel(m3iComponent)
                return;
            end


            modelBlockPath=this.SLModelBuilder.addComponentPrototype(m3iComponentPrototype);


            this.SlModelBlockToM3ICompPrototypeMap(modelBlockPath)=m3iComponentPrototype;
        end


        function ret=mmWalkAssemblyConnector(this,m3iAssemblyConnector)
            ret=[];

            if~m3iAssemblyConnector.Provider.isvalid()||...
                ~m3iAssemblyConnector.Requester.isvalid()
                return;
            end



            pComp=m3iAssemblyConnector.Provider.ComponentPrototype;
            rComp=m3iAssemblyConnector.Requester.ComponentPrototype;
            if~autosar.composition.mm2sl.ModelBuilder.isComponentImportedAsSimulinkModel(pComp.Type)||...
                ~autosar.composition.mm2sl.ModelBuilder.isComponentImportedAsSimulinkModel(rComp.Type)
                return;
            end


            this.SLModelBuilder.connectPortsUsingConnector(m3iAssemblyConnector);
        end


        function ret=mmWalkDelegationConnector(this,m3iDelegationConnector)
            ret=[];

            if~m3iDelegationConnector.InnerPort.isvalid()||...
                ~m3iDelegationConnector.OuterPort.isvalid()
                return;
            end



            innerComp=m3iDelegationConnector.InnerPort.ComponentPrototype;
            if~autosar.composition.mm2sl.ModelBuilder.isComponentImportedAsSimulinkModel(innerComp.Type)
                return;
            end


            this.SLModelBuilder.connectPortsUsingConnector(m3iDelegationConnector);
        end
    end

    methods(Access=private)
        function populateMapping(this)


            t=M3I.Transaction(this.M3IModel);


            [~]=Simulink.AutosarTarget.Component('','');
            [~]=Simulink.AutosarTarget.Composition('','');
            mmgr=get_param(this.ModelName,'MappingManager');
            mappingType='AutosarComposition';
            mapping=mmgr.getActiveMappingFor(mappingType);
            if isempty(mapping)
                mappingName=autosar.api.Utils.createMappingName(this.ModelName,mappingType);
                mmgr.createMapping(mappingName,mappingType);
                mmgr.activateMapping(mappingName);
            end
            mapping=mmgr.getActiveMappingFor(mappingType);


            mapping.AUTOSAR_ROOT=this.M3IModel;


            componentId=this.M3IComposition.qualifiedName;
            compositionObj=Simulink.AutosarTarget.Composition(...
            componentId,this.M3IComposition.Name);
            mapping.mapComposition(compositionObj);


            this.ComponentModelBuilder.SLModelBuilder.populatePortsMapping(...
            this.ComponentModelBuilder.slPort2RefBiMap,...
            this.ComponentModelBuilder.slPort2AccessMap);


            cellfun(@(x)x.destroy(),this.ComponentModelBuilder.slPort2RefBiMap.getRightKeys);


            reRegisterListener=autosarcore.unregisterListenerCBTemporarily(this.M3IModel);%#ok<NASGU>
            t.commit();


            modelBlocks=this.SlModelBlockToM3ICompPrototypeMap.keys();
            for idx=1:numel(modelBlocks)

                modelBlock=modelBlocks{idx};
                m3iCompPrototype=this.SlModelBlockToM3ICompPrototypeMap(modelBlock);


                slMapping=autosar.api.getSimulinkMapping(this.ModelName,this.ChangeLogger);
                slMapping.mapModelBlock(get_param(modelBlock,'Name'),...
                m3iCompPrototype.Name,m3iCompPrototype.qualifiedName);
            end
        end

        function componentModelBuilder=visitCompositionPorts(this,dataDictionary)






            createSimulinkObject=true;
            nameConflictAction='overwrite';
            createTypes=true;
            createCalPrms=false;
            createInternalBehavior=false;
            initializationRunnable='';
            resetRunnables={};
            terminateRunnable='';
            openModel=false;
            autoDelete=true;
            forceLegacyWorkspaceBehavior=false;
            useBusElementPorts=false;
            m3iSwcTiming='';
            componentModelBuilder=autosar.mm.mm2sl.ModelBuilder(this.M3IModel,...
            dataDictionary,this.ShareAUTOSARProperties,this.ChangeLogger,this.XmlOptsGetter,m3iSwcTiming);
            componentModelBuilder.createComponent(this.M3IComposition,createSimulinkObject,...
            nameConflictAction,createTypes,createCalPrms,...
            createInternalBehavior,initializationRunnable,resetRunnables,...
            terminateRunnable,dataDictionary,...
            this.UpdateMode,autoDelete,this.ModelName,openModel,...
            forceLegacyWorkspaceBehavior,useBusElementPorts);
        end






        function[m3iComponents,layers]=getOrderedComponents(this,m3iComposition)


            [m3iSrcComps,m3iDstComps,m3iLeafComps]=...
            autosar.composition.mm2sl.ModelBuilder.findConnectedAndLeafComps(m3iComposition);


            srcCompNames={};
            dstCompNames={};
            leafCompNames={};
            if~isempty(m3iSrcComps)
                srcCompNames={m3iSrcComps.Name};
                dstCompNames={m3iDstComps.Name};
            end
            if~isempty(m3iLeafComps)
                leafCompNames={m3iLeafComps.Name};
            end


            layoutLayers=autosar.mm.mm2sl.layout.LayoutGraphUtils.getLayoutLayers(...
            srcCompNames,dstCompNames,leafCompNames);

            if this.UpdateMode


                modelBlocks=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(this.ModelName,'ModelReference','');
                existingComps=get_param(modelBlocks,'Name');
                if~iscell(existingComps)
                    existingComps={existingComps};
                end
                if~isempty(existingComps)
                    newComps=setdiff([layoutLayers{:}],existingComps,'stable');
                    layers=[{existingComps'},{newComps}];
                else
                    layers=layoutLayers;
                end
            else
                layers=layoutLayers;
            end


            m3iComponents=Simulink.metamodel.arplatform.composition.SequenceOfComponentPrototype.make(...
            m3iComposition.rootModel);
            m3iAllComps=[m3iSrcComps,m3iDstComps,m3iLeafComps];
            if~isempty(m3iAllComps)
                [~,uniqIdx]=unique({m3iAllComps.Name});
                m3iAllComps=m3iAllComps(uniqIdx);
                for layerIdx=1:length(layers)
                    layer=layers{layerIdx};
                    for elmIdx=1:length(layer)
                        m3iComp=m3iAllComps(arrayfun(@(x)strcmp(x.Name,layer{elmIdx}),m3iAllComps));
                        if~isempty(m3iComp)
                            m3iComponents.append(m3iComp);
                        end
                    end
                end
            end
        end
    end

    methods(Static,Access='private')



        function[m3iSrcComps,m3iDstComps,m3iLeafComps]=findConnectedAndLeafComps(m3iComposition)

            assemblyConnectors=m3i.filter(@(x)...
            isa(x,'Simulink.metamodel.arplatform.composition.AssemblyConnector'),...
            m3iComposition.Connectors);


            m3iSrcComps=[];
            m3iDstComps=[];
            for i=1:length(assemblyConnectors)
                assemblyConnector=assemblyConnectors{i};
                if~assemblyConnector.Provider.isvalid()||...
                    ~assemblyConnector.Requester.isvalid()
                    continue;
                end
                m3iPort=assemblyConnector.Provider.ProvidedPort;
                if autosar.composition.mm2sl.SLConnector.portRequiresWiredConnection(m3iPort)
                    m3iSrcComp=assemblyConnector.Provider.ComponentPrototype;
                    m3iDstComp=assemblyConnector.Requester.ComponentPrototype;


                    if autosar.composition.mm2sl.ModelBuilder.isComponentImportedAsSimulinkModel(m3iSrcComp.Type)&&...
                        autosar.composition.mm2sl.ModelBuilder.isComponentImportedAsSimulinkModel(m3iDstComp.Type)
                        m3iSrcComps=[m3iSrcComps,m3iSrcComp];%#ok<AGROW>
                        m3iDstComps=[m3iDstComps,m3iDstComp];%#ok<AGROW>
                    end
                end
            end


            srcAndDstComps=[m3iSrcComps,m3iDstComps];
            m3iLeafComps=[];
            for compIdx=1:m3iComposition.Components.size()
                m3iComp=m3iComposition.Components.at(compIdx);
                if~m3iComp.Type.isvalid()
                    continue;
                end
                if isempty(find(arrayfun(@(x)x==m3iComp,srcAndDstComps),1))&&...
                    autosar.composition.mm2sl.ModelBuilder.isComponentImportedAsSimulinkModel(m3iComp.Type)
                    m3iLeafComps=[m3iLeafComps,m3iComp];%#ok<AGROW>
                end
            end
        end
    end

    methods(Static)
        function importAsModel=isComponentImportedAsSimulinkModel(m3iComp)
            if isa(m3iComp,'Simulink.metamodel.arplatform.composition.CompositionComponent')
                importAsModel=true;
            elseif isa(m3iComp,'Simulink.metamodel.arplatform.component.ParameterComponent')
                importAsModel=false;
            else

                importAsModel=autosar.composition.Utils.isAtomicComponentSupported(m3iComp);
            end
        end
    end
end



