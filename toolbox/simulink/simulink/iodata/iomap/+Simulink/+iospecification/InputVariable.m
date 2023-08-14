classdef InputVariable<Simulink.iospecification.CompatibleInterface





    properties
Name
Value
    end

    properties(Abstract,Hidden)
SupportedVarType
    end


    methods(Static)


        function bool=isa(varIn)

            filterDataTypeStruct.ALLOW_FOR_EACH=false;
            filterDataTypeStruct.ALLOW_EMPTY_DS=false;
            filterDataTypeStruct.ALLOW_EMPTY_TS=false;
            filterDataTypeStruct.ALLOW_DATASORE_MEM=false;

            bool=isSimulinkSignalFormat(varIn,filterDataTypeStruct);

        end

    end


    methods

        function obj=InputVariable(name,value)

            if isStringScalar(name)
                name=char(name);
            end

            if~ischar(name)
                DAStudio.error('sl_iospecification:inputvariables:badName');
            end

            obj.Name=name;

            if~isValidInputForm(obj,value)
                DAStudio.error('sl_iospecification:inputvariables:badVariable',obj.SupportedVarType);
            end

            obj.Value=value;
        end


        function diagnosticStruct=areCompatible(obj,inputPort)


            diagnosticStruct=areCompatible(inputPort,obj);
        end


        function ARE_DIMS_COMPATIBLE=areDimsCompatible(obj,inputPort)

            ARE_DIMS_COMPATIBLE=inputPort.areDimsCompatible(obj);

        end


        function[IS_DATATYPE_COMPATIBLE,errMsg]=isDataTypeCompatible(obj,inputPort)
            errMsg=[];
            IS_DATATYPE_COMPATIBLE=inputPort.isDataTypeCompatible(obj);
        end


        function IS_SIGNALTYPE_COMPATIBLE=isSignalTypeCompatible(obj,inputPort)
            IS_SIGNALTYPE_COMPATIBLE=inputPort.isSignalTypeCompatible(obj);
        end


        function dim=getDimension(~,dataSize)
            if length(dataSize)==1
                dim=dataSize;
                return;
            elseif length(dataSize)<=2
                dim=dataSize(2);
            else
                dim=dataSize(1:end-1);
            end
        end
    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=Simulink.iospecification.InputVariable.isa(varIn);
        end


        function dataProps=checkDataForFixedPoint(~,dataProps,numType)
            if isa(numType,'embedded.numerictype')
                dataProps=fixdt(numType);
            else
                dataProps=numType.tostring;
            end
        end

    end
end
