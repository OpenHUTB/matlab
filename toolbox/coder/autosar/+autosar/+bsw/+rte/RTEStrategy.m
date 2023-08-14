classdef RTEStrategy<handle





    properties
ServiceFunctionName
    end

    methods(Access=public,Abstract)
        createRTE(this,simulinkFcnBlk,inArgHandles,outArgHandles,portDefArgument,compTypeData);
    end

    methods
        function this=RTEStrategy(serviceFunctionName)
            this.ServiceFunctionName=serviceFunctionName;
        end
    end

    methods(Access=public,Static)
        function rteStrategy=getRTEStrategy(serviceFunctionName)

            [operationName,bswCompType]=autosar.bsw.rte.RTEStrategy.parseOperationAndPortNames(...
            serviceFunctionName);


            physicalIdType='uint16';


            if autosar.bsw.DemDiagnosticMonitor.FunctionPrototypeWithEventIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.DemDiagnosticMonitor.FunctionPrototypeWithEventIdMap(operationName);
            elseif autosar.bsw.DemDiagnosticInfo.FunctionPrototypeWithEventIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.DemDiagnosticInfo.FunctionPrototypeWithEventIdMap(operationName);
            elseif autosar.bsw.DemEnableCondition.FunctionPrototypeWithIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.DemEnableCondition.FunctionPrototypeWithIdMap(operationName);
                physicalIdType='uint8';
            elseif autosar.bsw.DemEventAvailable.FunctionPrototypeWithEventIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.DemEventAvailable.FunctionPrototypeWithEventIdMap(operationName);
            elseif autosar.bsw.DemIUMPRDenominator.FunctionPrototypeWithIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.DemIUMPRDenominator.FunctionPrototypeWithIdMap(operationName);
            elseif autosar.bsw.DemIUMPRDenominatorCondition.FunctionPrototypeWithIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.DemIUMPRDenominatorCondition.FunctionPrototypeWithIdMap(operationName);
            elseif autosar.bsw.DemIUMPRNumerator.FunctionPrototypeWithIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.DemIUMPRNumerator.FunctionPrototypeWithIdMap(operationName);
            elseif autosar.bsw.DemOperationCycle.FunctionPrototypeWithIdMap.isKey(operationName)
                physicalIdType='uint8';
                serviceFcnPrototype=autosar.bsw.DemOperationCycle.FunctionPrototypeWithIdMap(operationName);
            elseif autosar.bsw.DemPfcCycleQualified.FunctionPrototypeMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.DemPfcCycleQualified.FunctionPrototypeWithIdMap(operationName);
            elseif autosar.bsw.DemStorageCondition.FunctionPrototypeWithIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.DemStorageCondition.FunctionPrototypeWithIdMap(operationName);
                physicalIdType='uint8';
            elseif autosar.bsw.FiM_ControlFunctionAvailable.FunctionPrototypeWithIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.FiM_ControlFunctionAvailable.FunctionPrototypeWithIdMap(operationName);
            elseif autosar.bsw.FiM_FunctionInhibition.FunctionPrototypeWithIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.FiM_FunctionInhibition.FunctionPrototypeWithIdMap(operationName);
            elseif autosar.bsw.NvMService.FunctionPrototypeWithBlockIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.NvMService.FunctionPrototypeWithBlockIdMap(operationName);
            elseif autosar.bsw.NvMAdmin.FunctionPrototypeWithBlockIdMap.isKey(operationName)
                serviceFcnPrototype=autosar.bsw.NvMAdmin.FunctionPrototypeWithBlockIdMap(operationName);
            else
                assert(false,'Unrecognized operation: %s',operationName);
            end
            serviceFcnPrototype=sprintf(serviceFcnPrototype,bswCompType);

            if strcmp(bswCompType,'NvM')&&...
                any(strcmp(operationName,{'ReadBlock','WriteBlock','EraseNvBlock','RestoreBlockDefaults'}))
                rteStrategy=autosar.bsw.rte.ManagedDatastoreRTEStrategy(serviceFunctionName,serviceFcnPrototype,physicalIdType,operationName);
            else
                rteStrategy=autosar.bsw.rte.CallerDispatchRTEStrategy(serviceFunctionName,serviceFcnPrototype,physicalIdType,bswCompType);
            end


        end

        function[operationName,portName]=parseOperationAndPortNames(fcnName)
            operationName='';
            portName='';

            pat='(?<PortName>\w+)\_(?<OperationName>\w+)';
            names=regexp(fcnName,pat,'names');
            if~isempty(names)
                operationName=names.OperationName;
                portName=names.PortName;
            end
        end
    end
end


