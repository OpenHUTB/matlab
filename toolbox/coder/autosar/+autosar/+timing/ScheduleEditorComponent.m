classdef ScheduleEditorComponent<autosar.timing.ExecutionList





    properties(Access=private)
        TaskConnectivityGraph;
    end

    methods
        function this=ScheduleEditorComponent(modelName)
            if~autosar.api.Utils.isMappedToComponent(modelName)
                assert(false,'%s is not mapped to a component',modelName);
            end

            this@autosar.timing.ExecutionList(modelName);
            this.TaskConnectivityGraph=sltp.TaskConnectivityGraph(modelName);
        end

        function slEntryPointFunctions=getExecutionOrder(this)



            partitions=this.TaskConnectivityGraph.getSortedChildTasks('');
            slEntryPointFunctions=strings(1,length(partitions));
            for i=1:length(partitions)
                partitionName=partitions{i};
                slEntryPointFunction=this.getSlEntryPointFunctionForPartition(partitionName);
                slEntryPointFunctions(i)=slEntryPointFunction;
            end
        end

        function setExecutionOrder(this,rootSlEntryPointFunctions,~)


            for i=1:length(rootSlEntryPointFunctions)
                partition=this.findPartitionForSlEntryPointFunction(rootSlEntryPointFunctions{i});
                if isempty(partition)
                    return
                end

                this.TaskConnectivityGraph.setOrderIndex(partition,i-1);
            end

            if autosar.validation.ExportFcnValidator.isExportFcn(this.ModelName)


                this.TaskConnectivityGraph.assignInputPortPrioritiesForModel();
            end
        end

        function slEntryPointFunction=getSlEntryPointFunctionForPartition(this,partitionName)


            partitionType=this.TaskConnectivityGraph.getPartitionTypeString(partitionName);
            functionType=this.getSlEntryPointFunctionTypeForPartitionType(partitionType,partitionName);
            slEntryPointFunction=[functionType,':',partitionName];
        end
    end

    methods(Access=private)
        function functionType=getSlEntryPointFunctionTypeForPartitionType(this,partitionType,partitionName)
            switch partitionType
            case 'aperiodic'


                partitionName=autosar.api.getSimulinkMapping.escapeSimulinkName(partitionName);
                functionType=...
                autosar.api.getSimulinkMapping.findFunctionTypeForSlEntryPointFunctionWithoutPrefix(this.ModelName,partitionName);
                if~isempty(functionType)
                    return
                end


                functionType='Partition';
            case{'explicit-periodic','aperiodic-async'}
                functionType='Partition';
            case 'simulink-function'
                functionType='SimulinkFunction';
            case{'base','implicit-periodic'}
                functionType='Periodic';
            case 'async'
                functionType='ExportedFunction';
            otherwise
                assert(false,'Could not find function type for partition type %s',partitionType)
            end
        end

        function partition=findPartitionForSlEntryPointFunction(this,SlEntryPointFunction)
            functionType=autosar.api.getSimulinkMapping.findFunctionTypeForSlEntryPointFunction(this.ModelName,SlEntryPointFunction);
            switch functionType
            case{'Initialize','Terminate','Reset'}

                MSLDiagnostic('autosarstandard:importer:InitNotSupportedInScheduleEditor').reportAsWarning;
                partition='';
                return
            otherwise
                partition=autosar.api.internal.MappingFinder.getSlIdentifierForSlEntryPointFunction(SlEntryPointFunction,functionType);
            end
        end
    end
end


