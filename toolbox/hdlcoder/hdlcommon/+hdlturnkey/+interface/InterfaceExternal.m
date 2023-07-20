




classdef InterfaceExternal<hdlturnkey.interface.InterfaceCustomBase&...
    hdlturnkey.interface.IPWorkflowBase


    properties


    end

    methods

        function obj=InterfaceExternal()



            interfaceID='External Port';
            obj=obj@hdlturnkey.interface.InterfaceCustomBase(interfaceID);

        end

    end


    methods


        function validateCell=validateFullTable(obj,validateCell,hTable)

            dutPortNames=hTable.hTableMap.getConnectedPortList(obj.InterfaceID);
            for ii=1:length(dutPortNames)
                dutPortName=dutPortNames{ii};
                bitRangeStr=hTable.hTableMap.getBitRangeStr(dutPortName);
                if~obj.IsGenericIP&&isempty(bitRangeStr)
                    msgObject=message('hdlcommon:workflow:FPGAPinNotSpecifiedWarning',...
                    dutPortName);
                    validateCell{end+1}=hdlvalidatestruct('Warning',msgObject);%#ok<AGROW>
                end
            end
        end

        function validatePortForInterface(obj,hIOPort,~)


            if hIOPort.isSingle
                error(message('hdlcommon:workflow:SinglePortUnsupported',obj.InterfaceID,hIOPort.PortName));
            end


            portWidth=hIOPort.WordLength;
            portDimension=hIOPort.Dimension;



            if(portWidth*portDimension>65535)
                error(message('hdlcommon:workflow:VectorPortBitWidthLargerThan65535Bits',...
                obj.InterfaceID,portWidth*portDimension,hIOPort.PortName));
            end
        end


        function validatePortForInterfaceShared(~,hIOPort,~,interfaceStr)



            if hIOPort.isHalf
                error(message('hdlcommon:workflow:HalfPortUnsupported',interfaceStr,hIOPort.PortName));
            end




            if hIOPort.isBus
                error(message('hdlcommon:workflow:UnsupportedBusPort',...
                interfaceStr,hIOPort.PortName));
            end



            if hIOPort.isComplex
                error(message('hdlcommon:workflow:UnsupportedComplexPort',interfaceStr,hIOPort.PortName));
            end

        end
    end


    methods
        function fpgaPin=parseBitRangeStr(obj,hIOPort,bitRangeStr)



            if obj.IsGenericIP&&~isempty(bitRangeStr)
                error(message('hdlcommon:workflow:FPGAPinNotAllowed'));
            end
            if isempty(bitRangeStr)

                fpgaPin={};
            else

                fpgaPin=parseBitRangeStr@hdlturnkey.interface.InterfaceCustomBase(...
                obj,hIOPort,bitRangeStr);
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

        function isa=isIPExternalInterface(obj)%#ok<MANU>
            isa=true;
        end

        function isa=isIPCoreClockNeeded(~)
            isa=false;
        end


        function generatePCoreQsysTCL(obj,fid,hElab)


            fprintf(fid,'## External Ports\n');


            dutPortNames=hElab.hTurnkey.hTable.hTableMap.getConnectedPortList(obj.InterfaceID);

            for ii=1:length(dutPortNames)
                dutPortName=dutPortNames{ii};
                hIOPort=hElab.hTurnkey.hTable.hIOPortList.getIOPort(dutPortName);

                postCodeGenDutPortNames=hElab.getCodegenPortNameList(dutPortName);
                postCodeGenDutPortName=postCodeGenDutPortNames{1};


                hDUT=hElab.hDUTLayer;
                hCodeGenIOPort=hDUT.getCodegenIOPort(postCodeGenDutPortName);


                portWidth=hIOPort.WordLength;
                portDimension=hIOPort.Dimension;


                if hCodeGenIOPort.Bidirectional
                    conduitPortType=hdlturnkey.IOType.INOUT;
                else
                    conduitPortType=hIOPort.PortType;
                end
                hdlturnkey.tool.generateQsysTclConduitPort(fid,...
                postCodeGenDutPortName,portWidth*portDimension,conduitPortType);
            end
        end


        function generatePCoreLiberoTCL(obj,fid,hElab,topModuleFile,~)


            fprintf(fid,'## External Ports\n');


            dutPortNames=hElab.hTurnkey.hTable.hTableMap.getConnectedPortList(obj.InterfaceID);

            for ii=1:length(dutPortNames)
                dutPortName=dutPortNames{ii};
                hIOPort=hElab.hTurnkey.hTable.hIOPortList.getIOPort(dutPortName);

                postCodeGenDutPortNames=hElab.getCodegenPortNameList(dutPortName);
                postCodeGenDutPortName=postCodeGenDutPortNames{1};


                hDUT=hElab.hDUTLayer;
                hCodeGenIOPort=hDUT.getCodegenIOPort(postCodeGenDutPortName);


                portWidth=hIOPort.WordLength;
                portDimension=hIOPort.Dimension;


                if hCodeGenIOPort.Bidirectional
                    conduitPortType=hdlturnkey.IOType.INOUT;
                else
                    conduitPortType=hIOPort.PortType;
                end
                hdlturnkey.tool.generateLiberoTclConduitPort(fid,...
                postCodeGenDutPortName,portWidth*portDimension,conduitPortType,topModuleFile);
            end
        end

        function generatePCoreMPD(obj,fid,hElab)



            fprintf(fid,'## External Ports\n');


            dutPortNames=hElab.hTurnkey.hTable.hTableMap.getConnectedPortList(obj.InterfaceID);


            for ii=1:length(dutPortNames)
                dutPortName=dutPortNames{ii};
                postCodeGenDutPortNames=hElab.getCodegenPortNameList(dutPortName);
                postCodeGenDutPortName=postCodeGenDutPortNames{1};
                hIOPort=hElab.hTurnkey.hTable.hIOPortList.getIOPort(dutPortName);
                portWidth=hIOPort.WordLength;
                portDimension=hIOPort.Dimension;

                hdlturnkey.tool.generateEDKMPDPort(fid,...
                postCodeGenDutPortName,portWidth*portDimension,hIOPort.PortType);

            end
            fprintf(fid,'\n');

        end

    end

    methods(Static)

        function[isa,hIFCell,hIOPortCell]=isExternalInterfaceAssigned(hTurnkey)

            isa=false;
            hIOPortCell={};
            hIFCell={};
            interfaceIDList=hTurnkey.hTable.hTableMap.getAssignedInterfaces;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hTurnkey.getInterface(interfaceID);
                if hInterface.isIPInterface&&hInterface.isIPExternalInterface
                    portNames=hTurnkey.hTable.hTableMap.getConnectedPortList(interfaceID);
                    isa=true;
                    hIFCell{end+1}=hInterface;%#ok<AGROW>
                    for ii=1:length(portNames)
                        hIOPortCell{end+1}=hTurnkey.hTable.hIOPortList.getIOPort(portNames{ii});
                    end
                end
            end
        end
    end
end


