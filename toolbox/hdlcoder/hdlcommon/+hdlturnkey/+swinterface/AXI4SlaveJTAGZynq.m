


classdef AXI4SlaveJTAGZynq<hdlturnkey.swinterface.AXI4SlaveSoftware



    properties(Access=protected)
        DriverBlockLibrary='xilinxhdlvlib';
        AXI4SlaveWriteBlock='AXI Manager Write';
        AXI4SlaveReadBlock='AXI Manager Read';
    end


    properties(Access=protected)
    end


    methods

        function obj=AXI4SlaveJTAGZynq(varargin)

            obj=obj@hdlturnkey.swinterface.AXI4SlaveSoftware(varargin{:});
        end

    end



    methods(Static,Access=protected)
        function addHandshakeBlock(newBlockPath,ipCoreDeviceFile,copReadyOffset,copStrobeOffset)
            error(message('hdlcommon:workflow:NoHostinterfaceModel'));
        end
    end


    methods(Access=protected)
        function destBlockPath=addAXI4SlaveWriteBlock(obj,hModelGen,srcBlockPath,addrOffset,numAxiWriteBlocks,portName,hDataType,hAddr)
            if hDataType.isDouble
                portDim=hAddr.PortVectorSize;
            else
                portDim=hAddr.AddressLength;
            end
            if(portDim==1)
                HasStrobe='off';
            else
                HasStrobe='on';
            end
            driverBlock=[obj.DriverBlockLibrary,'/',obj.AXI4SlaveWriteBlock];



            hostTargetInterface=hModelGen.hTurnkey.hD.hIP.getHostTargetInterface;
            switch hostTargetInterface
            case 'JTAG AXI Manager (HDL Verifier)'
                AXIInterface='JTAG';
            case 'Ethernet AXI Manager (HDL Verifier)'
                AXIInterface='UDP';

            end
            driverBlockParams={...
            'Address',obj.convertOffsetToFullAddressStr(addrOffset,obj.hFPGAInterface.BaseAddress),...
            'BurstType','Increment',...
            'Priority',num2str(numAxiWriteBlocks),...
            'Interface',AXIInterface,...
            'HasStrobe',HasStrobe,...
            'StrobeAddress',obj.convertOffsetToFullAddressStr(hAddr.AddressStrobe,obj.hFPGAInterface.BaseAddress)};
            blockName=sprintf('AXI4SlaveWrite_%s',portName);
            destBlockPath=hModelGen.addLibraryBlock(driverBlock,'Right',srcBlockPath,driverBlockParams,'BlockName',blockName);
            obj.setDeviceAddress(hModelGen,AXIInterface);
        end

        function srcBlockPath=addAXI4SlaveReadBlock(obj,hModelGen,destBlockPath,addrOffset,dataTypeStr,portDim,numAxiReadBlocks,portName,hDataType,hAddr)
            if(portDim==1)
                HasStrobe='off';
            else
                HasStrobe='on';
            end

            driverBlock=[obj.DriverBlockLibrary,'/',obj.AXI4SlaveReadBlock];


            hostTargetInterface=hModelGen.hTurnkey.hD.hIP.getHostTargetInterface;
            switch hostTargetInterface
            case 'JTAG AXI Manager (HDL Verifier)'
                AXIInterface='JTAG';
            case 'Ethernet AXI Manager (HDL Verifier)'
                AXIInterface='UDP';
            end
            driverBlockParams={...
            'Address',obj.convertOffsetToFullAddressStr(addrOffset,obj.hFPGAInterface.BaseAddress),...
            'BurstType','Increment',...
            'Priority',num2str(numAxiReadBlocks+1),...
            'Interface',AXIInterface,...
            'DataTypeStr',dataTypeStr,...
            'HasStrobe',HasStrobe,...
            'OutputVectorSize',num2str(portDim),...
            'StrobeAddress',obj.convertOffsetToFullAddressStr(hAddr.AddressStrobe,obj.hFPGAInterface.BaseAddress)};

            blockName=sprintf('AXI4SlaveRead_%s',portName);
            srcBlockPath=hModelGen.addLibraryBlock(driverBlock,'Left',destBlockPath,driverBlockParams,'BlockName',blockName);
            obj.setDeviceAddress(hModelGen,AXIInterface);
        end
    end
    methods(Static)

        function fullAddrstr=convertOffsetToFullAddressStr(addrOffset,baseAddress)
            addrExternal=hdlturnkey.data.Address.convertAddrInternalToExternal(addrOffset);
            baseAddressDec=hex2dec(regexprep(baseAddress,'[x\W]*',''));
            fullAddress=baseAddressDec+addrExternal;
            fullAddrstr=sprintf('0x%s',dec2hex(fullAddress,8));
        end



        function setDeviceAddress(hModelGen,AXIInterface)
            hRD=hModelGen.hTurnkey.hD.hIP.getReferenceDesignPlugin;
            hostTargetInterface=hModelGen.hTurnkey.hD.hIP.getHostTargetInterface;
            if strcmp(hostTargetInterface,'Ethernet AXI Manager (HDL Verifier)')
                IPAddress=hRD.getEthernetIPAddressValue;
                mdlWks=get_param(hModelGen.tifMdlName,'ModelWorkspace');
                axiConfigObj=mdlWks.data;
                hdlv_am_idx=cellfun(@(v)strcmp(v,'HDLVAXIManagerConfig'),{axiConfigObj.Name});
                axiConfigObj(hdlv_am_idx).Value.setDeviceAddress(char(IPAddress));
                axiConfigObj(hdlv_am_idx).Value.setConfig(AXIInterface);
            end
        end

    end
end