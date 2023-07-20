


classdef(Abstract)AXI4StreamSoftware<hdlturnkey.swinterface.SoftwareInterfaceBase


    properties
        hFPGAInterface=[];
    end


    properties(Constant,Access=protected)

        IIOReadDeviceBaseName="s2mm";

        IIOWriteDeviceBaseName="mm2s";
        ChannelDeviceBaseName="stream-channel";
    end

    properties(Access=protected)

        IPCoreDeviceName string



        IIOReadDeviceName string
        IIOWriteDeviceName string
        ReadChannelDeviceName string
        WriteChannelDeviceName string
    end


    properties(Abstract,Constant,Access=protected)
DriverBlockLibrary
AXI4StreamWriteBlock
AXI4StreamReadBlock
    end


    properties(Access=protected)
        AddInterfaceMethod='addAXI4StreamInterface';
    end

    properties(Access=protected,Dependent)
DefaultWriteFrameLength
DefaultReadFrameLength
    end


    methods(Static)
        function hSoftwareInterface=getInstance(hFGPAInterface,hTurnkey)

            if hTurnkey.hD.isXilinxIP
                hSoftwareInterface=hdlturnkey.swinterface.AXI4StreamSoftwareZynq(hFGPAInterface);
            elseif hTurnkey.hD.isAlteraIP

                hSoftwareInterface=hdlturnkey.swinterface.SoftwareInterfaceEmpty(hFGPAInterface.InterfaceID);
            else
                hSoftwareInterface=hdlturnkey.swinterface.SoftwareInterfaceEmpty(hFGPAInterface.InterfaceID);
            end
        end
    end

    methods(Access=protected)
        function obj=AXI4StreamSoftware(hFGPAInterface)

            obj=obj@hdlturnkey.swinterface.SoftwareInterfaceBase(hFGPAInterface.InterfaceID);


            obj.hFPGAInterface=hFGPAInterface;
        end
    end


    methods
        function frameLen=get.DefaultWriteFrameLength(obj)


            frameLen=obj.DefaultReadFrameLength;
        end

        function frameLen=get.DefaultReadFrameLength(obj)




            frameLen=obj.hFPGAInterface.DefaultPacketSize;
        end
    end


    methods
        function registerDeviceTreeNames(obj,hNameService,ipDeviceName)



            channelDeviceBaseName=obj.ChannelDeviceBaseName+"@";

            if obj.hFPGAInterface.SlaveChannelEnable
                obj.IIOWriteDeviceName=hNameService.registerName(obj.IIOWriteDeviceBaseName);
                obj.WriteChannelDeviceName=hNameService.registerName(channelDeviceBaseName);
            end

            if obj.hFPGAInterface.MasterChannelEnable
                obj.IIOReadDeviceName=hNameService.registerName(obj.IIOReadDeviceBaseName);
                obj.ReadChannelDeviceName=hNameService.registerName(channelDeviceBaseName);
            end
            obj.IPCoreDeviceName=ipDeviceName;
        end

        function validateCell=generateDeviceTreeNodes(obj,hIPCoreNode)
            validateCell={};





            if obj.hFPGAInterface.SlaveChannelEnable
                channelUnitAddr=double(extractAfter(obj.WriteChannelDeviceName,"@"));
                hStreamWrite=devicetreeNode(obj.ChannelDeviceBaseName,"UnitAddress",channelUnitAddr);
                hStreamWrite.addComment(sprintf('Device tree node for write channel of interface "%s"',obj.InterfaceID));
                hStreamWrite.AddressCells=1;
                hStreamWrite.SizeCells=0;
                hStreamWrite.addProperty("compatible","mathworks,axi4stream-mm2s-channel-v1.00");
                hStreamWrite.addProperty("dma-names","mm2s");
                hStreamWrite.addProperty("dmas",{obj.hFPGAInterface.DeviceTreeSlaveChannelDMANode,0});
                hStreamWrite.addProperty("mathworks,dev-name",obj.IIOWriteDeviceName);

                hDataChannel=hStreamWrite.addNode("data-channel","UnitAddress",0);
                hDataChannel.addProperty("compatible","mathworks,iio-data-channel-v1.00");
                dataWidth=obj.hFPGAInterface.SlaveChannelDataWidth;
                dataFormat="u"+dataWidth+"/"+dataWidth+">>0";
                hDataChannel.addProperty("mathworks,data-format",dataFormat);
            end



            if obj.hFPGAInterface.MasterChannelEnable
                channelUnitAddr=double(extractAfter(obj.ReadChannelDeviceName,"@"));
                hStreamRead=devicetreeNode(obj.ChannelDeviceBaseName,"UnitAddress",channelUnitAddr);
                hStreamRead.addComment(sprintf('Device tree node for read channel of interface "%s"',obj.InterfaceID));
                hStreamRead.AddressCells=1;
                hStreamRead.SizeCells=0;
                hStreamRead.addProperty("compatible","mathworks,axi4stream-s2mm-channel-v1.00");
                hStreamRead.addProperty("dma-names","s2mm");
                hStreamRead.addProperty("dmas",{obj.hFPGAInterface.DeviceTreeMasterChannelDMANode,0});
                hStreamRead.addProperty("mathworks,dev-name",obj.IIOReadDeviceName);
                if~isempty(obj.hFPGAInterface.TLASTRegisterAddress)
                    hStreamRead.addProperty("mathworks,sample-cnt-reg",{obj.hFPGAInterface.TLASTRegisterAddress});
                end

                hDataChannel=hStreamRead.addNode("data-channel","UnitAddress",0);
                hDataChannel.addProperty("compatible","mathworks,iio-data-channel-v1.00");
                dataWidth=obj.hFPGAInterface.MasterChannelDataWidth;
                dataFormat="u"+dataWidth+"/"+dataWidth+">>0";
                hDataChannel.addProperty("mathworks,data-format",dataFormat);
            end


            hIPCoreNode.addProperty("compatible","mathworks,mwipcore-v3.00");
            hIPCoreNode.AddressCells=hStreamWrite.RequiredAddressCells;
            hIPCoreNode.SizeCells=hStreamWrite.RequiredSizeCells;


            hIPCoreNode.addNode(hStreamWrite);
            hIPCoreNode.addNode(hStreamRead);
        end
    end



    methods
        function validateCell=generateModelDriver(obj,hModelGen)
            validateCell={};
            if obj.hFPGAInterface.isFrameMode


                obj.generateModelDriverVectorMode(hModelGen);
            else

                obj.stubAllPorts(hModelGen);



                validateCell={};
                interfaceStr=obj.hFPGAInterface.InterfaceID;

                writePortName=obj.getWritePortName;
                if~isempty(writePortName)
                    msg=message('hdlcommon:interface:AXIStreamScalarSWModelGen',writePortName,interfaceStr,writePortName);
                    validateCell{end+1}=downstream.tool.generateWarningWithStruct(msg,hModelGen.isCommandLineDisplay);
                end

                readPortName=obj.getReadPortName;
                if~isempty(readPortName)
                    msg=message('hdlcommon:interface:AXIStreamScalarSWModelGen',readPortName,interfaceStr,readPortName);
                    validateCell{end+1}=downstream.tool.generateWarningWithStruct(msg,hModelGen.isCommandLineDisplay);
                end
            end
        end
    end

    methods(Access=protected)
        function generateModelDriverVectorMode(obj,hModelGen)

            load_system(obj.DriverBlockLibrary);
            closeLib=onCleanup(@()close_system(obj.DriverBlockLibrary,0));












            srcBlockList={};
            inPortList=obj.hIOPortList.InputPortNameList;
            for ii=1:length(inPortList)
                portName=inPortList{ii};
                hIOPort=obj.hIOPortList.getIOPort(portName);



                srcBlockPath=hModelGen.getTIFDutPort(portName);
                srcBlockList{end+1}=srcBlockPath;%#ok<AGROW>


                if(strcmp(hIOPort.SLDataType,'single')||...
                    strcmp(hIOPort.SLDataType,'half'))



                    srcBlockPath=hModelGen.addFloatTypecastBlock('Right',srcBlockPath);
                    srcBlockList{end+1}=srcBlockPath;%#ok<AGROW>
                end
                srcBlockPath=hModelGen.addDTCBlock('Right',srcBlockPath,fixdt('uint32'));
                srcBlockList{end+1}=srcBlockPath;%#ok<AGROW>


                srcBlockPath=obj.addAXI4StreamWriteBlock(hModelGen,srcBlockPath,ii);
                srcBlockList{end+1}=srcBlockPath;%#ok<AGROW>


                srcBlockPath=hModelGen.addTerminatorBlock('Right',srcBlockPath);
                srcBlockList{end+1}=srcBlockPath;%#ok<AGROW>
            end


            subsysPath=hModelGen.createSubsystem(srcBlockList,'AXI4StreamWrite');
            if~isempty(subsysPath)


                set_param(subsysPath,'Priority','1');
            end













            destBlockList={};
            outPortList=obj.hIOPortList.OutputPortNameList;
            for ii=1:length(outPortList)
                portName=outPortList{ii};
                hIOPort=obj.hIOPortList.getIOPort(portName);



                destBlockPath=hModelGen.getTIFDutPort(portName);
                destBlockList{end+1}=destBlockPath;%#ok<AGROW>

                if(strcmp(hIOPort.SLDataType,'single')||...
                    strcmp(hIOPort.SLDataType,'half'))



                    destBlockPath=hModelGen.addFloatTypecastBlock('Left',destBlockPath);
                    destBlockList{end+1}=destBlockPath;%#ok<AGROW>
                end


                if(strcmp(hIOPort.SLDataType,'single'))


                    outputDataType=fixdt('uint32');
                elseif(strcmp(hIOPort.SLDataType,'half'))


                    outputDataType=fixdt('uint16');
                else
                    outputDataType=fixdt(hIOPort.SLDataType);
                end
                destBlockPath=hModelGen.addDTCBlock('Left',destBlockPath,outputDataType);
                destBlockList{end+1}=destBlockPath;%#ok<AGROW>


                dim=hIOPort.Dimension;
                destBlockPath=obj.addAXI4StreamReadBlock(hModelGen,destBlockPath,dim,ii);
                destBlockList{end+1}=destBlockPath;%#ok<AGROW>


                srcBlockPath=destBlockPath;
                destBlockPath=hModelGen.addTerminatorBlock('Right',srcBlockPath,'SourceBlockPort',2);
                destBlockList{end+1}=destBlockPath;%#ok<AGROW>
            end


            subsysPath=hModelGen.createSubsystem(destBlockList,'AXI4StreamRead',true);
            if~isempty(subsysPath)


                set_param(subsysPath,'Priority','10');
            end
        end

        function destBlockPath=addAXI4StreamWriteBlock(obj,hModelGen,srcBlockPath,numAxiWriteBlocks)
            driverBlock=[obj.DriverBlockLibrary,'/',obj.AXI4StreamWriteBlock];
            driverBlockParams={...
            'DataTimeout','0',...
            'Priority',num2str(numAxiWriteBlocks)};
            if~isempty(obj.IPCoreDeviceName)



                driverBlockParams(end+1:end+2)={'devName',sprintf('%s:%s',obj.IPCoreDeviceName,obj.IIOWriteDeviceName)};
            end

            destBlockPath=hModelGen.addLibraryBlock(driverBlock,'Right',srcBlockPath,driverBlockParams);
        end

        function srcBlockPath=addAXI4StreamReadBlock(obj,hModelGen,destBlockPath,dim,numAxiReadBlocks)
            driverBlock=[obj.DriverBlockLibrary,'/',obj.AXI4StreamReadBlock];
            driverBlockParams={...
            'dataTypeStr','uint32',...
            'SamplesPerFrame',num2str(dim),...
            'DataTimeout','10',...
            'SampleTime','-1',...
            'Priority',num2str(numAxiReadBlocks+1)};
            if~isempty(obj.IPCoreDeviceName)



                driverBlockParams(end+1:end+2)={'devName',sprintf('%s:%s',obj.IPCoreDeviceName,obj.IIOReadDeviceName)};
            end

            srcBlockPath=hModelGen.addLibraryBlock(driverBlock,'Left',destBlockPath,driverBlockParams);
        end
    end


    methods
        function validateCell=generateScriptDriver(obj,hScriptGen)


            validateCell={};

            if~obj.isAXI4StreamVectorSampleMode
                obj.generateScriptDriverForSupportedPorts(hScriptGen);
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

            if~obj.isAXI4StreamVectorSampleMode
                obj.generateInterfaceAccessCommandForSupportedPorts(hScriptGen);
            else

            end
        end
    end

    methods(Access=protected)

        function validateCell=generateScriptDriverForSupportedPorts(obj,hScriptGen)


            validateCell={};

            fileID=hScriptGen.FileID;


            hScriptGen.addSection(fileID,obj.InterfaceID);


            writePortName=obj.getWritePortName;
            readPortName=obj.getReadPortName;


            pvPairs={{'"InterfaceID"',sprintf('"%s"',obj.InterfaceID)}};


            if~isempty(writePortName)
                pvPairs{end+1}={'"WriteEnable"','true'};
                pvPairs{end+1}={'"WriteDataWidth"',num2str(obj.hFPGAInterface.SlaveChannelDataWidth)};




                if obj.hFPGAInterface.isFrameMode
                    hIOPort=obj.hIOPortList.getIOPort(writePortName);


                    pvPairs{end+1}={'"WriteFrameLength"',num2str(prod(hIOPort.Dimension))};
                else
                    pvPairs{end+1}={'"WriteFrameLength"',num2str(obj.DefaultWriteFrameLength)};
                end




                if~isempty(obj.IPCoreDeviceName)
                    pvPairs{end+1}={'"WriteDeviceName"',sprintf('"%s:%s"',obj.IPCoreDeviceName,obj.IIOWriteDeviceName)};
                end
            else
                pvPairs{end+1}={'"WriteEnable"','false'};
            end


            if~isempty(readPortName)
                pvPairs{end+1}={'"ReadEnable"','true'};
                pvPairs{end+1}={'"ReadDataWidth"',num2str(obj.hFPGAInterface.MasterChannelDataWidth)};




                if obj.hFPGAInterface.isFrameMode
                    hIOPort=obj.hIOPortList.getIOPort(readPortName);


                    pvPairs{end+1}={'"ReadFrameLength"',num2str(prod(hIOPort.Dimension))};
                else
                    pvPairs{end+1}={'"ReadFrameLength"',num2str(obj.DefaultReadFrameLength)};
                end




                if~isempty(obj.IPCoreDeviceName)
                    pvPairs{end+1}={'"ReadDeviceName"',sprintf('"%s:%s"',obj.IPCoreDeviceName,obj.IIOReadDeviceName)};
                end
            else
                pvPairs{end+1}={'"ReadEnable"','false'};
            end

            obj.generateAddInterfaceCommand(hScriptGen,pvPairs);
            hScriptGen.addEmptyLine(fileID);


            portList=obj.getDataPortList;
            obj.generateDUTPortConstructor(hScriptGen,portList);


            obj.generateMapPortCommand(hScriptGen,portList);
            hScriptGen.addEmptyLine(fileID);
        end

        function validateCell=generateInterfaceAccessCommandForSupportedPorts(obj,hScriptGen)


            validateCell={};

            fileID=hScriptGen.FileID;


            hScriptGen.addSection(fileID,obj.InterfaceID);


            portList=obj.getDataPortList;


            obj.generatePortAccessCommand(hScriptGen,portList);

            hScriptGen.addEmptyLine(fileID);
        end

        function hDUTPort=createDUTPort(obj,hIOPort)











            if(hIOPort.isMatrix)
                dimension=hIOPort.Dimension;
            else
                dimension=[hIOPort.Dimension,1];
            end

            hDUTPort=fpgaio.data.DUTPort.constructFromIOPort(hIOPort,'Dimension',dimension,'IOInterface',obj.InterfaceID,'IOInterfaceMapping','');
        end

        function dataStr=getSampleDataStr(obj,portName)
            hIOPort=obj.hIOPortList.getIOPort(portName);
            if(hIOPort.PortType==hdlturnkey.IOType.IN)&&~obj.hFPGAInterface.isFrameMode



                dim=[obj.DefaultWriteFrameLength,1];
                hDUTPort=fpgaio.data.DUTPort.constructFromIOPort(hIOPort,'Dimension',dim);
                dataStr=hDUTPort.getSampleDataStr;
            else

                dataStr=getSampleDataStr@hdlturnkey.swinterface.SoftwareInterfaceBase(obj,portName);
            end
        end

        function portList=getDataPortList(obj)
            writePortName=obj.getWritePortName;
            readPortName=obj.getReadPortName;

            portList={};
            if~isempty(writePortName)
                portList{end+1}=writePortName;
            end
            if~isempty(readPortName)
                portList{end+1}=readPortName;
            end
        end

        function writePortName=getWritePortName(obj)

            writePortName='';

            channelIDList=obj.hFPGAInterface.getAssignedChannelIDList;
            for ii=1:length(channelIDList)
                hChannel=obj.hFPGAInterface.getChannel(channelIDList{ii});
                if hChannel.ChannelDirType==hdlturnkey.IOType.IN

                    hPort=hChannel.getDataPort;
                    writePortName=hPort.getAssignedPortName;
                    break;
                end
            end
        end

        function readPortName=getReadPortName(obj)

            readPortName='';

            channelIDList=obj.hFPGAInterface.getAssignedChannelIDList;
            for ii=1:length(channelIDList)
                hChannel=obj.hFPGAInterface.getChannel(channelIDList{ii});
                if hChannel.ChannelDirType==hdlturnkey.IOType.OUT

                    hPort=hChannel.getDataPort;
                    readPortName=hPort.getAssignedPortName;
                    break;
                end
            end
        end

        function isit=isAXI4StreamVectorSampleMode(obj)
            isit=false;
            InputVectorWithSampleMode=0;
            OutputVectorWithSampleMode=0;

            writePortName=obj.getWritePortName;
            if~isempty(writePortName)
                hIOPort=obj.hIOPortList.getIOPort(writePortName);
                if hIOPort.isVector&&~obj.hFPGAInterface.isFrameMode



                    InputVectorWithSampleMode=1;
                end
            end

            readPortName=obj.getReadPortName;
            if~isempty(readPortName)
                hIOPort=obj.hIOPortList.getIOPort(readPortName);
                if hIOPort.isVector&&~obj.hFPGAInterface.isFrameMode



                    OutputVectorWithSampleMode=1;
                end
            end

            if InputVectorWithSampleMode||OutputVectorWithSampleMode
                isit=true;
            end
        end
    end
end