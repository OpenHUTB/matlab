



classdef(Abstract)AXI4SlaveSoftware<hdlturnkey.swinterface.SoftwareInterfaceBase


    properties
        hFPGAInterface=[];
    end

    properties(Access=protected)
        IsCoProcessorMode=false;
        IPCoreDeviceFile='/dev/mwipcore';
        IsAXI4ReadbackEnabled=false;
    end


    properties(Constant,Access=protected)
        ReadChannelBaseName="mmrd-channel";
        WriteChannelBaseName="mmwr-channel";
        IIOReadDeviceBaseName="mmrd";
        IIOWriteDeviceBaseName="mmwr";
    end

    properties(Access=protected)

        IPCoreDeviceName string



        ReadChannelName string
        WriteChannelName string
        IIOReadDeviceName string
        IIOWriteDeviceName string
    end


    properties(Access=protected,Dependent)
HasProcessorConnection
    end
    properties(Access=protected)
        HasMATLABAXIMasterConnection=false;
    end


    properties(Abstract,Access=protected)
DriverBlockLibrary
AXI4SlaveWriteBlock
AXI4SlaveReadBlock
    end


    properties(Access=protected)
        AddInterfaceMethod='addAXI4SlaveInterface';
    end


    methods(Static)
        function hSoftwareInterface=getInstance(hFGPAInterface,hTurnkey)
            hRD=hTurnkey.hD.hIP.getReferenceDesignPlugin;
            hasMATLABAXIMasterConnection=hRD.getJTAGAXIParameterValue||hRD.getEthernetAXIParameterValue;


            if hTurnkey.hD.isXilinxIP
                hSoftwareInterface=hdlturnkey.swinterface.AXI4SlaveSoftwareZynq(hFGPAInterface,hTurnkey.isCoProcessorMode,hasMATLABAXIMasterConnection,hTurnkey.hD.hIP.getAXI4ReadbackEnable);
            elseif hTurnkey.hD.isAlteraIP
                hSoftwareInterface=hdlturnkey.swinterface.AXI4SlaveSoftwareAlteraSoC(hFGPAInterface,hTurnkey.isCoProcessorMode,hasMATLABAXIMasterConnection,hTurnkey.hD.hIP.getAXI4ReadbackEnable);
            elseif hTurnkey.hD.isMicrochipIP
                hSoftwareInterface=hdlturnkey.swinterface.AXI4SlaveSoftwareMicrochip(hFGPAInterface,hTurnkey.isCoProcessorMode,hasMATLABAXIMasterConnection,hTurnkey.hD.hIP.getAXI4ReadbackEnable);
            else
                hSoftwareInterface=hdlturnkey.swinterface.SoftwareInterfaceEmpty(hFGPAInterface.InterfaceID);
            end
        end

        function hHostInterface=getHostInstance(hFGPAInterface,hTurnkey)
            hRD=hTurnkey.hD.hIP.getReferenceDesignPlugin;
            hasMATLABAXIMasterConnection=hRD.getJTAGAXIParameterValue||hRD.getEthernetAXIParameterValue;
            if hTurnkey.hD.isXilinxIP
                hHostInterface=hdlturnkey.swinterface.AXI4SlaveJTAGZynq(hFGPAInterface,hTurnkey.isCoProcessorMode,hasMATLABAXIMasterConnection,hTurnkey.hD.hIP.getAXI4ReadbackEnable);
            elseif hTurnkey.hD.isAlteraIP
                hHostInterface=hdlturnkey.swinterface.AXI4SlaveJTAGAlteraSoC(hFGPAInterface,hTurnkey.isCoProcessorMode,hasMATLABAXIMasterConnection,hTurnkey.hD.hIP.getAXI4ReadbackEnable);
            elseif hTurnkey.hD.isMicrochipIP
                hHostInterface=hdlturnkey.swinterface.AXI4SlaveJTAGMicrochip(hFGPAInterface,hTurnkey.isCoProcessorMode,hasMATLABAXIMasterConnection,hTurnkey.hD.hIP.getAXI4ReadbackEnable);
            else
                hHostInterface=hdlturnkey.swinterface.SoftwareInterfaceEmpty(hFGPAInterface.InterfaceID);
            end
        end
    end

    methods(Access=protected)
        function obj=AXI4SlaveSoftware(hFGPAInterface,isCoProcessorMode,hasMATLABAXIMasterConnection,isAXI4ReadbackEnabled)

            if nargin<4
                isAXI4ReadbackEnabled=false;
            end

            if nargin<3
                hasMATLABAXIMasterConnection=false;
            end
            if nargin<2
                isCoProcessorMode=false;
            end

            obj=obj@hdlturnkey.swinterface.SoftwareInterfaceBase(hFGPAInterface.InterfaceID);


            obj.hFPGAInterface=hFGPAInterface;


            obj.IsCoProcessorMode=isCoProcessorMode;


            obj.IsAXI4ReadbackEnabled=isAXI4ReadbackEnabled;



            obj.HasMATLABAXIMasterConnection=hasMATLABAXIMasterConnection;
            if~(obj.HasProcessorConnection||obj.HasMATLABAXIMasterConnection)
                error('AXI4-Slave software interface has no supported master connection. A supported master connection is required to use this software interface class.');
            end
        end
    end


    methods
        function hasConn=get.HasProcessorConnection(obj)
            hasConn=obj.hFPGAInterface.HasProcessorConnection;
        end
    end


    methods
        function registerDeviceTreeNames(obj,hNameService,ipDeviceName)
            if obj.HasProcessorConnection
                obj.ReadChannelName=hNameService.registerName(obj.ReadChannelBaseName);
                obj.WriteChannelName=hNameService.registerName(obj.WriteChannelBaseName);

                obj.IIOReadDeviceName=hNameService.registerName(obj.IIOReadDeviceBaseName);
                obj.IIOWriteDeviceName=hNameService.registerName(obj.IIOWriteDeviceBaseName);
            end
            obj.IPCoreDeviceName=ipDeviceName;
        end

        function validateCell=generateDeviceTreeNodes(obj,hIPCoreNode)
            validateCell={};





            hMMRD=devicetreeNode("mmrd-channel","UnitAddress",0);
            hMMRD.addComment(sprintf('Device tree node for read channel of interface "%s"',obj.InterfaceID));
            hMMRD.addProperty("compatible","mathworks,mm-read-channel-v1.00");
            hMMRD.addProperty("mathworks,dev-name",obj.IIOReadDeviceName);


            hMMWR=devicetreeNode("mmwr-channel","UnitAddress",1);
            hMMWR.addComment(sprintf('Device tree node for write channel of interface "%s"',obj.InterfaceID));
            hMMWR.addProperty("compatible","mathworks,mm-write-channel-v1.00");
            hMMWR.addProperty("mathworks,dev-name",obj.IIOWriteDeviceName);


            hIPCoreNode.addProperty("compatible","mathworks,mwipcore-v3.00");
            hIPCoreNode.AddressCells=hMMRD.RequiredAddressCells;
            hIPCoreNode.SizeCells=hMMRD.RequiredSizeCells;


            hIPCoreNode.addNode(hMMRD);
            hIPCoreNode.addNode(hMMWR);
        end
    end


    methods
        function validateCell=generateModelDriver(obj,hModelGen)
            validateCell={};
            if obj.HasProcessorConnection
                obj.generateModelDriverProcessor(hModelGen);
            end
        end

        function validateCell=generateHostModelDriver(obj,hModelGen)
            validateCell={};
            hostTargetInterface=hModelGen.hTurnkey.hD.hIP.getHostTargetInterface;
            switch hostTargetInterface
            case 'JTAG AXI Manager (HDL Verifier)'
                validateCell=obj.generateHostModelDriverJTAG(hModelGen);
            case 'Ethernet AXI Manager (HDL Verifier)'
                validateCell=obj.generateHostModelDriverEthernetAXIM(hModelGen);
            case 'Ethernet'
                validateCell=obj.generateHostModelDriverEthernet(hModelGen);
            end
        end


        function validateCell=generateHostModelDriverJTAG(obj,hModelGen)
            validateCell={};
            if obj.HasMATLABAXIMasterConnection

                obj.generateModelDriverProcessor(hModelGen);
            end
        end

        function validateCell=generateHostModelDriverEthernetAXIM(obj,hModelGen)
            validateCell={};
            if obj.HasMATLABAXIMasterConnection

                obj.generateModelDriverProcessor(hModelGen);
            end
        end

        function validateCell=generateHostModelDriverEthernet(obj,hModelGen)
            validateCell={};

        end
    end

    methods(Abstract,Static,Access=protected)
        addHandshakeBlock(newBlockPath,ipCoreDeviceFile,copReadyOffset,copStrobeOffset)
    end

    methods(Access=protected)

        function refList=addToList(~,refList,element,isBus)









            if~isBus
                refList{end+1}=element;
            end
        end

        function generateModelDriverProcessor(obj,hModelGen)



            obj.loadDriverBlockLibrary;


            obj.createAXI4SlaveWriteSubsytem(hModelGen);


            obj.createAXI4SlaveReadSubsytem(hModelGen);

        end

        function closeLib=loadDriverBlockLibrary(obj)

            if~isempty(obj.DriverBlockLibrary)
                load_system(obj.DriverBlockLibrary);
                closeLib=onCleanup(@()close_system(obj.DriverBlockLibrary,0));
            end
        end

        function subsysPath=createAXI4SlaveWriteSubsytem(obj,hModelGen)















            writeSubsysBlockList={};
            inPortList=obj.hIOPortList.InputPortNameList;
            for ii=1:length(inPortList)
                portName=inPortList{ii};
                hIOPort=obj.hIOPortList.getIOPort(portName);



                portBlockPath=hModelGen.getTIFDutPort(portName);
                srcBlockPath=portBlockPath;
                writeSubsysBlockList{end+1}=srcBlockPath;%#ok<AGROW>








                if hIOPort.isBus
                    hAddrList=obj.hFPGAInterface.hAddrManager.getAddressWithName(portName);
                    hAddrCells=obj.hFPGAInterface.hAddrManager.getAllAssignedAddressObj(hAddrList);












                    subSystemBlock=hModelGen.addEmptySubSystemBlock('Right',srcBlockPath,portName);
                    srcBlockPath=subSystemBlock;
                    writeSubsysBlockList{end+1}=subSystemBlock;%#ok<AGROW>           
                else
                    hAddrCells=obj.hFPGAInterface.getIPCoreAddrWithName(portName);
                end




                writeSubsysBlockList=obj.createAXI4SlaveWriteSubsytemBlocks(hModelGen,...
                hIOPort,...
                ii,...
                hAddrCells,...
                srcBlockPath,...
                writeSubsysBlockList);




                if hIOPort.isBus
                    hModelGen.connectBlocks(portBlockPath,subSystemBlock);
                    hModelGen.arrangeSystem(subSystemBlock);
                end

            end












            if~obj.hFPGAInterface.BitPacking

                subsysPath=hModelGen.createSubsystem(writeSubsysBlockList,obj.getAXI4SlaveWriteSubSystemName);
                if~isempty(subsysPath)


                    set_param(subsysPath,'Priority','1');
                end
            end
        end

        function subsysPath=createAXI4SlaveReadSubsytem(obj,hModelGen)












            readSubsysBlockList={};
            outPortList=obj.hIOPortList.OutputPortNameList;
            for ii=1:length(outPortList)
                portName=outPortList{ii};
                hIOPort=obj.hIOPortList.getIOPort(portName);



                portBlockName=hIOPort.PortName;
                portBlockPath=hModelGen.getTIFDutPort(portBlockName);
                destBlockPath=portBlockPath;
                readSubsysBlockList{end+1}=destBlockPath;%#ok<AGROW>








                if hIOPort.isBus
                    hAddrList=obj.hFPGAInterface.hAddrManager.getAddressWithName(portName);
                    hAddrCells=obj.hFPGAInterface.hAddrManager.getAllAssignedAddressObj(hAddrList);












                    subSystemBlock=hModelGen.addEmptySubSystemBlock('Left',destBlockPath,portName);
                    destBlockPath=subSystemBlock;
                    readSubsysBlockList{end+1}=subSystemBlock;%#ok<AGROW>
                else
                    hAddrCells=obj.hFPGAInterface.getIPCoreAddrWithName(portName);
                end




                readSubsysBlockList=obj.createAXI4SlaveReadSubsytemBlocks(hModelGen,...
                hIOPort,...
                ii,...
                hAddrCells,...
                destBlockPath,...
                readSubsysBlockList);




                if hIOPort.isBus
                    hModelGen.connectBlocks(subSystemBlock,portBlockPath);
                    hModelGen.arrangeSystem(subSystemBlock);
                end
            end


            if obj.IsCoProcessorMode

                hReadyAddr=obj.hFPGAInterface.getBaseAddrWithName('cop_out_ready');
                copReadyOffset=hdlturnkey.data.Address.convertAddrInternalToCStr(hReadyAddr.AddressStart);


                hStrobeAddr=obj.hFPGAInterface.getBaseAddrWithName('cop_in_strobe');
                copStrobeOffset=hdlturnkey.data.Address.convertAddrInternalToCStr(hStrobeAddr.AddressStart);

                newBlockPath=obj.addCoProcessorBlock(hModelGen,copReadyOffset,copStrobeOffset);
                readSubsysBlockList{end+1}=newBlockPath;
            end














            if~obj.hFPGAInterface.BitPacking

                subsysPath=hModelGen.createSubsystem(readSubsysBlockList,obj.getAXI4SlaveReadSubSystemName);
                if~isempty(subsysPath)


                    set_param(subsysPath,'Priority','10');
                end
            end

        end

        function writeSubsysBlockList=createAXI4SlaveWriteSubsytemBlocks(obj,...
            hModelGen,...
            hIOPort,...
            portLoopIndex,...
            hAddrCells,...
            refBlockPath,...
            writeSubsysBlockList)














            hAddrCells=downstream.tool.convertToCell(hAddrCells);

            srcBlockName=hIOPort.PortName;
            for idx=1:length(hAddrCells)
                hAddr=hAddrCells{idx};
                wordLength=hAddr.PortWordLength;
                hDataType=hAddr.DataType;



                if isempty(hDataType)
                    hDataType=hIOPort.Type;
                end


                if hIOPort.isBus
                    inPortBlockPath=hModelGen.addBusElementPort('In',refBlockPath,hAddr.DispFlattenedPortName,hAddr.getDispFlattenedPortNameWithoutPortName);
                    AXI4SlaveWriteblockName=hAddr.DispFlattenedPortName;
                else
                    inPortBlockPath=refBlockPath;
                    AXI4SlaveWriteblockName=srcBlockName;
                end









                if~(hDataType.isSingle||hDataType.isDouble)&&~obj.hFPGAInterface.BitPacking


                    if(hDataType.isHalf)



                        inPortBlockPath=hModelGen.addFloatTypecastBlock('Right',inPortBlockPath);
                        writeSubsysBlockList=obj.addToList(writeSubsysBlockList,inPortBlockPath,hIOPort.isBus);
                    end
                    outputDataWidth=max(32,wordLength);
                    outputDataType=fixdt(0,outputDataWidth,0);
                    inPortBlockPath=hModelGen.addDTCBlock('Right',inPortBlockPath,outputDataType);
                    writeSubsysBlockList=obj.addToList(writeSubsysBlockList,inPortBlockPath,hIOPort.isBus);
                end


                if wordLength>32&&~hDataType.isDouble
                    dimLen=hAddr.PortVectorSize;
                    addrLen=hAddr.AddressLength;
                    inPortBlockPath=obj.addBitSliceSubsys(hModelGen,inPortBlockPath,wordLength,dimLen,addrLen,srcBlockName);
                    writeSubsysBlockList=obj.addToList(writeSubsysBlockList,inPortBlockPath,hIOPort.isBus);
                end


                inPortBlockPath=obj.addAXI4SlaveWriteBlock(hModelGen,inPortBlockPath,hAddr.AddressStart,portLoopIndex+idx,AXI4SlaveWriteblockName,hDataType,hAddr);
                writeSubsysBlockList=obj.addToList(writeSubsysBlockList,inPortBlockPath,hIOPort.isBus);
            end
        end

        function readSubsysBlockList=createAXI4SlaveReadSubsytemBlocks(obj,...
            hModelGen,...
            hIOPort,...
            portLoopIndex,...
            hAddrCells,...
            refBlockPath,...
            readSubsysBlockList)















            hAddrCells=downstream.tool.convertToCell(hAddrCells);

            destBlockName=hIOPort.PortName;
            for idx=1:length(hAddrCells)

                hAddr=hAddrCells{idx};
                wordLength=hAddr.PortWordLength;
                hDataType=hAddr.DataType;



                if isempty(hDataType)
                    hDataType=hIOPort.Type;
                end


                if hIOPort.isBus
                    outPortBlockPath=hModelGen.addBusElementPort('Out',refBlockPath,hAddr.DispFlattenedPortName,hAddr.getDispFlattenedPortNameWithoutPortName);
                    AXI4SlaveReadblockName=hAddr.DispFlattenedPortName;
                else
                    outPortBlockPath=refBlockPath;
                    AXI4SlaveReadblockName=destBlockName;
                end


                if~(hDataType.isSingle||hDataType.isDouble)

                    if isempty(hAddr.DispDataType)
                        outputDataType=fixdt(hIOPort.SLDataType);
                    else
                        outputDataType=fixdt(hAddr.DataType.SLType);
                    end



                    if(hDataType.isHalf)



                        outPortBlockPath=hModelGen.addFloatTypecastBlock('Left',outPortBlockPath);
                        readSubsysBlockList=obj.addToList(readSubsysBlockList,outPortBlockPath,hIOPort.isBus);
                        outPortBlockPath=hModelGen.addDTCBlock('Left',outPortBlockPath,fixdt('uint16'));
                    else
                        outPortBlockPath=hModelGen.addDTCBlock('Left',outPortBlockPath,outputDataType);
                    end
                    readSubsysBlockList=obj.addToList(readSubsysBlockList,outPortBlockPath,hIOPort.isBus);
                end


                if wordLength>32&&~hDataType.isDouble
                    dimLen=hAddr.PortVectorSize;
                    addrLen=hAddr.AddressLength;
                    outPortBlockPath=obj.addBitConcatSubsys(hModelGen,outPortBlockPath,wordLength,dimLen,addrLen,destBlockName);
                    readSubsysBlockList=obj.addToList(readSubsysBlockList,outPortBlockPath,hIOPort.isBus);
                end


                if hDataType.isSingle
                    dataTypeStr='single';
                elseif hDataType.isDouble
                    dataTypeStr='double';
                else
                    dataTypeStr='uint32';
                end

                if hDataType.isDouble
                    portDim=hAddr.PortVectorSize;
                else
                    portDim=hAddr.AddressLength;
                end
                outPortBlockPath=obj.addAXI4SlaveReadBlock(hModelGen,outPortBlockPath,hAddr.AddressStart,dataTypeStr,portDim,portLoopIndex+idx,AXI4SlaveReadblockName,hDataType,hAddr);
                readSubsysBlockList=obj.addToList(readSubsysBlockList,outPortBlockPath,hIOPort.isBus);
            end
        end

        function destBlockPath=addAXI4SlaveWriteBlock(obj,hModelGen,srcBlockPath,addrOffset,numAxiWriteBlocks,portName,hDataType,hAddr)
            driverBlock=[obj.DriverBlockLibrary,'/',obj.AXI4SlaveWriteBlock];
            driverBlockParams={...
            'DeviceName',obj.IPCoreDeviceFile,...
            'RegisterOffset',hdlturnkey.data.Address.convertAddrInternalToModelGenStr(addrOffset),...
            'Priority',num2str(numAxiWriteBlocks)};

            blockName=sprintf('AXI4SlaveWrite_%s',portName);
            destBlockPath=hModelGen.addLibraryBlock(driverBlock,'Right',srcBlockPath,driverBlockParams,'BlockName',blockName);
        end

        function srcBlockPath=addAXI4SlaveReadBlock(obj,hModelGen,destBlockPath,addrOffset,dataTypeStr,portDim,numAxiReadBlocks,portName,hDataType,hAddr)
            driverBlock=[obj.DriverBlockLibrary,'/',obj.AXI4SlaveReadBlock];
            driverBlockParams={...
            'DeviceName',obj.IPCoreDeviceFile,...
            'RegisterOffset',hdlturnkey.data.Address.convertAddrInternalToModelGenStr(addrOffset),...
            'DataType',dataTypeStr,...
            'DataLength',num2str(portDim),...
            'Priority',num2str(numAxiReadBlocks+1),...
            'SampleTime','-1'};

            blockName=sprintf('AXI4SlaveRead_%s',portName);
            srcBlockPath=hModelGen.addLibraryBlock(driverBlock,'Left',destBlockPath,driverBlockParams,'BlockName',blockName);
        end

        function newBlockPath=addCoProcessorBlock(obj,hModelGen,copReadyOffset,copStrobeOffset)

            newBlockPath=hModelGen.getBlockPathFromName(hModelGen.tifDutPath,'AXI4_Handshake');
            obj.addHandshakeBlock(newBlockPath,obj.IPCoreDeviceFile,copReadyOffset,copStrobeOffset);
            set_param(newBlockPath,'Priority','1');
        end
    end

    methods(Static,Access=protected)
        function subsysPath=addBitSliceSubsys(hModelGen,srcBlockPath,wordLength,dimLen,addrLen,portName)






            dataSections=ceil(double(wordLength)/32);
            assert(dimLen*dataSections==addrLen);


            subsysBlockList={};


            muxBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('mux');
            muxBlockParams={'Inputs',num2str(addrLen)};
            blockSpace=3*hdlturnkey.backend.ModelGeneration.BlockSpace;
            muxBlockPath=hModelGen.addBlockRight(muxBlock,srcBlockPath,muxBlockParams,'BlockSpace',blockSpace);
            subsysBlockList{end+1}=muxBlockPath;


            msb=uint32(wordLength-1);
            lsb=uint32(wordLength-32);
            for ii=1:dataSections

                sliceBlockPath=hModelGen.addBitSliceBlock('Right',srcBlockPath,msb,lsb);
                subsysBlockList{end+1}=sliceBlockPath;%#ok<AGROW>


                dtcBlockPath=hModelGen.addDTCBlock('Right',sliceBlockPath,fixdt('uint32'));
                subsysBlockList{end+1}=dtcBlockPath;%#ok<AGROW>




                demuxBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('demux');
                demuxBlockParams={'Outputs',num2str(dimLen)};
                demuxBlockPath=hModelGen.addLibraryBlock(demuxBlock,'Right',dtcBlockPath,demuxBlockParams);
                subsysBlockList{end+1}=demuxBlockPath;%#ok<AGROW>

                for jj=0:dimLen-1









                    demuxPortNum=jj+1;
                    muxPortNum=dataSections*jj+ii;
                    hModelGen.connectBlocks(demuxBlockPath,muxBlockPath,demuxPortNum,muxPortNum);
                end


                msb=msb-32;
                lsb=lsb-32;
            end


            subsysName=sprintf('Bitslice_%s',portName);
            subsysPath=hModelGen.createSubsystem(subsysBlockList,subsysName,true);
        end

        function subsysPath=addBitConcatSubsys(hModelGen,destBlockPath,wordLength,dimLen,addrLen,portName)






            dataSections=ceil(double(wordLength)/32);
            assert(dimLen*dataSections==addrLen);


            subsysBlockList={};



            demuxBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('demux');
            demuxBlockParams={'Outputs',num2str(addrLen)};
            blockSpace=3*hdlturnkey.backend.ModelGeneration.BlockSpace;
            demuxBlockPath=hModelGen.addBlockLeft(demuxBlock,destBlockPath,demuxBlockParams,'BlockSpace',blockSpace);
            subsysBlockList{end+1}=demuxBlockPath;


            muxBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('mux');
            muxBlockParams={'Inputs',num2str(dimLen)};
            muxBlockPath=hModelGen.addLibraryBlock(muxBlock,'Left',destBlockPath,muxBlockParams);
            subsysBlockList{end+1}=muxBlockPath;


            for ii=0:dimLen-1

                muxPortNum=ii+1;
                concatBlockPath=hModelGen.addBitConcatBlock('Left',muxBlockPath,dataSections,'DestBlockPort',muxPortNum);
                subsysBlockList{end+1}=concatBlockPath;%#ok<AGROW>

                msb=uint32(wordLength-1);
                lsb=uint32(wordLength-32);
                for jj=1:dataSections


                    sliceDataType=fixdt(0,msb-lsb+1,0);
                    demuxPortNum=dataSections*ii+jj;
                    dtcBlockPath=hModelGen.addDTCBlock('Right',demuxBlockPath,sliceDataType,'SourceBlockPort',demuxPortNum);
                    subsysBlockList{end+1}=dtcBlockPath;%#ok<AGROW>


                    hModelGen.connectBlocks(dtcBlockPath,concatBlockPath,1,jj);


                    msb=msb-32;
                    lsb=lsb-32;
                end
            end


            subsysName=sprintf('Bitconcat_%s',portName);
            subsysPath=hModelGen.createSubsystem(subsysBlockList,subsysName,true);
        end
    end


    methods
        function validateCell=generateScriptDriver(obj,hScriptGen)

            validateCell={};
            if~obj.IsCoProcessorMode
                obj.generateScriptDriverFreeRunning(hScriptGen);
            else

                inPortList=obj.hIOPortList.InputPortNameList;
                outPortList=obj.hIOPortList.OutputPortNameList;
                portListStr=strjoin([inPortList,outPortList],', ');
                msg=message('hdlcommon:interface:NoDriverSWScriptGen',portListStr,obj.InterfaceID);
                validateCell{end+1}=downstream.tool.generateNoteWithStruct(msg,hScriptGen.isCommandLineDisplay);
            end
        end

        function validateCell=generateInterfaceAccessCommand(obj,hScriptGen)

            validateCell={};
            if~obj.IsCoProcessorMode
                obj.generateInterfaceAccessCommandFreeRunning(hScriptGen);
            else

            end
        end
    end

    methods(Access=protected)
        function validateCell=generateScriptDriverFreeRunning(obj,hScriptGen)


            validateCell={};

            fileID=hScriptGen.FileID;


            hScriptGen.addSection(fileID,obj.InterfaceID);


            pvPairs={{'"InterfaceID"',sprintf('"%s"',obj.InterfaceID)}};

            baseAddr=obj.hFPGAInterface.BaseAddress;
            if iscell(baseAddr)


                baseAddr=baseAddr{1};
            end
            baseAddr=erase(baseAddr,'_');
            addrRange='0x10000';
            pvPairs{end+1}={'"BaseAddress"',baseAddr};
            pvPairs{end+1}={'"AddressRange"',addrRange};

            InterfaceType=hScriptGen.hTurnkey.hD.hIP.getHostTargetInterface;
            if strcmp(InterfaceType,'JTAG AXI Manager (HDL Verifier)')

                axiMasterVarName='hAXIMDriver';
                vendor=sprintf('"%s"',hScriptGen.Vendor);
                hScriptGen.addFunctionCall(fileID,'aximanager',{vendor},{axiMasterVarName});


                driverParams=obj.getDriverParametersMATLABAXIMaster(axiMasterVarName);
            elseif strcmp(InterfaceType,'Ethernet AXI Manager (HDL Verifier)')
                hRD=hScriptGen.hTurnkey.hD.hIP.getReferenceDesignPlugin;

                axiMasterVarName='hAXIMDriver';
                inputArg=sprintf('"%s","Interface","UDP","DeviceAddress","%s","Port","%d"',...
                hScriptGen.Vendor,hRD.getEthernetIPAddressValue{:},hRD.EthernetPortAddr(1));
                hScriptGen.addFunctionCall(fileID,'aximanager',{inputArg},{axiMasterVarName});

                driverParams=obj.getDriverParametersMATLABAXIMaster(axiMasterVarName);
            else



                driverParams=obj.getDriverParametersProcessor;

            end
            pvPairs=[pvPairs,driverParams];
            obj.generateAddInterfaceCommand(hScriptGen,pvPairs);
            hScriptGen.addEmptyLine(fileID);


            obj.generateDUTPortConstructor(hScriptGen);


            obj.generateMapPortCommand(hScriptGen);
            hScriptGen.addEmptyLine(fileID);
        end

        function validateCell=generateInterfaceAccessCommandFreeRunning(obj,hScriptGen)


            validateCell={};

            fileID=hScriptGen.FileID;


            hScriptGen.addSection(fileID,obj.InterfaceID);


            obj.generatePortAccessCommand(hScriptGen);

            hScriptGen.addEmptyLine(fileID);
        end

        function pvPairs=getDriverParametersProcessor(obj)
            pvPairs={};
            if~isempty(obj.IPCoreDeviceName)

                pvPairs{end+1}={'"WriteDeviceName"',sprintf('"%s:%s"',obj.IPCoreDeviceName,obj.IIOWriteDeviceName)};
                pvPairs{end+1}={'"ReadDeviceName"',sprintf('"%s:%s"',obj.IPCoreDeviceName,obj.IIOReadDeviceName)};
            end
        end

        function pvPairs=getDriverParametersMATLABAXIMaster(obj,axiMasterVarName)
            pvPairs={{'"WriteDriver"',axiMasterVarName},...
            {'"ReadDriver"',axiMasterVarName},...
            {'"DriverAddressMode"','"Full"'}};
        end

        function hDUTPort=createDUTPort(obj,hIOPort)



            hObject=obj.hFPGAInterface.getIPCoreAddrWithName(hIOPort.PortName);
            if isa(hObject,'hdlturnkey.data.AddressList')






                hAddrList=hObject;
                hDUTPort=obj.constructFromAddressList(hAddrList,hIOPort,hIOPort.PortName);
            else

                hAddr=hObject;
                addrInternal=hAddr.AddressStart;










                if obj.IsAXI4ReadbackEnabled&&strcmp(hIOPort.PortType,"IN")
                    Direction='INOUT';
                else
                    Direction=char(hIOPort.PortType);
                end
                addrDec=hdlturnkey.data.Address.convertAddrInternalToExternal(addrInternal);
                hDUTPort=fpgaio.data.DUTPort.constructFromIOPort(hIOPort,'IOInterface',obj.InterfaceID,'IOInterfaceMapping',['0x',dec2hex(addrDec)],'Direction',Direction);
            end
        end

        function hDUTPort=constructFromAddress(obj,hAddr,busName,varargin)





            propList=properties('fpgaio.data.DUTPort');
            constructorArgs={};
            hDataType=hAddr.DataType;
            for ii=1:length(propList)
                propName=propList{ii};
                switch propName
                case 'Name'
                    name=char(extractAfter(hAddr.DispFlattenedPortName,[busName,'.']));
                    constructorArgs=[{name},constructorArgs];%#ok<AGROW>
                    continue;
                case 'Direction'
                    propVal=char(hAddr.AssignedPortType);
                case 'IOInterface'
                    propVal=obj.InterfaceID;
                case 'DataType'
                    if hDataType.isBoolean
                        propVal='logical';
                    elseif hDataType.isSingle
                        propVal='single';
                    elseif hDataType.isDouble
                        propVal='double';
                    elseif hDataType.isHalf
                        propVal='half';
                    else
                        portTypeNT=numerictype(hDataType.Signed,hDataType.WordLength,-hDataType.FractionLength);
                        if fixed.internal.type.isEquivalentToBuiltin(portTypeNT)


                            propVal=fixed.internal.type.toMATLABTypeName(portTypeNT);
                        else

                            propVal=portTypeNT;
                        end
                    end
                case 'Dimension'
                    propVal=[1,hDataType.Dimension];
                otherwise
                    continue;
                end

                constructorArgs(end+1:end+2)={propName,propVal};
            end



            addrInternal=hAddr.AddressStart;
            addrDec=hdlturnkey.data.Address.convertAddrInternalToExternal(addrInternal);
            constructorArgs(end+1:end+2)={'IOInterfaceMapping',['0x',dec2hex(addrDec)]};



            constructorArgs=[constructorArgs,varargin];


            hDUTPort=fpgaio.data.DUTPort(constructorArgs{:});
        end

        function hDUTPort=constructFromAddressList(obj,hAddrList,hIOPort,assignedBusName,varargin)


            hAddrCellsList=hAddrList.getAllAssignedAddressObj;
            if strcmp(hAddrList.AssignedName,assignedBusName)
                busPortName=hAddrList.AssignedName;
            else
                busPortName=extractAfter(hAddrList.AssignedName,[assignedBusName,'.']);
            end


            hSubPorts=fpgaio.data.DUTPort.empty;
            for idx=1:length(hAddrCellsList)
                hAddr=hAddrCellsList{idx};
                hSubPorts(end+1)=obj.constructFromAddress(hAddr,hAddrList.AssignedName,varargin{:});%#ok<AGROW>
            end
            if hAddrList.hasSubAddressList
                hSubAddressList=hAddrList.getAllAssignedAddressListObj;
                for idx=1:length(hSubAddressList)
                    hSubAddressList=hSubAddressList{idx};
                    hSubPorts(end+1)=obj.constructFromAddressList(hSubAddressList,hIOPort,hAddrList.AssignedName,varargin{:});%#ok<AGROW>
                end
            end


            hDUTPort=fpgaio.data.DUTPort(busPortName,'Direction',char(hIOPort.PortType),'SubPorts',hSubPorts);
        end


        function AXI4SlaveWriteSubSystemName=getAXI4SlaveWriteSubSystemName(~)
            AXI4SlaveWriteSubSystemName='AXI4SlaveWrite';
        end
        function AXI4SlaveReadSubSystemName=getAXI4SlaveReadSubSystemName(~)
            AXI4SlaveReadSubSystemName='AXI4SlaveRead';
        end
    end
end
