


classdef VDMAPort<handle


    properties


        Assigned=false;


        ElabScheduled=false;

    end

    properties(Hidden=true)

        AssignedPortNameMap=[];


        ElabedSignalMap=[];
    end

    properties(Constant)

        PortDataStr='Video Data';
        PortSOFStr='Start of Frame';
        PortEOLStr='End of Line';
    end

    methods

        function obj=VDMAPort()

            cleanAssignment(obj);
        end

        function cleanAssignment(obj)

            obj.AssignedPortNameMap=containers.Map();
            obj.AssignedPortNameMap(obj.PortDataStr)='';
            obj.AssignedPortNameMap(obj.PortSOFStr)='';
            obj.AssignedPortNameMap(obj.PortEOLStr)='';

            obj.ElabedSignalMap=containers.Map();
            obj.ElabedSignalMap(obj.PortDataStr)=[];
            obj.ElabedSignalMap(obj.PortSOFStr)=[];
            obj.ElabedSignalMap(obj.PortEOLStr)=[];
        end

        function parseBitRangeStr(obj,bitRangeStr,interfaceID)



            if~obj.AssignedPortNameMap.isKey(bitRangeStr)
                error(message('hdlcommon:workflow:BitRangeNotSupported',interfaceID));
            end
        end

        function assignSubPort(obj,portName,subPortName)

            obj.AssignedPortNameMap(subPortName)=portName;
        end

        function subPort=allocateSubPort(obj,portName,interfaceID)
            assignedDataPort=obj.AssignedPortNameMap(obj.PortDataStr);
            if isempty(assignedDataPort)
                subPort=obj.PortDataStr;
            else

                error(message('hdlcommon:workflow:DupInterfaceAssignment',...
                interfaceID,portName,assignedDataPort));
            end
        end

        function dataPort=getAssignedDataPort(obj)
            dataPort=obj.AssignedPortNameMap(obj.PortDataStr);
        end

    end


end


