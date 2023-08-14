


classdef SubPort<handle


    properties(Access=public)


        PortID='';


        PortName='';


        hDataType=[];

        IsRequiredPort=false;

        PortType='';

        PortRegExp='';
        PortDirType=hdlturnkey.IOType.INOUT;


        MultipleAssignment=false;


        ExternalPortName='';


        DefaultValue=[];

    end

    properties(Access=protected)


        Assigned=false;


        AssignedPortMap=containers.Map();

    end

    properties(Constant,Access=protected)

        OptionalPostFix=' (optional)';

    end

    methods(Access=public)

        function obj=SubPort(portID)

            obj.PortID=portID;
        end

        function initilizePort(obj,portName,hDataType,isRequiredPort,...
            portType,portRegExp,portDirType)

            obj.PortName=portName;
            obj.hDataType=hDataType;
            obj.IsRequiredPort=isRequiredPort;
            obj.PortType=portType;
            obj.PortRegExp=portRegExp;
            obj.PortDirType=portDirType;
        end

        function portIDStr=getPortIDDispStr(obj)

            if~obj.IsRequiredPort
                portIDStr=obj.appendOptionalPostFix(obj.PortID);
            else
                portIDStr=obj.PortID;
            end
        end


        function isa=isAssigned(obj)
            isa=obj.Assigned;
        end
        function cleanPortAssignment(obj)
            obj.Assigned=false;
            obj.AssignedPortMap=containers.Map();
        end
        function setPortAssignment(obj,portName,hTableMap)
            obj.Assigned=true;
            if~obj.isAssignedPortName(portName)
                hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
                obj.AssignedPortMap(portName)=hIOPort;
            end
        end
        function setCodeGenerationPortAssignment(obj,portName,codegenIOPortList)
            obj.Assigned=true;
            if~obj.isAssignedPortName(portName)
                hIOPort=codegenIOPortList.getIOPort(portName);
                obj.AssignedPortMap(portName)=hIOPort;
            end
        end
        function removePortAssignment(obj,portName)
            if obj.AssignedPortMap.isKey(portName)
                obj.AssignedPortMap.remove(portName);
            end
            if obj.AssignedPortMap.length==0
                obj.Assigned=false;
            end
        end

        function isa=isAssignedPortName(obj,portName)
            isa=obj.AssignedPortMap.isKey(portName);
        end
        function portNameList=getAssignedPortNameList(obj)

            portNameList=obj.AssignedPortMap.keys;
        end

        function portName=getAssignedPortName(obj)

            portName='';
            if obj.isAssigned
                obj.validateSingleAssignment;
                portNameList=obj.getAssignedPortNameList;
                portName=portNameList{1};
            end
        end
        function hIOPort=getAssignedPort(obj)

            hIOPort=[];
            if obj.isAssigned
                obj.validateSingleAssignment;
                portName=getAssignedPortName(obj);
                hIOPort=obj.AssignedPortMap(portName);
            end
        end

        function[portWidth,portDimension,isComplex]=getAssignedPortWidth(obj)

            portWidth=0;
            portDimension=1;
            isComplex=false;
            if obj.isAssigned

                obj.validateSingleAssignment;
                hIOPort=obj.getAssignedPort;
                portWidth=hIOPort.WordLength;
                isComplex=hIOPort.isComplex;
                if hIOPort.isVector
                    portDimension=double(hIOPort.Dimension);
                end
            end
        end
    end

    methods(Access=protected)


        function validateSingleAssignment(obj)
            if obj.MultipleAssignment
                error(message('hdlcommon:interface:SubPortSingleAssignment'));
            end
        end


        function subPortIDStr=appendOptionalPostFix(obj,subPortID)

            subPortIDStr=sprintf('%s%s',subPortID,obj.OptionalPostFix);
        end

    end
end


