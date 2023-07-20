classdef BusElTreeNodeBranch<Simulink.iospecification.BusElTreeNodeLeaf&Simulink.iospecification.BusTreeNodeCompatibleInterface





    methods


        function IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj)
            IS_VALID_INPUTVAR_TO_COMPARE=isa(inputVariableObj,'Simulink.iospecification.BusInput')||...
            isa(inputVariableObj,'Simulink.iospecification.TSArrayInput')||isa(inputVariableObj,'Simulink.iospecification.GroundInput');

        end


        function[IS_DATATYPE_COMPATIBLE,errMsg,sigDT,portDT]=isDataTypeCompatible(obj,inputVariableObj)
            IS_DATATYPE_COMPATIBLE.datatype.status=false;
            IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext='';
            portDT='struct';
            sigDT=inputVariableObj.getDataType;
            [IS_COMPATIBLE,errMsg]=isInputCompatibleWithTree(obj,obj.BusEl,inputVariableObj);

            IS_DATATYPE_COMPATIBLE.datatype.status=IS_COMPATIBLE;
        end


        function dims=getDimensionsFromEl(obj)

            dims=1;
        end


        function signalType=getSignalTypeFromEl(obj)
            signalType='real';
        end

    end

end
