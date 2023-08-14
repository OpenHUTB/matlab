classdef BusObjectElementLeaf<Simulink.iospecification.CompatibleInterface&Simulink.iospecification.AllowsPartial




    properties
Handle
BusEl
Block

        USE_COMPILED_PARAMS=false
    end

    methods


        function obj=BusObjectElementLeaf(elIn,blockH)
            obj.BusEl=elIn;
            obj.Handle=blockH;

        end


        function IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj)
            IS_VALID_INPUTVAR_TO_COMPARE=isa(inputVariableObj,'Simulink.iospecification.TimeseriesInput')||...
            isa(inputVariableObj,'Simulink.iospecification.TimetableInput')||isa(inputVariableObj,'Simulink.iospecification.GroundInput');

        end


        function outDataType=getDataType(obj)

            if~obj.USE_COMPILED_PARAMS

                outDataType=getDataTypeFromEl(obj);


                outDataType=formatIfEnum(obj,outDataType);
                return;
            end

            outDataType=getCompiledDataTypeFromPort(obj);
        end


        function outDims=getDimensions(obj)

            if~obj.USE_COMPILED_PARAMS
                outDims=resolvePortDimension(obj);
                return;
            end

            temp=get_param(obj.Handle,'CompiledPortDimensions');
            outDims=temp.Outport(2:end);
        end


        function outSignalType=getSignalType(obj)


            if~obj.USE_COMPILED_PARAMS
                outSignalType=getSignalTypeFromEl(obj);
                return;
            end


            temp=get_param(obj.Handle,'CompiledPortComplexSignals');

            if isempty(temp.Outport)
                return;
            end

            outSignalType=obj.getComplexString(temp.Outport);

        end


        function portDimValue=resolvePortDimension(obj)

            portDimsStr=getDimensionsFromEl(obj);

            if~isnumeric(portDimsStr)

                [portDimValue,~]=slResolve(portDimsStr,getfullname(obj.Handle));
                if~isempty(portDimValue)
                    portDimValue=resolvePortDimValue(obj,portDimValue,portDimsStr);
                else
                    portDimValue=portDimsStr;
                end
            else
                portDimValue=portDimsStr;
            end

        end


        function portDimVal=resolvePortDimValue(~,portDimVal,portDimValStr)

            if ischar(portDimVal)||isstring(portDimVal)
                portDimVal=str2num(portDimVal);
            elseif~isnumeric(portDimVal)
                portDimVal=portDimValStr;
            end

        end


        function portName=getPortName(obj)
            portName=get_param(obj.Handle,'Name');
        end
    end




    methods


        function dataType=getDataTypeFromEl(obj)
            dataType=obj.BusEl.DataType;
        end


        function dims=getDimensionsFromEl(obj)
            dims=obj.BusEl.Dimensions;
        end


        function signalType=getSignalTypeFromEl(obj)
            signalType=obj.BusEl.Complexity;
        end


    end
end
