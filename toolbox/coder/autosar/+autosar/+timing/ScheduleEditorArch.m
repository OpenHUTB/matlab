classdef ScheduleEditorArch<autosar.timing.ExecutionList





    properties(Access=private)
        TaskConnectivityGraph;
    end

    methods
        function this=ScheduleEditorArch(modelName)
            if~(autosar.api.Utils.isMappedToComposition(modelName)&&...
                Simulink.internal.isArchitectureModel(modelName,'AUTOSARArchitecture'))
                assert(false,'%s is not mapped to a composition',modelName);
            end

            this@autosar.timing.ExecutionList(modelName);
            this.TaskConnectivityGraph=sltp.TaskConnectivityGraph(modelName);
        end

        function[slEntryPointFunctions,swcNames]=getExecutionOrder(this)



            partitions=this.TaskConnectivityGraph.getSortedChildTasks('');
            if this.hasPartitionsWithNoSIDAndComponentsWithNoRate()||...
                (any(strcmp(partitions,'D1'))&&this.hasNewExplicitSampleTime())





                slEntryPointFunctions='';
                swcNames='';
                return
            end

            slEntryPointFunctions=strings(size(partitions));
            swcNames=strings(size(partitions));
            hasKnownLimitationsCausingEmptyD1=this.hasD1Limitation();
            for i=1:length(partitions)
                if strcmp(partitions{i},'D1')&&hasKnownLimitationsCausingEmptyD1


                    continue
                end

                if this.TaskConnectivityGraph.getIsSlFunc(partitions{i})

                    continue
                end

                [rootSlEntryPointFunction,swcName]=this.getRootSlEntryPointFunctionForPartition(partitions{i});


                slEntryPointFunctions(i)=rootSlEntryPointFunction;
                swcNames(i)=swcName;
            end


            slEntryPointFunctions(cellfun('isempty',slEntryPointFunctions))=[];
            swcNames(cellfun('isempty',swcNames))=[];
        end

        function ret=isPartitionForServiceFcn(this,partition)

            ret=false;
            if slfeature('SoftwareModelingAutosar')>0

                SID=this.TaskConnectivityGraph.getSourceBlockSIDs(partition);
                assert(length(SID)==1,...
                'Partition %s is not mapped to one source block SIDs',partition);
                handle=Simulink.ID.getHandle([this.ModelName,':',SID{1}]);
                if isequal(get_param(handle,'BlockType'),'SubSystem')&&...
                    isequal(get_param(handle,'IsSimulinkFunction'),'on')

                    ret=true;
                end
            end
        end

        function setExecutionOrder(this,rootSlEntryPointFunctions,swcNames)


            hasKnownLimitationsCausingEmptyD1=this.hasD1Limitation();
            for i=1:length(rootSlEntryPointFunctions)
                partition=this.findPartitionForRootSlEntryPointFunction(rootSlEntryPointFunctions{i},swcNames{i});
                if isempty(partition)


                    return
                end

                try
                    if hasKnownLimitationsCausingEmptyD1


                        index=i;
                    else
                        index=i-1;
                    end
                    this.TaskConnectivityGraph.setOrderIndex(partition,index);
                catch ME
                    switch ME.identifier
                    case 'SimulinkPartitioning:Actions:InvalidPartitionExecutionOrderPriorityConflict'
                        MSLDiagnostic('autosarstandard:importer:CompositionViolateRateMonotonicPolicy').reportAsWarning;
                    otherwise
                        rethrow(ME)
                    end
                end
            end

            if autosar.validation.ExportFcnValidator.isExportFcn(this.ModelName)


                this.TaskConnectivityGraph.assignInputPortPrioritiesForModel();
            end
        end
    end

    methods(Access=private)
        function partition=findPartitionForRootSlEntryPointFunction(this,rootSlEntryPointFunction,swcName)

            partitions=this.TaskConnectivityGraph.getSortedChildTasks('');
            hasKnownLimitationsCausingEmptyD1=this.hasD1Limitation();
            for i=1:length(partitions)
                if strcmp(partitions{i},'D1')&&hasKnownLimitationsCausingEmptyD1


                    continue
                end

                if this.TaskConnectivityGraph.getIsSlFunc(partitions{i})

                    continue
                end

                [mappedRootSlEntryPointFunction,mappedSwcName]=this.getRootSlEntryPointFunctionForPartition(partitions{i});


                if strcmp(mappedSwcName,swcName)&&...
                    (strcmp(mappedRootSlEntryPointFunction,rootSlEntryPointFunction)||...
                    strcmp(mappedRootSlEntryPointFunction,'Periodic')&&strcmp(rootSlEntryPointFunction,'Periodic:D1')||...
                    strcmp(mappedRootSlEntryPointFunction,'Periodic:D1')&&strcmp(rootSlEntryPointFunction,'Periodic'))
                    partition=partitions{i};
                    return
                end
            end


            if~autosar.timing.ScheduleEditorArch.isEntryPointFunctionSupported(swcName,rootSlEntryPointFunction)
                partition='';
                return
            end

            assert(false,'Could not find partition for root entry-point function %s of swc %s',rootSlEntryPointFunction,swcName);
        end

        function[rootSlEntryPointFunction,swcName]=getRootSlEntryPointFunctionForPartition(this,partition)


            if slfeature('SoftwareModelingAutosar')>0

                zcModel=get_param(this.ModelName,'SystemComposerModel');
                rootArch=zcModel.Architecture.getImpl();
                runnables=rootArch.getTrait(...
                systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).getFunctionsOfType(...
                systemcomposer.architecture.model.swarch.FunctionType.OSFunction);
                for i=1:length(runnables)
                    if isequal(runnables(i).p_Name,partition)
                        swcName=runnables(i).calledFunctionParent.p_Name;
                        swcHandle=systemcomposer.utils.getSimulinkPeer(runnables(i).calledFunctionParent);
                        swcModelName=get_param(swcHandle,'ModelName');
                        swcExecutionList=autosar.timing.ScheduleEditorComponent(swcModelName);
                        swPartition=runnables(i).calledFunction.p_Name;
                        if strcmp(swPartition,'D[inherited]')
                            swPartition='D1';
                        elseif contains(swPartition,'[')

                            swPartition=extractBefore(swPartition,'[');
                        end
                        rootSlEntryPointFunction=swcExecutionList.getSlEntryPointFunctionForPartition(swPartition);
                        break;
                    end
                end
            else

                SIDs=this.TaskConnectivityGraph.getSourceBlockSIDs(partition);
                assert(length(SIDs)==1,...
                'Partition %s is not mapped to one source block SIDs',partition);
                handle=Simulink.ID.getHandle([this.ModelName,':',SIDs{1}]);
                swcName=get_param(handle,'Name');
                swcPartition=extractAfter(partition,'.');
                swcModelName=get_param(handle,'ModelName');
                swcExecutionList=autosar.timing.ScheduleEditorComponent(swcModelName);
                rootSlEntryPointFunction=swcExecutionList.getSlEntryPointFunctionForPartition(swcPartition);
            end
        end

        function res=hasD1Limitation(this)
            partitions=this.TaskConnectivityGraph.getChildTasks('');
            res=any(strcmp(partitions,'D1'))&&...
            (this.hasOnlyUncalledSimulinkFunctions()||...
            this.hasOnlyAperiodicExportFunctionsAndSLFunctions()||...
            this.hasBranchedInputs()||...
            this.hasUnconnectedInports()||...
            this.hasBusElementButNoCorrespondingPort()||...
            this.hasVariantSourceDanglingPorts()||...
            ~this.periodicRatesIntegerMultipleOfEachOther());
        end

        function res=hasPartitionsWithNoSIDAndComponentsWithNoRate(this)


            res=false;
            partitions=this.TaskConnectivityGraph.getChildTasks('');
            partitionWithNoSID=arrayfun(@(x)(...
            isempty(this.TaskConnectivityGraph.getSourceBlockSIDs(partitions{x}))),...
            1:length(partitions));
            if~any(partitionWithNoSID)
                return
            end


            mdlReferences=Simulink.findBlocksOfType(this.ModelName,'ModelReference');
            for i=1:length(mdlReferences)
                modelName=get_param(mdlReferences(i),'ModelName');
                [hasExplicitRate,rate]=this.hasExplicitPeriodicRate(modelName);
                if hasExplicitRate
                    continue
                end

                MSLDiagnostic('autosarstandard:exporter:UnableToExportEOCNoRate',...
                getfullname(mdlReferences(i)),modelName,rate).reportAsWarning;
                res=true;
            end
        end

        function res=hasOnlyUncalledSimulinkFunctions(this)



            res=false;


            mdlReferences=Simulink.findBlocksOfType(this.ModelName,'ModelReference');
            for i=1:length(mdlReferences)
                modelName=get_param(mdlReferences(i),'ModelName');
                if this.hasOnlySimulinkFunctions(modelName)&&...
                    this.hasUncalledSimulinkFunctions(mdlReferences(i))
                    res=true;
                    return
                end
            end



            handle=Simulink.findBlocks(this.ModelName,'MaskType','NVRAM Service Component');
            if~isempty(handle)&&this.hasUncalledSimulinkFunctions(handle)
                res=true;
                return
            end
            handle=Simulink.findBlocks(this.ModelName,'MaskType','NVRAM DSM Controller');
            if~isempty(handle)&&this.hasUncalledSimulinkFunctions(handle)
                res=true;
                return
            end
        end

        function res=hasVariantSourceDanglingPorts(this)




            res=false;
            mdlReferences=Simulink.findBlocksOfType(this.ModelName,'ModelReference');
            for i=1:length(mdlReferences)
                modelName=get_param(mdlReferences(i),'ModelName');
                options=Simulink.FindOptions("LookUnderMasks","All","FollowLinks",true);
                hasVariantSourceAndActivationTimeUpdateDiagram=...
                Simulink.findBlocks(modelName,'BlockType','VariantSource',...
                'VariantActivationTime','update diagram',options);
                if~isempty(hasVariantSourceAndActivationTimeUpdateDiagram)
                    res=true;
                    return
                end
            end
        end

        function res=hasUnconnectedInports(this)



            res=false;
            ports=find_system(this.ModelName,'FindAll','on','type','port','PortType','inport');
            if isempty(ports)
                return;
            end
            lineHandles=get_param(ports,'Line');
            if~iscell(lineHandles)
                lineHandles={lineHandles};
            end
            res=any(cellfun(@(x)isequal(x,-1),lineHandles));
        end

        function res=periodicRatesIntegerMultipleOfEachOther(this)



            res=true;



            periodicRates=this.getPeriodicRatesExceptEmptyBaseRate();


            unique(periodicRates);
            sort(periodicRates);

            if length(periodicRates)<2
                return
            end


            for i=2:length(periodicRates)
                if~this.isIntegerMultipleOfEachOther(periodicRates(1),periodicRates(i))
                    res=false;
                    return
                end
            end
        end

        function rates=getPeriodicRatesExceptEmptyBaseRate(this)
            rates=[];
            partitions=this.TaskConnectivityGraph.getChildTasks('');
            for i=1:length(partitions)
                partition=partitions{i};
                if strcmp(partition,'D1')
                    continue
                end

                partitionType=this.TaskConnectivityGraph.getPartitionTypeString(partition);
                if strcmp(partitionType,'aperiodic')||...
                    strcmp(partitionType,'aperiodic-async')
                    continue
                end

                newRate=this.TaskConnectivityGraph.getRateSpec(partition);
                assert(length(newRate)==1,'Offsets are not supported in AUTOSAR');
                rates=[rates,newRate];%#ok<AGROW>
            end
        end

        function res=hasBranchedInputs(this)



            res=false;


            lines=find_system(this.ModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','type','line');
            mdlReferences=Simulink.findBlocksOfType(this.ModelName,'ModelReference');
            for i=1:length(mdlReferences)
                modelName=get_param(mdlReferences(i),'ModelName');
                lines=[lines;find_system(modelName,'FindAll','on','type','line')];%#ok
            end


            lineDestinations=get_param(lines,'DstBlockHandle');
            if~iscell(lineDestinations)
                lineDestinations={lineDestinations};
            end
            branch=cellfun(@(x)(...
            length(x)>1),lineDestinations);
            if any(branch)
                res=true;
                return
            end





            ports=find_system(this.ModelName,'FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'type','port','PortType','inport');
            signalHierarchies=get(ports,'SignalHierarchy');
            if~iscell(signalHierarchies)
                signalHierarchies={signalHierarchies};
            end
            branch=cellfun(@(x)(...
            ~isempty(x)&&~isempty(x.Children)),signalHierarchies);
            if any(branch)
                res=true;
                return
            end
        end

        function res=hasBusElementButNoCorrespondingPort(this)




            res=false;
            mdlReferences=Simulink.findBlocksOfType(this.ModelName,'ModelReference');
            for i=1:length(mdlReferences)
                modelName=get_param(mdlReferences(i),'ModelName');
                bepH=autosar.simulink.bep.Utils.findBusElementPortsAtRoot(modelName);



                if length(bepH)>1
                    [~,index]=unique(get_param(bepH,'PortName'));
                    bepH=bepH(index);
                end


                for j=1:length(bepH)
                    portName=get_param(bepH(j),'PortName');
                    elements=autosar.simulink.bep.Utils.getElements(bepH(j));
                    noCorrespondingBlock=arrayfun(@(x)(...
                    isempty(Simulink.findBlocks(modelName,'PortName',portName,'Element',elements{x}))),...
                    1:length(elements));
                    if any(noCorrespondingBlock)
                        res=true;
                        return
                    end
                end
            end
        end

        function res=hasOnlyAperiodicExportFunctionsAndSLFunctions(this)




            res=true;
            partitions=this.TaskConnectivityGraph.getChildTasks('');
            for i=1:length(partitions)
                partitionType=this.TaskConnectivityGraph.getPartitionTypeString(partitions{i});
                if~strcmp(partitionType,'aperiodic')&&...
                    ~strcmp(partitions{i},'D1')
                    res=false;
                    return
                end
            end
        end

        function res=hasNewExplicitSampleTime(this)



            res=true;
            sampleTime=get_param(this.ModelName,'FixedStep');
            if strcmp(sampleTime,'auto')
                res=false;
                return
            end




            if this.hasOnlyAperiodicExportFunctionsAndSLFunctions()
                res=false;
                return
            end

            mdlReferences=Simulink.findBlocksOfType(this.ModelName,'ModelReference');
            for i=1:length(mdlReferences)
                modelName=get_param(mdlReferences(i),'ModelName');
                tcg=sltp.TaskConnectivityGraph(modelName);
                partitions=tcg.getChildTasks('');
                hasRate=arrayfun(@(x)(...
                strcmp(tcg.getRateSpecString(partitions{x}),sampleTime)),1:length(partitions));
                if any(hasRate)
                    res=false;
                    return
                end
            end

            MSLDiagnostic('autosarstandard:exporter:UnableToExportEOCNewRate',...
            this.ModelName).reportAsWarning;
        end
    end

    methods(Access=private,Static)
        function res=hasUncalledSimulinkFunctions(handle)
            res=false;
            functionCatalog=Simulink.FunctionGraphCatalog(handle,'ListFunctionsAndCallers');
            for i=1:length(functionCatalog)
                if isempty(functionCatalog(i).CallerBlocks)
                    res=true;
                    return
                end
            end
        end

        function res=hasOnlySimulinkFunctions(componentReferenceName)
            tcg=sltp.TaskConnectivityGraph(componentReferenceName);
            partitions=tcg.getChildTasks('');
            res=~isempty(partitions);
            for i=1:length(partitions)
                if~strcmp(tcg.getPartitionTypeString(partitions{i}),'simulink-function')
                    res=false;
                end
            end
        end

        function[res,rate]=hasExplicitPeriodicRate(componentReferenceName)
            tcg=sltp.TaskConnectivityGraph(componentReferenceName);
            partitions=tcg.getChildTasks('');
            if length(partitions)~=1||...
                ~strcmp(tcg.getPartitionTypeString(partitions{1}),'implicit-periodic')
                res=true;
                rate=-1;
                return
            end

            rate=tcg.getRateSpecString(partitions{1});
            hasBlocksWithRate=~isempty(Simulink.findBlocks(componentReferenceName,'SampleTime',rate))||...
            ~isempty(Simulink.findBlocks(componentReferenceName,'SystemSampleTime',rate));
            hasModelWithRate=~strcmp(get_param(componentReferenceName,'FixedStep'),'auto');
            res=hasBlocksWithRate||hasModelWithRate;
        end

        function isSupported=isEntryPointFunctionSupported(swcName,rootSlEntryPointFunction)
            functionType=autosar.api.getSimulinkMapping.findFunctionTypeForSlEntryPointFunction(swcName,rootSlEntryPointFunction);
            switch functionType
            case 'SimulinkFunction'


                MSLDiagnostic('autosarstandard:importer:SLFunctionsNotSupportedInScheduleEditor').reportAsWarning;
                isSupported=false;
            case 'Initialize'
                MSLDiagnostic('autosarstandard:importer:InitNotSupportedInScheduleEditor').reportAsWarning;
                isSupported=false;
            otherwise
                isSupported=true;
            end
        end

        function res=isIntegerMultipleOfEachOther(rate1,rate2)
            assert(0.0<rate1&&isfinite(rate1));
            assert(0.0<rate2&&isfinite(rate2));

            res=autosar.timing.ScheduleEditorArch.isMultipleOf(rate1,rate2);
        end
    end

    methods(Access=public,Static)
        function[res,m]=isMultipleOf(r1,r2)
            if(r2<r1&&~autosar.timing.ScheduleEditorArch.almostEqual(r1,r2))
                res=false;
                return
            end

            m=floor(r2/r1+0.5);
            res=autosar.timing.ScheduleEditorArch.almostEqual(r2,r1*m);
        end

        function res=almostEqual(r1,r2)
            if r1==r2
                res=true;
            elseif(r1*r2<=0)
                res=false;
            elseif((isinf(r1)&&r1>0.0)||...
                (isinf(r2)&&r2>0.0))
                res=false;
            elseif isfinite(r1/r2)
                tol=1E-8;
                [N,D]=rat(r1/r2,tol);
                res=(N==D);
            else
                res=false;
            end
        end
    end
end


