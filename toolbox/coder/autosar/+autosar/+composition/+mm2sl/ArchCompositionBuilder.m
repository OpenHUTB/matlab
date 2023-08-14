classdef ArchCompositionBuilder<m3i.Visitor





    properties(Access=private)
        RootArchModelH;
        ChangeLogger;
        TotalNumOfCompositions;
        CurrentCompositionNum;
        OkayToPushNags;
        SchemaVer;
        ComponentModelsMap;
        CompositionArgParser;
    end

    methods(Access=public)

        function this=ArchCompositionBuilder(rootArchModelH,schemaVer,okToPushNags,componentModelsMap,compositionArgParser)
            this.RootArchModelH=get_param(rootArchModelH,'handle');
            this.OkayToPushNags=okToPushNags;
            this.ChangeLogger=autosar.updater.ChangeLogger;
            this.SchemaVer=schemaVer;
            this.ComponentModelsMap=componentModelsMap;
            this.CompositionArgParser=compositionArgParser;


            this.registerVisitor('mmVisit','mmVisit');
            this.bind('Simulink.metamodel.arplatform.port.DataReceiverPort',@mmWalkRequiredPort,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.port.DataSenderPort',@mmWalkProvidedPort,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.port.ModeReceiverPort',@mmWalkRequiredPort,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.port.ModeSenderPort',@mmWalkProvidedPort,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.port.NvDataReceiverPort',@mmWalkRequiredPort,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.port.NvDataSenderPort',@mmWalkProvidedPort,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.composition.CompositionComponent',@mmWalkComposition,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.composition.ComponentPrototype',@mmWalkComponentPrototype,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.composition.AssemblyConnector',@mmWalkAssemblyConnector,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.composition.DelegationConnector',@mmWalkDelegationConnector,'mmVisit');
        end

        function importComposition(this,m3iTopComposition,slSourceH,xmlOptsGetter)




            m3iModel=autosar.api.Utils.m3iModel(this.RootArchModelH);
            tran=M3I.Transaction(m3iModel);



            doRecursion=true;
            m3iAllCompositions=autosar.composition.Utils.findCompositionComponents(...
            m3iTopComposition,doRecursion);
            this.TotalNumOfCompositions=length(m3iAllCompositions);
            this.CurrentCompositionNum=0;


            this.importNestedComps(m3iTopComposition,slSourceH);


            this.dispCompositionImportProgress(m3iTopComposition);


            ddName=this.CompositionArgParser.DataDictionary;
            if~isempty(ddName)
                set_param(slSourceH,'DataDictionary',ddName);
                Simulink.dd.open(ddName);
            end

            this.apply('mmVisit',m3iTopComposition,slSourceH);


            if strcmp(get_param(slSourceH,'Type'),'block_diagram')
                maxShortNameLength=get_param(slSourceH,'AutosarMaxShortNameLength');
                xmlOpts=xmlOptsGetter.getXmlOpts(m3iTopComposition,maxShortNameLength);
                autosar.mm.util.XmlOptionsSetter.setCommonXmlOpts(...
                m3iModel.RootPackage.front(),xmlOpts);
                isAdaptive=false;
                schemaVer=autosar.mm.util.getSchemaVersionForConfigSet(this.SchemaVer,isAdaptive);
                set_param(slSourceH,'AutosarSchemaVersion',schemaVer);
            end

            tran.commit();

            this.configureForMultiTask(slSourceH);


            this.importExecutionOrderConstraints(m3iTopComposition);
        end


        function ret=mmVisitM3IObject(~,~,varargin)
            ret=[];
        end


        function ret=visitM3IObject(~,~,varargin)
            ret=[];
        end

        function ret=mmWalkRequiredPort(this,m3iPort,slSourceH)%#ok<INUSL>
            ret=[];
            autosar.composition.mm2sl.ArchCompositionBuilder.addPort(...
            'Receiver',m3iPort,slSourceH);
        end

        function ret=mmWalkProvidedPort(this,m3iPort,slSourceH)%#ok<INUSL>
            ret=[];
            autosar.composition.mm2sl.ArchCompositionBuilder.addPort(...
            'Sender',m3iPort,slSourceH);
        end


        function ret=mmWalkComposition(this,m3iComposition,slSourceH)
            ret=[];


            this.applySeq('mmVisit',m3iComposition.ReceiverPorts,slSourceH);
            this.applySeq('mmVisit',m3iComposition.SenderPorts,slSourceH);
            this.applySeq('mmVisit',m3iComposition.ModeReceiverPorts,slSourceH);
            this.applySeq('mmVisit',m3iComposition.ModeSenderPorts,slSourceH);
            this.applySeq('mmVisit',m3iComposition.NvReceiverPorts,slSourceH);
            this.applySeq('mmVisit',m3iComposition.NvSenderPorts,slSourceH);

            this.applySeq('mmVisit',m3iComposition.Connectors,slSourceH);


            compObj=autosar.arch.Composition.create(slSourceH);
            compObj.Name=m3iComposition.Name;
            if strcmp(get_param(slSourceH,'Type'),'block_diagram')
                compObj.CompositionName=m3iComposition.Name;


                autosar.composition.mm2sl.ArchCompositionBuilder.copyUuidIfNotEmpty(...
                m3iComposition,autosar.api.Utils.m3iMappedComponent(slSourceH));
            end


            autosar.composition.mm2sl.ArchCompositionBuilder.autoLayout(slSourceH);
        end


        function ret=mmWalkAssemblyConnector(this,m3iAssemblyConnector,slConnectorParentH)
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


            m3iComposition=m3iAssemblyConnector.containerM3I;
            slConnector=autosar.composition.mm2sl.SLConnector(getfullname(this.RootArchModelH),...
            false,[],[],m3iComposition,[]);
            slConnector.connectPortsUsingConnectorInArchModel(m3iAssemblyConnector,slConnectorParentH);
        end


        function ret=mmWalkDelegationConnector(this,m3iDelegationConnector,slConnectorParentH)
            ret=[];

            if~m3iDelegationConnector.InnerPort.isvalid()||...
                ~m3iDelegationConnector.OuterPort.isvalid()
                return;
            end



            innerComp=m3iDelegationConnector.InnerPort.ComponentPrototype;
            if~autosar.composition.mm2sl.ModelBuilder.isComponentImportedAsSimulinkModel(innerComp.Type)
                return;
            end


            m3iComposition=m3iDelegationConnector.containerM3I;
            slConnector=autosar.composition.mm2sl.SLConnector(getfullname(this.RootArchModelH),...
            false,[],[],m3iComposition,[]);
            slConnector.connectPortsUsingConnectorInArchModel(m3iDelegationConnector,slConnectorParentH);

        end
    end

    methods(Access=private)
        function importNestedComps(this,m3iTopComposition,slSourceH)

            m3iCompPrototypes=m3iTopComposition.Components;
            for idx=1:m3iCompPrototypes.size()
                m3iCompProtoType=m3iCompPrototypes.at(idx);
                m3iCompType=m3iCompProtoType.Type;
                if m3iCompType.isvalid()&&~autosar.composition.mm2sl.ModelBuilder.isComponentImportedAsSimulinkModel(m3iCompType)
                    continue;
                end
                if isa(m3iCompType,'Simulink.metamodel.arplatform.composition.CompositionComponent')

                    this.dispCompositionImportProgress(m3iCompType);


                    compObj=this.addComposition(...
                    m3iCompProtoType,slSourceH);


                    this.importNestedComps(m3iCompType,compObj.SimulinkHandle);


                    this.apply('mmVisit',m3iCompType,compObj.SimulinkHandle);
                else

                    if m3iCompType.isvalid()&&(~this.CompositionArgParser.ExcludeInternalBehavior...
                        ||any(strcmp(this.CompositionArgParser.ComponentModels,this.ComponentModelsMap(autosar.api.Utils.getQualifiedName(m3iCompProtoType.Type)))))
                        compModelName=this.ComponentModelsMap(autosar.api.Utils.getQualifiedName(m3iCompProtoType.Type));

                        compObj=this.addComponent(...
                        m3iCompProtoType,slSourceH,compModelName);
                        compObj.set('Kind',m3iCompProtoType.Type.Kind.toString());
                    else

                        compObj=this.addComponent(...
                        m3iCompProtoType,slSourceH,'');

                        if m3iCompType.isvalid()
                            compObj.set('Kind',m3iCompProtoType.Type.Kind.toString());
                        end
                    end


                    autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(...
                    getfullname(compObj.SimulinkHandle));
                end
            end
        end

        function dispCompositionImportProgress(this,m3iCompType)
            compositionQName=autosar.api.Utils.getQualifiedName(m3iCompType);
            this.CurrentCompositionNum=this.CurrentCompositionNum+1;
            Simulink.output.info(message(...
            'autosarstandard:editor:CompositionImportToArchModelProgress',...
            int2str(this.CurrentCompositionNum),...
            int2str(this.TotalNumOfCompositions),compositionQName).getString());
        end

        function terminateStage=dispStageInContext(this,msg)
            if this.OkayToPushNags

                terminateStage=sldiagviewer.createStage(msg,'ModelName',getfullname(this.RootArchModelH));
            else
                terminateStage=[];
                disp(msg);
            end
        end

        function compObj=addComponent(this,m3iSrcCompProtoType,slCompositionH,componentModelName)
            import autosar.composition.mm2sl.ArchCompositionBuilder



            archCompositionObj=autosar.arch.Composition.create(slCompositionH);
            compObj=archCompositionObj.addComponent(m3iSrcCompProtoType.Name);

            importAsLogical=false;

            if isempty(componentModelName)
                importAsLogical=true;
            else
                if(autosar.validation.ExportFcnValidator.isExportFcn(componentModelName)...
                    &&(slfeature('BEPInExportFunctions')<1||slfeature('AUTOSARBepExpFcn')<1))

                    importAsLogical=true;
                    Simulink.output.info(message(...
                    'autosarstandard:importer:ComponentNotLinkedExpFcn',...
                    componentModelName).getString());
                end

                [canRefactor,~,messageStr]=...
                autosar.simulink.bep.RefactorModelInterface.canRefactorModelInterface(componentModelName);
                if~importAsLogical&&~canRefactor
                    importAsLogical=true;
                    Simulink.output.info(messageStr);
                end
            end

            if importAsLogical

                m3iCompType=m3iSrcCompProtoType.Type;
                if m3iCompType.isvalid()
                    this.applySeq('mmVisit',m3iCompType.ReceiverPorts,compObj.SimulinkHandle);
                    this.applySeq('mmVisit',m3iCompType.SenderPorts,compObj.SimulinkHandle);
                    this.applySeq('mmVisit',m3iCompType.ModeReceiverPorts,compObj.SimulinkHandle);
                    this.applySeq('mmVisit',m3iCompType.ModeSenderPorts,compObj.SimulinkHandle);
                    this.applySeq('mmVisit',m3iCompType.NvReceiverPorts,compObj.SimulinkHandle);
                    this.applySeq('mmVisit',m3iCompType.NvSenderPorts,compObj.SimulinkHandle);
                end

                set_param(compObj.SimulinkHandle,'ContentPreviewEnabled','off');
            else


                arProps=autosar.api.getAUTOSARProperties(componentModelName);
                arProps.set('XmlOptions','XmlOptionsSource','Inherit');




                MG2.syncOnGuiPingPong();


                save_system(componentModelName);


                compObj.linkToModel(componentModelName);
            end


            m3iAddedCompProto=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(compObj.SimulinkHandle);
            ArchCompositionBuilder.copyUuidIfNotEmpty(m3iSrcCompProtoType,m3iAddedCompProto);
        end

        function importExecutionOrderConstraints(this,m3iTopComposition)



            modelName=getfullname(this.RootArchModelH);
            hasEOC=autosar.timing.mm2sl.VfbViewBuilder.hasExecutionOrderConstraints(modelName,m3iTopComposition);
            if~hasEOC
                return
            end


            set_param(modelName,'SimulationCommand','update');


            updateMode=false;
            vfbViewBuilder=autosar.timing.mm2sl.VfbViewBuilder(modelName,updateMode,m3iTopComposition);
            vfbViewBuilder.build();
        end
    end

    methods(Static,Access=private)
        function autoLayout(slSourceH)


            compObj=autosar.arch.Composition.create(slSourceH);
            compObj.layout();

            if strcmp(get_param(slSourceH,'Type'),'block')
                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(...
                getfullname(slSourceH));
            else
                set_param(slSourceH,'ZoomFactor','FitSystem');
            end
        end

        function portObj=addPort(portKind,m3iSrcPort,slCompositionH)

            archCompositionObj=autosar.arch.Composition.create(slCompositionH);
            portObj=archCompositionObj.addPort(portKind,m3iSrcPort.Name);


            if isa(portObj,'autosar.arch.ArchPort')
                m3iAddedPort=autosar.composition.Utils.findM3IPortForCompositePort(portObj.SimulinkHandle);
                autosar.composition.mm2sl.ArchCompositionBuilder.copyUuidIfNotEmpty(m3iSrcPort,m3iAddedPort);
            end
        end

        function compObj=addComposition(m3iSrcCompProtoType,slCompositionH)
            import autosar.composition.mm2sl.ArchCompositionBuilder



            archCompositionObj=autosar.arch.Composition.create(slCompositionH);
            compObj=archCompositionObj.addComposition(m3iSrcCompProtoType.Name);


            m3iAddedCompProto=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(compObj.SimulinkHandle);
            ArchCompositionBuilder.copyUuidIfNotEmpty(m3iSrcCompProtoType,m3iAddedCompProto);
            ArchCompositionBuilder.copyUuidIfNotEmpty(m3iSrcCompProtoType.Type,m3iAddedCompProto.Type);
        end

        function copyUuidIfNotEmpty(m3iSrc,m3iDst)
            uuid=autosar.api.Utils.getUUID(m3iSrc);
            if~isempty(uuid)
                autosar.mm.Model.setExtraExternalToolInfo(m3iDst,...
                'ARXML',{'%s'},{uuid});
            end
        end

        function configureForMultiTask(slSourceH)
            assert(Simulink.internal.isArchitectureModel(slSourceH,'AUTOSARArchitecture'),...
            'These settings only apply to architecture models');


            set_param(slSourceH,'AllowMultiTaskInputOutput','on');

            if autosar.composition.mm2sl.ArchCompositionBuilder.archContainsAsyncInport(slSourceH)


                set_param(slSourceH,'MultiTaskRateTransMsg','error');
            end
        end

        function containsAsync=archContainsAsyncInport(slSourceH)


            containsAsync=false;

            archObj=autosar.arch.loadModel(slSourceH);
            components=archObj.find('Component','AllLevels',true);
            referencedModels=unique({components.ReferenceName});
            for refIdx=1:numel(referencedModels)
                if isempty(referencedModels{refIdx})

                    continue;
                end


                asyncTaskSpec=find_system(referencedModels{refIdx},...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'BlockType','AsynchronousTaskSpecification');
                if~isempty(asyncTaskSpec)
                    containsAsync=true;
                    return;
                end
            end
        end
    end
end



