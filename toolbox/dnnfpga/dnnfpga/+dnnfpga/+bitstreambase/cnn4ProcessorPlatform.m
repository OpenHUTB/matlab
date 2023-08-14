classdef cnn4ProcessorPlatform<dnnfpga.bitstreambase.abstractPlatform

    properties

        Verbose=dnnfpgafeature('Verbose');

    end

    properties(Access=protected)
hBitstream
hTarget
    end


    methods(Access=public,Hidden=true)
        function this=cnn4ProcessorPlatform(hBit,hT)
            this@dnnfpga.bitstreambase.abstractPlatform();



            this.hBitstream=hBit;
            this.hTarget=hT;
        end
    end


    methods(Access=public)
        function deploySanityCheck(~,~)
        end

        function executeSanityCheck(~,~,~,~)
        end

        function printAddress(~)
        end

        function setupProfiler(this,option)

        end

        function rawLogs=scanProfiler(this,options,fpgaLayer)



            debugMemDepth=fpgaLayer.getProcessor.getCC.debug.debugMemDepth;

            rawLogs=[];
            numLogsTS=this.readHWMemDMA_integration(fpgaLayer,'profilerTScounter',2,1);
            numLogsTS=dnnfpga.assembler.ConvtoUint32U(numLogsTS(1));

            numLogsMSG=this.readHWMemDMA_integration(fpgaLayer,'profilerMSGcounter',2,1);
            numLogsMSG=dnnfpga.assembler.ConvtoUint32U(numLogsMSG(1));


            if(numLogsTS==numLogsMSG)
                if(numLogsTS>0)

                    numLogs=numLogsTS;

                    timeStamps=this.readHWMemDMA_integration(fpgaLayer,'profilerTSmem',debugMemDepth,1);
                    timeStamps=dnnfpga.assembler.ConvtoUint32U(timeStamps);
                    logData=this.readHWMemDMA_integration(fpgaLayer,'profilerMSGmem',debugMemDepth,1);
                    logData=dnnfpga.assembler.ConvtoUint32U(logData);


                    [logDataSplit,timeStampsSplit,lastAddr]=this.getConcatedLogsSplit(logData,timeStamps,numLogs);

                    lastProcesorType=fpgaLayer.getForwardArgs.params{end}.type;



                    [logDataLastFrame,timeStampsLastFrame]=this.getMultiFrameLogsOrder(logDataSplit,timeStampsSplit,lastAddr,lastProcesorType);



                    rawLogs=struct('log',num2cell(logDataLastFrame),'timestamp',num2cell(timeStampsLastFrame));
                end
            else

                dnnfpga.disp(message('dnnfpga:dnnfpgadisp:ProfilerLogErr'),1,this.Verbose);
            end

            save('profileRawLogs.mat','rawLogs');
        end

        function[logDataSplit,timeStampsSplit,lastAddr]=getConcatedLogsSplit(this,logData,timeStamps,numLogs)




            logDataSplit=[];
            timeStampsSplit=[];


            lastAddr=numLogs;




            times=floor(double(lastAddr)/length(logData));
            lastAddr=lastAddr-times*length(logData);





            lastAddrLog=lastAddr;


            for i=1:length(logData)
                if logData(i)==0
                    break;
                else

                    DataBi=dec2bin(logData(i));

                    DataBiVector=[];
                    for xx=1:length(DataBi)
                        DataBiVector=[DataBiVector,uint32(str2double(DataBi(xx)))];
                    end
                    DataBi=DataBiVector;

                    timestamp=timeStamps(i);

                    concatIndex=find(DataBi);

                    for j=1:length(concatIndex)

                        logDataNew=zeros(1,length(DataBi));

                        logDataNew(concatIndex(j))=1;


                        logDataNew=num2str(logDataNew);
                        logDataNew=logDataNew(~isspace(logDataNew));
                        logDataNew=uint32(bin2dec(logDataNew));
                        logDataSplit=[logDataSplit,logDataNew];
                        timeStampsSplit=[timeStampsSplit,timestamp];
                    end

                    if length(concatIndex)>1
                        if lastAddrLog>=i
                            lastAddr=lastAddr+length(concatIndex)-1;
                        end
                    end

                end
            end
        end


        function checksum=readBitstreamChecksumFromFPGA(this)
            checksum='NOT_A_VALID_BITSTREAM_CHECKSUM';
            if this.hTarget.Interface~=dlhdl.TargetInterface.File
                checksum=this.readChecksumFromFPGA('bitstreamChecksum',8);
            end
        end
        function writeBitstreamChecksumToFPGA(this,checksum)
            this.writeChecksumToFPGA('bitstreamChecksum',checksum);
        end


        function checksum=readNetworkChecksumFromFPGA(this)
            checksum='NOT_A_VALID_NETWORK_CHECKSUM';
            if this.hTarget.Interface~=dlhdl.TargetInterface.File
                checksum=this.readChecksumFromFPGA('networkChecksum',4);
            end
        end
        function writeNetworkChecksumToFPGA(this,checksum)
            this.writeChecksumToFPGA('networkChecksum',checksum);
        end

    end


    methods(Access=protected)

        function hexValue=getHexValue(~,value)
            hexValue=dec2hex(typecast(value,'uint32'));
            if length(hexValue)<8
                str=repmat('0',1,8-length(hexValue));
                hexValue=[str,hexValue];
            end
        end

        function checksum=readChecksumFromFPGA(this,cksmName,vectorSize)



            checksum='';
            for i=1:vectorSize
                value=this.readValueFromRegister(cksmName,1,i-1);
                hexValue=this.getHexValue(value);
                checksum=strcat(checksum,hexValue);
            end
        end

        function writeChecksumToFPGA(this,cksmName,checksum)










            n=length(checksum)/8;
            startIndex=1;
            endIndex=startIndex+7;
            for i=1:n
                value=typecast(uint32(hex2dec(checksum(startIndex:endIndex))),'single');
                this.writeValueToRegister(cksmName,0,value,i-1);
                startIndex=endIndex+1;
                endIndex=startIndex+7;
            end
        end

        function readValue=readValueFromRegister(this,memSelect,addr,bank)











            if(nargin<4)
                bank=fi(0,0,16,0);
            else
                bank=fi(bank,0,16,0);
            end


            mode=1;
            hT=this.getTarget;
            baseAddr=this.getBaseAddr();
            debugTagObj=dnnfpga.debug.DebugTagCNN4;
            memS=bitconcat(bank,fi(uint16(debugTagObj.getDebugID(memSelect)),0,16,0));
            addrMap=dnnfpga.bitstreambase.platformUtilsBeta2.includeHWAddresses_integration(baseAddr);


            dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugEnable_offset')),true,hT);
            dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugSelect_offset')),memS,hT);
            dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugRdAddr_offset')),uint32(addr),hT);
            readValue=dnnfpga.hwutils.readSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugRdData_offset')),1,0,hT,'OutputDataType','single');
            dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugEnable_offset')),false,hT);
        end

        function writeValueToRegister(this,memSelect,addr,value,bank)











            if(nargin<5)
                bank=fi(0,0,16,0);
            else
                bank=fi(bank,0,16,0);
            end


            mode=1;
            hT=this.getTarget;
            baseAddr=this.getBaseAddr();
            debugTagObj=dnnfpga.debug.DebugTagCNN4;
            memS=bitconcat(bank,fi(uint16(debugTagObj.getDebugID(memSelect)),0,16,0));
            addrMap=dnnfpga.bitstreambase.platformUtilsBeta2.includeHWAddresses_integration(baseAddr);


            dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugEnable_offset')),true,hT);
            dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugSelect_offset')),memS,hT);
            dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugWrAddr_offset')),uint32(addr),hT);
            dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugWrData_offset')),single(value),hT);
            dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugValid_offset')),true,hT);
            dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugValid_offset')),false,hT);

        end

        function writeHWMemDMA_integration(this,fpgaLayer,conv_memSelect,conv_v,conv_width)





            baseAddr=this.getBaseAddr();
            addrMap=dnnfpga.bitstreambase.platformUtilsBeta2.includeHWAddresses_integration(baseAddr);
            hDDROffsetMap=fpgaLayer.getDDROffsetMap();


            hT=this.getTarget;


            conv_mode=1;
            debugTagObj=dnnfpga.debug.DebugTagCNN4;
            conv_memS=uint16(debugTagObj.getDebugID(conv_memSelect));


            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+hDDROffsetMap('debuggerScratchOffset')),conv_v,hT);
            conv_len=numel(conv_v);

            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugSelect_offset')),conv_memS,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAEnable_offset')),true,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMALength_offset')),uint32(conv_len),hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAWidth_offset')),uint32(conv_width),hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAOffset_offset')),uint32(hDDROffsetMap('debuggerScratchOffset')),hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMADirection_offset')),true,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugEnable_offset')),true,hT);

            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAStart_offset')),true,hT);
            while(dnnfpga.hwutils.readSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('conv_dma_from_ddr4_done')),1,0,hT,'OutputDataType','uint32')~=1)
                pause(1);
            end

            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAStart_offset')),false,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAEnable_offset')),false,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugEnable_offset')),false,hT);

            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAStart_offset')),false,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAEnable_offset')),false,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugEnable_offset')),false,hT);






        end

        function conv_readBack=readHWMemDMA_integration(this,fpgaLayer,conv_memSelect,conv_len,conv_width)





            baseAddr=this.getBaseAddr();
            addrMap=dnnfpga.bitstreambase.platformUtilsBeta2.includeHWAddresses_integration(baseAddr);
            hDDROffsetMap=fpgaLayer.getDDROffsetMap();


            hT=this.getTarget;


            conv_mode=1;
            debugTagObj=dnnfpga.debug.DebugTagCNN4;
            conv_memS=uint16(debugTagObj.getDebugID(conv_memSelect));



            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugSelect_offset')),conv_memS,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAEnable_offset')),true,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMALength_offset')),uint32(conv_len),hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAWidth_offset')),uint32(conv_width),hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAOffset_offset')),uint32(hDDROffsetMap('debuggerScratchOffset')),hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMADirection_offset')),false,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugEnable_offset')),true,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAStart_offset')),true,hT);
            while(dnnfpga.hwutils.readSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('conv_dma_to_ddr4_done')),1,0,hT,'OutputDataType','uint32')~=1)
                pause(dnnfpgafeature('HWPollingInterval'));
            end
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAStart_offset')),false,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugDMAEnable_offset')),false,hT);
            dnnfpga.hwutils.writeSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('conv_debugEnable_offset')),false,hT);

            conv_readBack=dnnfpga.hwutils.readSignal(conv_mode,dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+hDDROffsetMap('debuggerScratchOffset')),conv_len,zeros(1,conv_len),hT,'OutputDataType','single');

        end
    end

    methods(Access=protected)

        function hT=getTarget(this)
            hT=this.hTarget;

        end

        function baseAddr=getBaseAddr(this)
            ipBaseAddr=this.hBitstream.getDLProcessorAddressSpace;
            ddrBaseAddr=this.hBitstream.getDLMemoryAddressSpace;

            baseAddr.IPBaseAddr=ipBaseAddr;
            baseAddr.DDRBaseAddr=ddrBaseAddr;
        end
    end
end





