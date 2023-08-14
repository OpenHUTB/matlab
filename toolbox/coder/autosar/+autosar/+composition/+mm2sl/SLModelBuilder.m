classdef SLModelBuilder<handle




    properties(Access=private)
        ModelName;
        UpdateMode;
        ChangeLogger;
        SLConnector;
        ComponentModelNames;
        LayoutManager;
        SLMatcher;
        AddedSlPorts;
        ComponentToModelMap;
        ShareAUTOSARProperties;
    end

    methods(Access=public)
        function this=SLModelBuilder(modelName,changeLogger,slMatcher,...
            addedSlPorts,updateMode,layoutManager,existingComponentModels,...
            shareAUTOSARProperties)

            this.ModelName=modelName;
            this.ChangeLogger=changeLogger;
            this.SLMatcher=slMatcher;
            this.AddedSlPorts=addedSlPorts;
            this.UpdateMode=updateMode;
            this.ComponentModelNames={};
            this.LayoutManager=layoutManager;
            this.SLConnector=[];
            this.ComponentToModelMap=autosar.composition.mm2sl....
            SLModelBuilder.createComponentToModelMap(existingComponentModels);
            this.ShareAUTOSARProperties=shareAUTOSARProperties;
        end

        function createSLConnector(this,m3iComposition,slModelBlockToM3ICompPrototypeMap)
            this.SLConnector=autosar.composition.mm2sl.SLConnector(this.ModelName,...
            this.UpdateMode,this.ChangeLogger,this.SLMatcher,...
            m3iComposition,slModelBlockToM3ICompPrototypeMap);
            if this.UpdateMode
                this.SLMatcher.markConnectorsUnmatched();
            end




            this.SLConnector.connectPRPortsForAllCompPrototypes();
        end


        function blockPath=addComponentPrototype(this,m3iCompPrototype)

            if this.UpdateMode
                [isMapped,blockPath]=this.SLMatcher.isComponentPrototypeMapped(m3iCompPrototype);
                if isMapped
                    this.updateComponentProrotype(m3iCompPrototype,blockPath);
                else
                    blockPath=this.createComponentPrototype(m3iCompPrototype,this.ModelName);
                end
            else
                blockPath=this.createComponentPrototype(m3iCompPrototype,this.ModelName);
            end


            refModel=get_param(blockPath,'ModelName');
            if~bdIsLoaded(refModel)
                load_system(refModel);
            end

            if~any(strcmp(this.ComponentModelNames,refModel))
                this.ComponentModelNames{end+1}=refModel;
            end
        end

        function connectPortsUsingConnector(this,m3iConnector)
            this.SLConnector.connectPortsUsingConnector(m3iConnector);
        end


        function finalizeCompositionModel(this,schemaVer)



            this.doDeletions();
            this.addSignalLines();


            autosar.composition.mm2sl.SLModelBuilder....
            deleteUnconnectedCompositionPorts(this.ModelName,...
            this.AddedSlPorts,this.ChangeLogger);


            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,this.ModelName,...
            'AutosarSchemaVersion',schemaVer,...
            'ModelReferenceNumInstancesAllowed','Single',...
            'EnableMultiTasking','on',...
            'AutoInsertRateTranBlk','on');



            this.addLinkToDictionaryIfNeeded();



            if slfeature('ExecutionDomainExportFunction')>0


                functionCallInports=find_system(this.ModelName,'SearchDepth',1,...
                'blocktype','Inport','OutputFunctionCall','on');
                asyncTaskSpecs=find_system(this.ModelName,'SearchDepth',1,...
                'blocktype','AsynchronousTaskSpecification');
                if~isempty(functionCallInports)&&isempty(asyncTaskSpecs)
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,this.ModelName,...
                    'SetExecutionDomain','on',...
                    'ExecutionDomainType','ExportFunction');
                end
            end


            this.LayoutManager.refresh();



            if this.UpdateMode
                autosar.mm.mm2sl.layout.LayoutHelper.deleteUnconnectedLines(this.ModelName);
            end


            addterms(this.ModelName);

            this.markupAdditions();
        end
    end

    methods(Static)
        function copyBreakpointsToCompositionModel(swcModelName,compositionModelName,compositionModelWS,lutObj)




            assert(isa(lutObj,'Simulink.LookupTable')&&strcmp(lutObj.BreakpointsSpecification,'Reference'),...
            'Expect reference model lookup tables');

            slBreakpointNames=lutObj.Breakpoints;
            for bpIndex=1:numel(slBreakpointNames)
                bpName=slBreakpointNames{bpIndex};
                [~,bpObj]=autosar.utils.Workspace.objectExistsInModelScope(swcModelName,bpName);
                if~autosar.utils.Workspace.objectExistsInModelScope(compositionModelName,bpName)
                    assignin(compositionModelWS,bpName,bpObj);
                end
            end
        end

        function deleteUnconnectedCompositionPorts(modelName,addedSlPorts,slChangeLogger)










            isSkeletonCompositionModel=isempty(find_system(modelName,...
            'SearchDepth',1,'BlockType','ModelReference'));
            if isSkeletonCompositionModel
                return
            end


            slPortsToDelete=[];
            for portIdx=1:length(addedSlPorts)
                slPort=addedSlPorts{portIdx};
                if ishandle(slPort)
                    pc=get_param(slPort,'PortConnectivity');
                    isInport=strcmp(get_param(slPort,'BlockType'),'Inport');
                    if isInport
                        if isempty(pc.DstBlock)
                            slPortsToDelete=[slPortsToDelete,slPort];%#ok<AGROW>
                        end
                    else
                        if(pc.SrcBlock==-1)
                            slPortsToDelete=[slPortsToDelete,slPort];%#ok<AGROW>
                        end
                    end
                end
            end


            automaticChanges=slChangeLogger.getLog('Automatic');
            toRemoveIdx=[];
            for blkIdx=1:length(slPortsToDelete)
                blkName=getfullname(slPortsToDelete(blkIdx));
                for chIdx=1:length(automaticChanges)
                    if contains(automaticChanges{chIdx},blkName)
                        toRemoveIdx=[toRemoveIdx,chIdx];%#ok<AGROW>
                    end
                end
            end
            slChangeLogger.removeLog('Automatic',toRemoveIdx);


            arrayfun(@(x)delete_block(x),slPortsToDelete);
        end
    end

    methods(Static,Access=private)


        function componentToModelMap=createComponentToModelMap(existingComponentModels)



            componentToModelMap=containers.Map();
            existingComponentModels=unique(existingComponentModels);
            for mdlIdx=1:length(existingComponentModels)
                modelName=existingComponentModels{mdlIdx};
                dataObj=autosar.api.getAUTOSARProperties(modelName,true);
                compQName=dataObj.get('XmlOptions','ComponentQualifiedName');
                componentToModelMap(compQName)=modelName;
            end
        end

        function periodicSampleTimes=getPeriodicRunnablesSampleTimes(m3iComp)
            m3iBehavior=m3iComp.Behavior;
            if~m3iBehavior.isvalid()||(m3iBehavior.Runnables.size()==0)
                periodicSampleTimes=0.2;
                return;
            end

            m3iRunnables=m3iBehavior.Runnables;
            periodicSampleTimes=autosar.mm.mm2sl.PeriodicRunnablesModelingStyleDeterminer....
            collectPeriodicRunnableSampleTimes(m3iRunnables);
        end



        function eventPorts=getPeriodicEventPortHandles(modelBlock)
            eventPorts=[];

            if strcmp(get_param(modelBlock,'ShowModelPeriodicEventPorts'),'off')
                return;
            end

            modelName=get_param(modelBlock,'ModelName');

            numIRTPorts=0;
            if strcmp(get_param(modelBlock,'ShowModelInitializePort'),'on')
                numIRTPorts=numIRTPorts+1;
            end

            if strcmp(get_param(modelBlock,'ShowModelTerminatePort'),'on')
                numIRTPorts=numIRTPorts+1;
            end

            if strcmp(get_param(modelBlock,'ShowModelResetPorts'),'on')
                numIRTPorts=numIRTPorts+...
                length(autosar.utils.InitResetTermFcnBlock.findResetFunctionBlocks(modelName));
            end

            if strcmp(get_param(modelBlock,'ShowModelReinitializePorts'),'on')
                numIRTPorts=numIRTPorts+...
                length(autosar.utils.InitResetTermFcnBlock.findReinitializeFunctionBlocks(modelName));
            end



            numDataInports=length(autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(...
            modelName,'Inport',''));
            ph=get_param(modelBlock,'PortHandles');
            numAllInports=length(ph.Inport);
            eventPorts=ph.Inport(numDataInports+numIRTPorts+1:numAllInports);
        end



        function portDiscreteRates=getPortDiscreteRates(modelBlock,periodicSampleTimes)
            modelName=get_param(modelBlock,'ModelName');
            hasPartitions=~isempty(Simulink.findBlocks(...
            modelName,'BlockType','SubSystem','ScheduleAs','Periodic partition'));
            if hasPartitions


                taskConnectivityGraph=sltp.TaskConnectivityGraph(modelName);
                partitions=taskConnectivityGraph.getSortedChildTasks('');
                portDiscreteRates='{';
                for stIdx=1:length(periodicSampleTimes)
                    sampleTimeStr=Simulink.metamodel.arplatform.getRealStringCompact(periodicSampleTimes(stIdx));
                    if stIdx>1
                        portDiscreteRates=[portDiscreteRates,';'];%#ok<AGROW>
                    end

                    rateName='';
                    if taskConnectivityGraph.isExplicitTask(partitions{stIdx})
                        rateName=partitions{stIdx};
                    end

                    portDiscreteRates=[portDiscreteRates,'''',rateName,''' ',sampleTimeStr];%#ok<AGROW>
                end
                portDiscreteRates=[portDiscreteRates,'}'];
            else


                portDiscreteRates='[';
                for stIdx=1:length(periodicSampleTimes)
                    sampleTimeStr=Simulink.metamodel.arplatform.getRealStringCompact(periodicSampleTimes(stIdx));
                    if stIdx>1
                        portDiscreteRates=[portDiscreteRates,','];%#ok<AGROW>
                    end

                    portDiscreteRates=[portDiscreteRates,sampleTimeStr];%#ok<AGROW>
                end
                portDiscreteRates=[portDiscreteRates,']'];
            end
        end
    end

    methods(Access=private)

        function addedBlock=copyBlock(this,srcBlk,dstBlk,paramValPair)

            blockH=add_block(srcBlk,dstBlk,paramValPair{:});
            addedBlock=getfullname(blockH);


            blockType=get_param(srcBlk,'BlockType');
            this.ChangeLogger.logAddition('Automatic',[blockType,' block'],...
            addedBlock);


            this.LayoutManager.addBlock(addedBlock);
        end

        function addedBlock=addBlock(this,blockType,blockPath,paramValPair)

            blockH=add_block(['built-in/',blockType],blockPath,paramValPair{:});
            addedBlock=getfullname(blockH);


            this.ChangeLogger.logAddition('Automatic',[blockType,' block'],...
            addedBlock);


            this.LayoutManager.addBlock(addedBlock);
        end

        function doDeletions(this)
            if this.UpdateMode

                this.SLMatcher.doDeletions(this.ChangeLogger);
            end
        end

        function addSignalLines(this)

            this.SLConnector.addLines();
        end

        function markupAdditions(this)

            if this.UpdateMode
                addedBlocks=this.LayoutManager.getAddedBlocks();
                for ii=1:length(addedBlocks)
                    autosar.mm.mm2sl.SLModelBuilder.createAddedBlockSimulinkArea(addedBlocks(ii));
                end


                addedSlPorts=this.AddedSlPorts;
                for ii=1:length(addedSlPorts)
                    addedPort=addedSlPorts{ii};
                    if ishandle(addedPort)
                        autosar.mm.mm2sl.MRLayoutManager.homeBlk(addedPort);
                        autosar.mm.mm2sl.SLModelBuilder.createAddedBlockSimulinkArea(addedPort);
                    end
                end
            end
        end

        function m3iComp=getM3ICompType(this,modelBlock,m3iCompPrototype)
            if this.ShareAUTOSARProperties



                refModel=get_param(modelBlock,'ModelName');
                if~bdIsLoaded(refModel)
                    load_system(refModel);
                end
                m3iComp=autosarcore.ModelUtils.m3iMappedComponent(refModel);
            else
                m3iComp=m3iCompPrototype.Type;
            end
        end

        function addAndWireEventPorts(this,modelBlock,m3iCompPrototype)
            if autosar.validation.ExportFcnValidator.isExportFcn(get_param(modelBlock,'ModelName'))

                this.addAndWireFcnCallInports(modelBlock);
            else




                m3iCompType=this.getM3ICompType(modelBlock,m3iCompPrototype);
                if isa(m3iCompType,'Simulink.metamodel.arplatform.component.AtomicComponent')
                    periodicSampleTimes=autosar.composition.mm2sl.SLModelBuilder....
                    getPeriodicRunnablesSampleTimes(m3iCompType);
                    this.addAndWirePeriodicEventPorts(modelBlock,periodicSampleTimes);
                end



                this.addAndWireFcnCallInports(modelBlock);
            end
        end

        function[blockPath,blockAlreadyExists]=createComponentPrototype(...
            this,m3iCompPrototype,parentModel)


            m3iComp=m3iCompPrototype.Type;
            compQName=autosar.api.Utils.getQualifiedName(m3iComp);
            if this.ComponentToModelMap.isKey(compQName)
                componentName=this.ComponentToModelMap(compQName);
            else
                componentName=m3iComp.Name;
            end
            instanceName=m3iCompPrototype.Name;

            blockPath=[parentModel,'/',instanceName];
            blockType='ModelReference';


            blockAlreadyExists=find_system(this.ModelName,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FirstResultOnly','on','Name',instanceName);
            if isempty(blockAlreadyExists)
                this.addBlock(blockType,blockPath,...
                {'ModelName',componentName,...
                'SimulationMode','Normal'});
            end


            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blockPath,...
            'ModelName',componentName);


            this.commonToCreateAndUpdateComponentPrototype(m3iCompPrototype,blockPath);
        end

        function updateComponentProrotype(this,m3iCompPrototype,blockPath)


            blockObj=get_param(blockPath,'Object');
            blockObj.refreshModelBlock();


            this.commonToCreateAndUpdateComponentPrototype(m3iCompPrototype,blockPath);
        end


        function commonToCreateAndUpdateComponentPrototype(this,m3iCompPrototype,blockPath)

            slDesc=autosar.mm.util.DescriptionHelper.getSLDescFromM3IDesc(m3iCompPrototype.desc);
            if~isempty(slDesc)
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blockPath,...
                'Description',slDesc);
            end


            this.addAndWireEventPorts(blockPath,m3iCompPrototype);
        end






        function addAndWirePeriodicEventPorts(this,modelBlock,periodicSampleTimes)

            modelName=get_param(modelBlock,'ModelName');
            assert(~autosar.validation.ExportFcnValidator.isExportFcn(modelName),...
            'Periodic Event ports are not supported for export function model %s',modelName);


            [~,sortIdx]=sort(periodicSampleTimes);
            periodicSampleTimes=periodicSampleTimes(sortIdx);


            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,modelBlock,...
            'ShowModelPeriodicEventPorts','on');


            portDiscreteRates=autosar.composition.mm2sl.SLModelBuilder.getPortDiscreteRates(modelBlock,periodicSampleTimes);
            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,modelBlock,...
            'PortDiscreteRates',portDiscreteRates);


            eventPorts=autosar.composition.mm2sl.SLModelBuilder.getPeriodicEventPortHandles(modelBlock);
            assert(length(periodicSampleTimes)==length(eventPorts),...
            'Number of periodic event ports should be same as sample times of model');



            parentName=bdroot(modelBlock);
            blockName=get_param(modelBlock,'Name');
            for portIdx=1:length(eventPorts)
                eventPort=eventPorts(portIdx);
                lineConnectedToEventPort=get_param(eventPort,'Line');
                sampleTime=Simulink.metamodel.arplatform.getRealStringCompact(periodicSampleTimes(portIdx));
                if(lineConnectedToEventPort==-1)


                    fcnCallPortName=[blockName,'_Run_',sampleTime];
                    fcnCallPort=this.addBlock('Inport',[parentName,'/',fcnCallPortName],...
                    {'MakeNameUnique','on','OutputFunctionCall','on',...
                    'SampleTime',sampleTime});

                    autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(fcnCallPort);
                    portNum=num2str(get_param(eventPort,'PortNumber'));
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentName,...
                    [get_param(fcnCallPort,'Name'),'/1'],...
                    [get_param(modelBlock,'Name'),'/',portNum]);
                else

                    assert(this.UpdateMode,'eventPort have something connected outside updateModel!');



                    srcBlockH=get(lineConnectedToEventPort,'SrcBlockHandle');
                    if(length(srcBlockH)==1)&&(srcBlockH~=-1)&&...
                        strcmp(get_param(srcBlockH,'BlockType'),'Inport')&&...
                        strcmp(get_param(srcBlockH,'OutputFunctionCall'),'on')
                        autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                        srcBlockH,'SampleTime',sampleTime);
                    end
                end
            end
        end




        function addAndWireFcnCallInports(this,modelBlock)


            compName=get_param(modelBlock,'ModelName');
            parentName=bdroot(modelBlock);
            fcnCallInports=find_system(compName,'SearchDepth',1,...
            'BlockType','Inport','OutputFunctionCall','on');



            for fcnIdx=1:length(fcnCallInports)
                fcnCallInport=fcnCallInports{fcnIdx};
                portHandles=get_param(modelBlock,'PortHandles');
                dstPortNum=get_param(fcnCallInport,'Port');
                dstPortHandle=portHandles.Inport(str2double(dstPortNum));
                lineConnectedToDstPort=get_param(dstPortHandle,'Line');

                if(lineConnectedToDstPort==-1)




                    addedBlock=this.copyBlock(fcnCallInport,...
                    [parentName,'/',get_param(fcnCallInport,'Name')],...
                    {'MakeNameUnique','on'});


                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentName,...
                    [get_param(addedBlock,'Name'),'/1'],...
                    [get_param(modelBlock,'Name'),'/',dstPortNum]);

                else

                    assert(this.UpdateMode,'fcnCallInport have something connected outside updateModel!');



                    srcBlockH=get(lineConnectedToDstPort,'SrcBlockHandle');
                    if(length(srcBlockH)==1)&&(srcBlockH~=-1)&&...
                        strcmp(get_param(srcBlockH,'BlockType'),'Inport')&&...
                        strcmp(get_param(srcBlockH,'OutputFunctionCall'),'on')
                        sampleTime=get_param(fcnCallInport,'SampleTime');
                        autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                        srcBlockH,'SampleTime',sampleTime);
                    end
                end
            end
        end

        function addLinkToDictionaryIfNeeded(this)

            dictionaries=unique(cellfun(@(x)get_param(x,'DataDictionary'),...
            this.ComponentModelNames,'UniformOutput',false));
            dictionaries(strcmp(dictionaries,''))=[];

            if~isempty(dictionaries)
                ddName=dictionaries{1};
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                this.ModelName,'DataDictionary',ddName);
            end
        end
    end
end



