


classdef IOPortListBase<handle


    properties

        InputPortNameList={};
        OutputPortNameList={};


        IOPortMap=[];
    end

    methods

        function obj=IOPortListBase()

            obj.IOPortMap=containers.Map();
        end

        function clearIOPortList(obj)
            obj.IOPortMap=containers.Map();
            obj.InputPortNameList={};
            obj.OutputPortNameList={};
        end


        function addIOPort(obj,hIOPort)
            switch hIOPort.PortType
            case hdlturnkey.IOType.IN
                obj.InputPortNameList{end+1}=hIOPort.PortName;
            case hdlturnkey.IOType.OUT
                obj.OutputPortNameList{end+1}=hIOPort.PortName;



            end

            obj.IOPortMap(hIOPort.PortName)=hIOPort;
        end

        function hIOPort=getIOPort(obj,portName)
            hIOPort=obj.IOPortMap(portName);
        end


        function isValid=isValidPortName(obj,portName)
            isValid=obj.IOPortMap.isKey(portName);
        end


        function hasVector=hasVectorPortInBusPort(obj,hDataType)
            hasVector=false;
            if hDataType.isBusType


                memberIDList=hDataType.getMemberIDList;
                for idx=1:numel(memberIDList)
                    hMemberDataType=hDataType.getMemberType(memberIDList{idx});


                    hasVector=hasVector||obj.hasVectorPortInBusPort(hMemberDataType);
                end
            elseif hDataType.isVector
                hasVector=true;
            else
                hasVector=false;
            end
        end


        function hasVector=hasVectorPort(obj)


            hasVector=false;
            for ii=1:length(obj.InputPortNameList)
                portName=obj.InputPortNameList{ii};
                hIOPort=obj.getIOPort(portName);
                if hIOPort.isBus
                    hasVector=obj.hasVectorPortInBusPort(hIOPort.Type);
                elseif hIOPort.isVector
                    hasVector=true;
                end
                if hasVector
                    break;
                end
            end


            if~hasVector
                for ii=1:length(obj.OutputPortNameList)
                    portName=obj.OutputPortNameList{ii};
                    hIOPort=obj.getIOPort(portName);
                    if hIOPort.isBus
                        hasVector=obj.hasVectorPortInBusPort(hIOPort.Type);
                    elseif hIOPort.isVector
                        hasVector=true;
                    end
                    if hasVector
                        break;
                    end
                end
            end
        end

    end

end