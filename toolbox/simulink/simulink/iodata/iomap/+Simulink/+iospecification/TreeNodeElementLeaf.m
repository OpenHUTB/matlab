classdef TreeNodeElementLeaf<Simulink.iospecification.CompatibleInterface




    properties
treeNode
Handle
    end

    methods


        function obj=BusObjectElementLeaf(treeNodeIn,handleIn)
            obj.treeNode=treeNodeIn;
            obj.Handle=handleIn;
        end


        function IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj)
            IS_VALID_INPUTVAR_TO_COMPARE=isa(inputVariableObj,'Simulink.iospecification.TimeseriesInput')||...
            isa(inputVariableObj,'Simulink.iospecification.TimetableInput')||isa(inputVariableObj,'Simulink.iospecification.GroundInput');

        end


        function outDataType=getDataType(obj)
            outDataType=Simulink.iospecification.RootInportBusElement.getTreeNodeDataType(obj.treeNode);
        end


        function outDims=getDimensions(obj)
            outDims=resolvePortDimension(obj);
        end


        function outSignalType=getSignalType(obj)
            outSignalType=Simulink.iospecification.RootInportBusElement.getTreeNodeSignalType(obj.treeNode);
        end


        function portDimValue=resolvePortDimension(obj)

            portDimsStr=Simulink.iospecification.RootInportBusElement.getTreeNodeDimensions(obj.treeNode);

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

end
