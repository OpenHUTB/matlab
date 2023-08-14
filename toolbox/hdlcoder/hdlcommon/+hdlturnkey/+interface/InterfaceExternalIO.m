












classdef InterfaceExternalIO<hdlturnkey.interface.InterfaceExternalIOBase&...
    hdlturnkey.interface.IPWorkflowBase


    properties

    end

    methods

        function obj=InterfaceExternalIO(varargin)


            obj=obj@hdlturnkey.interface.InterfaceExternalIOBase(varargin{:});

        end

    end


    methods



        function validatePortForInterfaceShared(obj,hIOPort,~,interfaceStr)



            if hIOPort.isHalf
                error(message('hdlcommon:workflow:HalfPortUnsupported',interfaceStr,hIOPort.PortName));
            end


            if hIOPort.isSingle
                error(message('hdlcommon:workflow:SinglePortUnsupported',interfaceStr,hIOPort.PortName));
            end


            if hIOPort.isBus
                error(message('hdlcommon:workflow:UnsupportedBusPort',...
                interfaceStr,hIOPort.PortName));
            end


            portDirType=hIOPort.PortType;
            interfaceDirType=obj.InterfaceType;
            if interfaceDirType~=hdlturnkey.IOType.INOUT&&portDirType~=interfaceDirType
                error(message('hdlcommon:interface:PortTypeNotMatch',interfaceStr,...
                downstream.tool.getPortDirTypeStr(interfaceDirType),...
                downstream.tool.getPortDirTypeStr(portDirType),hIOPort.PortName));
            end
        end
    end


    methods

    end


    methods

    end


    methods

    end


    methods

    end


    methods

    end



    methods

        function isa=isIPExternalInterface(obj)%#ok<MANU>
            isa=true;
        end
        function isa=isIPExternalIOInterface(obj)%#ok<MANU>
            isa=true;
        end

        function generatePCoreQsysTCL(obj,fid,hElab)



            fprintf(fid,'## External Ports\n');

            if~obj.isINOUTInterface



                portType=obj.InterfaceType;
                if(portType==hdlturnkey.IOType.INOUT)
                    if isempty(obj.DutInputPortList)
                        portType=hdlturnkey.IOType.OUT;
                    else
                        portType=hdlturnkey.IOType.IN;
                    end
                end
                hdlturnkey.tool.generateQsysTclConduitPort(fid,...
                obj.PortName,obj.PortWidth,portType);
            else

                hdlturnkey.tool.generateQsysTclConduitPort(fid,obj.InportNames{1},...
                obj.InOutSplitInputPortWidth,hdlturnkey.IOType.IN);

                hdlturnkey.tool.generateQsysTclConduitPort(fid,obj.OutportNames{1},...
                obj.InOutSplitOutputPortWidth,hdlturnkey.IOType.OUT);
            end

        end

        function generatePCoreLiberoTCL(obj,fid,hElab,topModuleFile)



            fprintf(fid,'## External Ports\n');

            if~obj.isINOUTInterface



                portType=obj.InterfaceType;
                if(portType==hdlturnkey.IOType.INOUT)
                    if isempty(obj.DutInputPortList)
                        portType=hdlturnkey.IOType.OUT;
                    else
                        portType=hdlturnkey.IOType.IN;
                    end
                end
                hdlturnkey.tool.generateLiberoTclConduitPort(fid,...
                obj.PortName,obj.PortWidth,portType,topModuleFile);
            else

                hdlturnkey.tool.generateLiberoTclConduitPort(fid,obj.InportNames{1},...
                obj.InOutSplitInputPortWidth,hdlturnkey.IOType.IN,topModuleFile);

                hdlturnkey.tool.generateLiberoTclConduitPort(fid,obj.OutportNames{1},...
                obj.InOutSplitOutputPortWidth,hdlturnkey.IOType.OUT,topModuleFile);
            end

        end

        function generatePCoreMPD(obj,fid,~)



            fprintf(fid,'## External Ports\n');

            if~obj.isINOUTInterface



                portType=obj.InterfaceType;
                if(portType==hdlturnkey.IOType.INOUT)
                    if isempty(obj.DutInputPortList)
                        portType=hdlturnkey.IOType.OUT;
                    else
                        portType=hdlturnkey.IOType.IN;
                    end
                end
                hdlturnkey.tool.generateEDKMPDPort(fid,...
                obj.PortName,obj.PortWidth,portType);
            else

                hdlturnkey.tool.generateEDKMPDPort(fid,obj.InportNames{1},...
                obj.InOutSplitInputPortWidth,hdlturnkey.IOType.IN);

                hdlturnkey.tool.generateEDKMPDPort(fid,obj.OutportNames{1},...
                obj.InOutSplitOutputPortWidth,hdlturnkey.IOType.OUT);
            end
        end

        function isa=isIPCoreClockNeeded(~)
            isa=false;
        end

    end

    methods(Static)

        function[isa,hIFCell,hIOPortCell]=isExternalIOInterfaceAssigned(hTurnkey)

            isa=false;
            hIOPortCell={};
            hIFCell={};
            interfaceIDList=hTurnkey.hTable.hTableMap.getAssignedInterfaces;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hTurnkey.getInterface(interfaceID);
                if hInterface.isIPInterface&&hInterface.isIPExternalIOInterface
                    portNames=hTurnkey.hTable.hTableMap.getConnectedPortList(interfaceID);
                    isa=true;
                    hIFCell{end+1}=hInterface;%#ok<AGROW>
                    for i=1:length(portNames)
                        hIOPortCell{end+1}=hTurnkey.hTable.hIOPortList.getIOPort(portNames{i});
                    end
                end
            end
        end
    end
end


