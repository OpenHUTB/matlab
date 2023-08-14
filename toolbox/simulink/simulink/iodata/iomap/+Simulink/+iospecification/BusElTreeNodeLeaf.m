classdef BusElTreeNodeLeaf<Simulink.iospecification.BusObjectElementLeaf









    methods


        function dataType=getDataTypeFromEl(obj)
            dataType=Simulink.iospecification.RootInportBusElement.getTreeNodeDataType(obj.BusEl);
        end


        function dims=getDimensionsFromEl(obj)
            dims=Simulink.iospecification.RootInportBusElement.getTreeNodeDimensions(obj.BusEl);
        end


        function signalType=getSignalTypeFromEl(obj)
            signalType=Simulink.iospecification.RootInportBusElement.getTreeNodeSignalType(obj.BusEl);
        end


        function[IS_DATATYPE_COMPATIBLE,errMsg,inputDataType,blockDT]=isDataTypeCompatible(obj,inputVariableObj)
            errMsg=[];
            blockDT=obj.getDataType();
            inputDataType=inputVariableObj.getDataType();
            IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext='';
            if contains(lower(blockDT),'inherit')
                IS_DATATYPE_COMPATIBLE.datatype.status=2;
                IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleInterfaceDataTypeInherit');
                IS_DATATYPE_COMPATIBLE.portspecific=DAStudio.message('sl_iospecification:inputvariables:compatibleInterfaceDataTypeInherit');
                return;
            end


            IS_DATATYPE_COMPATIBLE.datatype.status=isequal(blockDT,...
            inputDataType);

            IS_DATATYPE_COMPATIBLE.datatype.status=IS_DATATYPE_COMPATIBLE.datatype.status||...
            (strcmp(inputDataType,'logical')&&strcmp(blockDT,'boolean'));

            if~IS_DATATYPE_COMPATIBLE.datatype.status
                IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleMismatchDataType',blockDT,inputDataType);
            elseif IS_DATATYPE_COMPATIBLE.datatype.status==2
                IS_DATATYPE_COMPATIBLE.portspecific=DAStudio.message('sl_iospecification:inputvariables:leafSignalInherit');
            end
        end

    end


end
