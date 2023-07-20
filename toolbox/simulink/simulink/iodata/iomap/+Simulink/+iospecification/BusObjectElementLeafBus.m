classdef BusObjectElementLeafBus<Simulink.iospecification.BusObjectElementLeaf&Simulink.iospecification.BusObjectCompatibleInterface




    properties


BusObject
BusObjectName
    end

    methods


        function obj=BusObjectElementLeafBus(elIn,blockH)
            obj=obj@Simulink.iospecification.BusObjectElementLeaf(elIn,blockH);
            obj.Handle=blockH;
            obj.BusObjectName=parseBusObjectNameFromDataType(obj,elIn.DataType);

            try
                obj.BusObject=getBusObjectDefinition(obj,obj.BusObjectName);
            catch ME
                throwAsCaller(ME);
            end
        end


        function IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj)
            IS_VALID_INPUTVAR_TO_COMPARE=isa(inputVariableObj,'Simulink.iospecification.BusInput')||...
            isa(inputVariableObj,'Simulink.iospecification.TSArrayInput')||isa(inputVariableObj,'Simulink.iospecification.GroundInput');

        end


        function outDataType=getDataType(obj)

            outDataType=obj.BusEl.DataType;
        end


        function outDims=getDimensions(obj)
            outDims=resolvePortDimension(obj);
        end


        function outSignalType=getSignalType(obj)
            outSignalType=obj.BusEl.Complexity;
        end


        function[BusObject,out2]=resolveParameterValue(obj,BusObjectName)
            blockH=obj.Handle;

            [BusObject,out2]=slResolve(BusObjectName,getfullname(blockH));
        end


        function[IS_DATATYPE_COMPATIBLE,errMsg,sigDT,portDT]=isDataTypeCompatible(obj,inputVariableObj)
            IS_DATATYPE_COMPATIBLE.datatype.status=false;

            portDT=obj.BusObjectName;
            sigDT=inputVariableObj.getDataType;
            [IS_COMPATIBLE,errMsg]=isInputCompatibleWithTree(obj,obj.BusObject,inputVariableObj);

            IS_DATATYPE_COMPATIBLE.datatype.status=IS_COMPATIBLE;
        end

    end

end
