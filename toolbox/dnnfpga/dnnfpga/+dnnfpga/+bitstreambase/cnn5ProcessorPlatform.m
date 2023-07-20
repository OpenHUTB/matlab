classdef cnn5ProcessorPlatform<dnnfpga.bitstreambase.cnn4ProcessorPlatform



    methods

        function deploy(this,fpgaLayer)


            processor=fpgaLayer.getProcessor;
            convProc=processor.getBCC();
            dataType=convProc.convp.conv.kernelDataType;
            if(strcmp(dataType,'int8'))
                dataType='uint32';
            end
            baseAddr=this.getBaseAddr();
            addrMap=dnnfpga.bitstreambase.platformUtilsDAGNet.includeHWAddresses_integration(baseAddr);
            irParams=fpgaLayer.getDepolyableIR(true);


            hT=this.getTarget;


            hDDROffsetMap=fpgaLayer.getDDROffsetMap();
            LCOffset=hDDROffsetMap('InstructionDataOffset');
            initData=fpgaLayer.getData;


            hasConv=isfield(initData.weights,'conv');
            hasFC=isfield(initData.weights,'fc');
            hasAdder=isfield(initData.instructions,'adder');



            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('reset_offset')),1,hT);



            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('AXI1Rd_offset')),uint32(addrMap('ddrbase')),hT);

            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('AXI1Wr_offset')),uint32(addrMap('ddrbase')),hT);

            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('AXI2Rd_offset')),uint32(addrMap('ddrbase')),hT);

            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('AXI3Rd_offset')),uint32(addrMap('ddrbase')),hT);

            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('AXI3Wr_offset')),uint32(addrMap('ddrbase')),hT);


            convLCData=[];
            fcLCData=[];
            adderLCData=[];
            skdDDRAddr=hDDROffsetMap('SkdInstructionDataOffset');
            skdLCData=initData.instructions.scheduler;


            for i=1:1:length(irParams.values)
                value=irParams.values(i);
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+value.memoryRegion.baseAddr),...
                value.constValue,hT,'OutputDataType','single');
            end


            this.initializeStateData(fpgaLayer);


            if hasFC
                fcLCData=initData.instructions.fc;

                fcDDRAddr=hDDROffsetMap('FCInstructionDataOffset');

                fcWeightOffset=hDDROffsetMap('FCWeightDataOffset');

                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('fc_weight_ddr_addr')),fcWeightOffset,hT);
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('fc_lc_ddr_addr')),fcDDRAddr,hT);
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('fc_lc_ddr_len')),length(fcLCData),hT);


            end

            if hasConv
                syncData=fpgaLayer.getData.syncInstructions;

                this.writeHWMemDMA_integration(fpgaLayer,'syncIP0',syncData.ip,1);
                this.writeHWMemDMA_integration(fpgaLayer,'syncOP0',syncData.op,1);
                this.writeHWMemDMA_integration(fpgaLayer,'syncCONV',syncData.conv,1);

                convLCData=initData.instructions.conv;

                convWeightOffset=hDDROffsetMap('ConvWeightDataOffset');

                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('nc_LCoffset_IP0')),LCOffset,hT);
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('nc_LCtotalLength_IP0')),length(convLCData.ip),hT);
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('nc_LCoffset_Conv')),LCOffset+4*length(convLCData.ip),hT);
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('nc_LCtotalLength_Conv')),length(convLCData.conv),hT);
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('nc_LCoffset_OP0')),LCOffset+4*length(convLCData.ip)+4*length(convLCData.conv),hT);
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('nc_LCtotalLength_OP0')),length(convLCData.op),hT);
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('conv_weight_ddr_addr')),convWeightOffset,hT);
            end


            if hasAdder
                adderLCData=initData.instructions.adder;
                adderDDRAddr=hDDROffsetMap('AdderInstructionDataOffset');
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('adder_lc_addr')),adderDDRAddr,hT);
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('adder_lc_len')),length(adderLCData),hT);
            end


            if isempty(convLCData)
                LCDataAll=[convLCData,fcLCData,adderLCData,skdLCData];
            else
                LCDataAll=[convLCData.ip,convLCData.conv,convLCData.op,fcLCData,adderLCData,skdLCData];

            end








            if(strcmpi(hT.Vendor,'intel'))
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('has_handShaking')),true,hT);




                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('hs_ddr_addr')),hDDROffsetMap('debuggerScratchOffset'),hT);
            end


            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('skd_ddr_addr')),skdDDRAddr,hT);
            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('skd_ddr_len')),length(skdLCData),hT);


            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('inputStart')),false,hT);


            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+LCOffset),LCDataAll,hT);



            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('preLoadingStart')),false,hT);
            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('preLoadingStart')),true,hT);
            dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('preLoadingStart')),false,hT);


            if hasConv
                dnnfpga.disp(message('dnnfpga:dnnfpgadisp:LoadWgtConvProc'),1,this.Verbose);
                convWeightDataOffset=hDDROffsetMap('ConvWeightDataOffset');
                convWeightData=initData.weights.conv;
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+convWeightDataOffset),convWeightData,hT,'OutputDataType',dataType);
                dnnfpga.disp(message('dnnfpga:dnnfpgadisp:ConvWgtLoaded',string(datetime('now'))),1,this.Verbose);
            end
            if hasFC

                fcWeightOffset=hDDROffsetMap('FCWeightDataOffset');

                fcWeightData=initData.weights.fc;


                if(~strcmp(dataType,'single'))
                    fcWeightData=uint32(fcWeightData);
                end

                chunkSize=5e6;
                fc_WeightReadLength=length(fcWeightData);
                chunkNum=ceil(fc_WeightReadLength/chunkSize);


                if(chunkNum)
                    dnnfpga.disp(message('dnnfpga:dnnfpgadisp:LoadWgtFCProc'),1,this.Verbose);
                    for i=0:chunkNum-2
                        dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+fcWeightOffset+i*chunkSize*4),fcWeightData(i*chunkSize+1:(i+1)*chunkSize),hT,'OutputDataType',dataType);
                        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:DispProgress',int32((i+1)/chunkNum*100),string(datetime('now'))),1,this.Verbose);
                    end
                end


                if(chunkNum)
                    dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+fcWeightOffset+(chunkNum-1)*chunkSize*4),fcWeightData((chunkNum-1)*chunkSize+1:end),hT,'OutputDataType',dataType);
                    dnnfpga.disp(message('dnnfpga:dnnfpgadisp:FCWgtLoaded',string(datetime('now'))),1,this.Verbose);
                end
            end
        end

        function result=execute(this,inputData,fpgaLayer)


            import dnnfpga.dagCompile.DataFormat

            streamingMode=fpgaLayer.getStreamingMode;
            streamingContinuous=fpgaLayer.getStreamingContinuous;

            irParams=fpgaLayer.getDepolyableIR(true);


            [addrMap,dataType,inputOffset,resultOffset,useCustomBaseAddr]=this.executeSetup(fpgaLayer);

            isInt8=~strcmp(dataType,'single');


            inputStartAddr=dnnfpga.hwutils.numTo8Hex(addrMap('inputStart'));
            streamingModeAddr=dnnfpga.hwutils.numTo8Hex(addrMap('StreamingMode'));
            frameCountAddr=dnnfpga.hwutils.numTo8Hex(addrMap('FrameCount'));
            doneAddr=dnnfpga.hwutils.numTo8Hex(addrMap('done'));
            streamingDoneAddr=dnnfpga.hwutils.numTo8Hex(addrMap('StreamingDone'));
            inputStopAddr=dnnfpga.hwutils.numTo8Hex(addrMap('InputStop'));
            useCustomBaseAddrAddr=dnnfpga.hwutils.numTo8Hex(addrMap('UseCustomBaseAddr'));
            inputBaseAddrAddr=dnnfpga.hwutils.numTo8Hex(addrMap('InputBaseAddr'));
            outputBaseAddrAddr=dnnfpga.hwutils.numTo8Hex(addrMap('OutputBaseAddr'));



            processor=fpgaLayer.getProcessor;
            cc=processor.getCC();
            enableAxiStream=cc.enableAxiStream;
            if(~enableAxiStream)

                AXIStreamOutSize=dnnfpga.hwutils.numTo8Hex(addrMap('AXIStreamOutSize'));

                this.writeRegSignal(AXIStreamOutSize,uint32(0));
            end

            deployableDataType=dataType;
            if isInt8
                deployableDataType='uint32';
            end


            hT=this.getTarget;
            if(iscell(inputData))

                frameCount=uint32(size(inputData{1},2));
            else


                frameCount=uint32(size(inputData,2));
            end


            if streamingContinuous
                this.writeRegSignal(frameCountAddr,0);
            else
                this.writeRegSignal(frameCountAddr,frameCount);
            end

            if useCustomBaseAddr
                this.writeRegSignal(useCustomBaseAddrAddr,1);
                this.writeRegSignal(inputBaseAddrAddr,inputOffset);
                this.writeRegSignal(outputBaseAddrAddr,resultOffset);
            end


            function data=hwReadData(dataDescriptor,num,offset)
                if nargin<2
                    num=1;
                end
                if nargin<3
                    offset=0;
                end
                data=dagnet.shared.hwReadData(dataDescriptor,hT,addrMap('ddrbase'),inputOffset,resultOffset,num,offset);
            end

            if streamingMode

                dataHolder=dnnfpga.interact.DataHolder();
                for i=1:frameCount
                    for j=1:numel(inputData)
                        data=inputData{j}(:,i);
                        if isInt8
                            data=typecast(int8(data),'uint32');
                        end
                        dataHolder.addInputData(data);
                    end
                end
            else




                inputDataTobeWritten=[];
                if(iscell(inputData))
                    for frame=1:frameCount
                        for i=1:numel(inputData)
                            inputDataTobeWritten=[inputDataTobeWritten;reshape(inputData{i}(:,frame),[numel(inputData{i}(:,frame)),1])];
                        end
                    end
                else
                    inputDataTobeWritten=reshape(inputData,[numel(inputData),1]);
                end
                if isInt8
                    inputDataTobeWritten=typecast(int8(inputDataTobeWritten),'uint32');
                end
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+inputOffset),inputDataTobeWritten,hT,'OutputDataType',deployableDataType);
            end


            dnnfpga.disp(message('dnnfpga:dnnfpgadisp:FinWrInputAct'),1,this.Verbose);

            dataTransNum=fpgaLayer.getProcessor.getCC.dataTransNum;
            convThreadNum=fpgaLayer.getProcessor.getCC.convp.conv.threadNumLimit;
            if(~isempty(fpgaLayer.getProcessor.getCC.fcp))
                fcThreadNum=processor.getCC.fcp.threadNumLimit;
            else

                fcThreadNum=dataTransNum;
            end



            if~isempty(irParams.activations)
                tc=[];
                aSupport=[];
                try
                    tc=evalin('base','testcase__');
                    aSupport=dagnet.shared.ActivationsSupport(tc.snet,tc.img,irParams,hT,addrMap('ddrbase'),inputOffset,resultOffset);
                catch
                end

                swData=[];
                hwData=[];
                localData={1:100};
            end






            if irParams.isRNN
                if streamingMode
                    dnnfpga.disp(message('dnnfpga:dnnfpgadisp:StreamSequence',frameCount),1,this.Verbose);
                else
                    dnnfpga.disp(message('dnnfpga:dnnfpgadisp:RunSequence',frameCount),1,this.Verbose);
                end
            else
                if streamingMode
                    dnnfpga.disp(message('dnnfpga:dnnfpgadisp:RunStreaming',frameCount),1,this.Verbose);
                elseif frameCount==1
                    dnnfpga.disp(message('dnnfpga:dnnfpgadisp:RunSingleIpAct'),1,this.Verbose);
                else
                    dnnfpga.disp(message('dnnfpga:dnnfpgadisp:RunMultiframe',frameCount),1,this.Verbose);
                end
            end

            this.writeRegSignal(streamingModeAddr,streamingMode);

            this.pulseSignal(inputStartAddr);

            inputCount=uint32(0);
            outputCount=uint32(0);
            if streamingMode

                while this.readRegSignal(streamingDoneAddr)==uint32(0)
                    [wroteInput,readOutput]=this.handleData(addrMap,dataHolder,deployableDataType);
                    if wroteInput
                        inputCount=inputCount+1;
                    end
                    if readOutput
                        outputCount=outputCount+1;
                    end
                    if streamingContinuous&&inputCount>=frameCount
                        this.pulseSignal(inputStopAddr);
                    end
                    pause(0.1);
                end
            else

                jump=false;

                while(this.readRegSignal(doneAddr)==uint32(0))&&~jump
                    pause(0.1);
                end
            end












            frameSize=0;
            if isempty(irParams.outputs)
                outputComponents=fpgaLayer.getDepolyableIR.getSortedOutputComponents();


                outputComponentSizeOrig{1}=outputComponents{1}.inputs.net.size;

                outputDataFormat{1}=outputComponents{1}.inputs.net.dataFormat;
                numberOfOutputs=1;
            else

                outputNetList=[irParams.outputs.net];
                numberOfOutputs=length(outputNetList);
                outputComponentSizeOrig={};
                outputDataFormat={};
                outputMemRegion={};
                for outIndex=1:length(outputNetList)

                    outputComponentSizeOrig{outIndex}=outputNetList(outIndex).size;

                    outputDataFormat{outIndex}=outputNetList(outIndex).dataFormat;

                    outputMemRegion{outIndex}=irParams.outputs(outIndex).memoryRegion;


                    outputAddrOffset{outIndex}=outputMemRegion{outIndex}.baseAddr;

                    outputSize{outIndex}=irParams.outputs(outIndex).getDataCount;
                end
                frameSize=sum([outputSize{:}]);
            end
            for outIndex=1:numberOfOutputs

                outputComponentSize=dnnfpga.dagCompile.DDRSupport.normalizeSizeStatic(outputComponentSizeOrig{outIndex},dataTransNum,convThreadNum,outputDataFormat{outIndex},fcThreadNum);
                OutputFeatureNum=outputComponentSizeOrig{outIndex}(3);
                isOutputFromConv=isSameDataFormat(outputDataFormat{outIndex},DataFormat.Conv);


                resultCount=prod(outputComponentSize);



                currentOutputValue=zeros(resultCount,frameCount);
                currentOutputValue=cast(currentOutputValue,dataType);

                if isInt8
                    currentOutputValue=int8(currentOutputValue);
                end


                if streamingMode

                    for i=1:frameCount
                        data=dataHolder.getOutputData(i);
                        if isInt8
                            data=typecast(data,'int8');
                        end
                        currentOutputValue(:,i)=data;
                    end
                else


                    for i=1:frameCount
                        offset=resultCount;
                        if isInt8






                            DDRResultSize=ceil(resultCount/4);
                        else







                            DDRResultSize=resultCount;
                            offset=offset*4;
                        end

                        if isInt8


                            FCResultInt32Data=dnnfpga.hwutils.readSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+resultOffset+(i-1)*offset),DDRResultSize,cast(zeros(1,DDRResultSize),deployableDataType),hT,'OutputDataType',deployableDataType);
                            FCResultInt8Data=typecast(uint32(FCResultInt32Data),'int8');
                            currentOutputValue(:,i)=FCResultInt8Data(1:resultCount);
                        else


                            outputAddress=dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+resultOffset+outputAddrOffset{outIndex}+(i-1)*frameSize*4);
                            currentOutputValue(:,i)=dnnfpga.hwutils.readSignal(1,outputAddress,DDRResultSize,cast(zeros(1,DDRResultSize),deployableDataType),hT,'OutputDataType',deployableDataType);
                        end
                    end
                end


                if isOutputFromConv



                    resultConv=zeros([outputComponentSizeOrig{outIndex},frameCount]);
                    resultConv=cast(resultConv,dataType);
                    for i=1:frameCount


                        oneData=dnnfpga.format.convertDDRVectorFormatConv4To3DOutput(currentOutputValue(:,i),dataTransNum,outputComponentSize);

                        if convThreadNum<dataTransNum












                            dataTransChunck=1:dataTransNum:outputComponentSize(3);
                            threadNumChunck=dataTransChunck+convThreadNum-1;
                            validFeatureNum=cell2mat(arrayfun(@(startIndex,endIndex)startIndex:endIndex,dataTransChunck,threadNumChunck,'UniformOutput',false));
                            oneData=oneData(:,:,validFeatureNum);
                        end



                        oneData=oneData(:,:,1:OutputFeatureNum);
                        sz=size(oneData);

                        if numel(sz)==2
                            resultConv(:,:,1,i)=oneData;
                        else
                            resultConv(:,:,:,i)=oneData;
                        end
                    end


                    if(~isempty(fpgaLayer.getNotRunTiledLayerPos))
                        notRunTiledLayerPos=fpgaLayer.getNotRunTiledLayerPos;
                        size_=size(notRunTiledLayerPos);
                        for ii=1:size_(1)
                            idx=notRunTiledLayerPos(ii,:);
                            resultConv(idx(1)+1:idx(2),idx(3)+1:idx(4),:)=0;
                        end
                    end

                    currentOutputValue=resultConv;
                else


                    resultCountOrig=prod(outputComponentSizeOrig{outIndex});
                    nd=size(outputComponentSizeOrig{outIndex},2);
                    resultTrimmed=[];
                    for i=1:frameCount
                        oneData=currentOutputValue(:,i);


                        oneData=oneData(1:resultCountOrig);
                        oneData=reshape(oneData,outputComponentSizeOrig{outIndex});
                        resultTrimmed=cat(nd+1,resultTrimmed,oneData);
                    end
                    currentOutputValue=resultTrimmed;
                end
                result{outIndex,1}=currentOutputValue;
                result{outIndex,2}=isOutputFromConv;
            end
        end

        function initializeStateData(this,fpgaLayer)
            initOccurred=false;
            baseAddr=this.getBaseAddr();
            addrMap=dnnfpga.bitstreambase.platformUtilsDAGNet.includeHWAddresses_integration(baseAddr);

            processor=fpgaLayer.getProcessor;
            convProc=processor.getBCC();
            dataType=convProc.convp.conv.kernelDataType;

            irParams=fpgaLayer.getDepolyableIR(true);


            if(strcmp(dataType,'int8'))
                deployableDataType='uint32';
            else
                deployableDataType=dataType;
            end

            hT=this.getTarget;

            for dd=irParams.states
                sz=dd.memoryRegion.size;
                sz=sz/4;
                initData=zeros([1,sz],deployableDataType);

                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(addrMap('ddrbase')+dd.memoryRegion.getAddr),...
                initData,hT,'OutputDataType',deployableDataType);
                initOccurred=true;
            end
            if initOccurred
                dnnfpga.disp(message('dnnfpga:dnnfpgadisp:ResetNetwork'));
            end
        end

        function rawLogs=scanProfiler(this,options,fpgaLayer)

            baseAddr=this.getBaseAddr();
            addrMap=dnnfpga.bitstreambase.platformUtilsDAGNet.includeHWAddresses_integration(baseAddr);


            debugMemDepth=fpgaLayer.getProcessor.getCC.debug.debugMemDepth;

            rawLogs=[];
            numLogsTS=this.readHWMemDMA_integration(fpgaLayer,'profilerTScounter',2,1);
            numLogsTS=dnnfpga.assembler.ConvtoUint32U(numLogsTS(1));

            numLogsMSG=this.readHWMemDMA_integration(fpgaLayer,'profilerMSGcounter',2,1);
            numLogsMSG=dnnfpga.assembler.ConvtoUint32U(numLogsMSG(1));

            perfOverflowAddr=dnnfpga.hwutils.numTo8Hex(addrMap('PerfCounterOverflow'));
            counterOverflow=this.readRegSignal(perfOverflowAddr);

            if(numLogsTS==numLogsMSG)
                if(counterOverflow)
                    error(message('dnnfpga:dnnfpgadisp:ProfilerCounterOverflow'));
                elseif(numLogsTS<=0)


                    dnnfpga.disp(message('dnnfpga:dnnfpgadisp:ProfilerLogErr'),1,this.Verbose);
                else

                    numLogs=numLogsTS;

                    timeStamps=this.readHWMemDMA_integration(fpgaLayer,'profilerTSmem',debugMemDepth,1);
                    timeStamps=dnnfpga.assembler.ConvtoUint32U(timeStamps);
                    logData=this.readHWMemDMA_integration(fpgaLayer,'profilerMSGmem',debugMemDepth,1);
                    logData=dnnfpga.assembler.ConvtoUint32U(logData);


                    [logDataSplit,timeStampsSplit,lastAddr]=this.getConcatedLogsSplit(logData,timeStamps,numLogs);


                    [logDataNew,timeStampsNew]=this.getMultiFrameLogsOrder(fpgaLayer,logDataSplit,timeStampsSplit,lastAddr);


                    totalExecutionTime=this.readHWMemDMA_integration(fpgaLayer,'profilerTimeCounter',1,1);
                    totalExecutionTime=dnnfpga.assembler.ConvtoUint32U(totalExecutionTime);


                    eventAndTimeStamp=struct('log',num2cell(logDataNew),'timestamp',num2cell(timeStampsNew));
                    rawLogs=struct('eventAndTimeStamp',eventAndTimeStamp,'totalExecutionTime',totalExecutionTime);
                end
            end

            save('profileRawLogs.mat','rawLogs');
        end


    end
    methods(Access=protected)

        function[logDataNew,timeStampsNew]=getMultiFrameLogsOrder(~,fpgaLayer,logData,timeStamps,lastAddr)

            import dnnfpga.dagCompile.*







            frameStartSignalValue=2^27;



            realEventNum=length(logData);














            frameStart=1;
            for idx=horzcat(flip(1:lastAddr-1),flip(lastAddr+1:realEventNum))
                if logData(idx)==frameStartSignalValue
                    frameStart=idx;
                    break;
                end
            end







            for(compNum=1:length(fpgaLayer.getDepolyableIR.sortedComponents))
                FPGAComponent=fpgaLayer.getDepolyableIR.sortedComponents(compNum);
                if(FPGAComponent.hasKind(LayerKind.SoftToHard))
                    compNum=compNum+1;
                    break;
                end
            end
            firstFPGAComponent=fpgaLayer.getDepolyableIR.sortedComponents(compNum);


            if firstFPGAComponent.hasKind(LayerKind.Conv)
                leadingSignalValue=2^10;
            elseif firstFPGAComponent.hasKind(LayerKind.FC)
                leadingSignalValue=2^15;
            elseif firstFPGAComponent.hasKind(LayerKind.Add)||...
                firstFPGAComponent.hasKind(LayerKind.CustomLayer)





                leadingSignalValue=2^21;
            else
                leadingSignalValue=2^27;
            end


            if lastAddr>frameStart

                indexRange=frameStart:lastAddr;
            else

                indexRange=frameStart:realEventNum;
            end


            startIdx=frameStart;
            for idx=indexRange
                if logData(idx)==leadingSignalValue
                    startIdx=idx;
                    break;
                end
            end


            if lastAddr>startIdx

                logDataNew=logData(startIdx:lastAddr);
                timeStampsNew=timeStamps(startIdx:lastAddr);
            else

                logDataNew=logData(startIdx:realEventNum);
                logDataNew=[logDataNew,logData(1:lastAddr)];
                timeStampsNew=timeStamps(startIdx:realEventNum);
                timeStampsNew=[timeStampsNew,timeStamps(1:lastAddr)];
            end
        end

        function[addrMap,dataType,inputOffset,resultOffset,useCustomBaseAddr]=executeSetup(this,fpgaLayer)

            import dnnfpga.dagCompile.DataFormat



            baseAddr=this.getBaseAddr();
            addrMap=dnnfpga.bitstreambase.platformUtilsDAGNet.includeHWAddresses_integration(baseAddr);
            hDDROffsetMap=fpgaLayer.getDDROffsetMap();
            useCustomBaseAddr=false;
            if isKey(hDDROffsetMap,'InputDataOffsetAlt')
                useCustomBaseAddr=true;
                inputOffset=hDDROffsetMap('InputDataOffsetAlt');
            else
                inputOffset=hDDROffsetMap('InputDataOffset');
            end
            if isKey(hDDROffsetMap,'OutputResultOffsetAlt')
                useCustomBaseAddr=true;
                resultOffset=hDDROffsetMap('OutputResultOffsetAlt');
            else
                resultOffset=hDDROffsetMap('OutputResultOffset');
            end

            processor=fpgaLayer.getProcessor;
            convProc=processor.getBCC();
            dataType=convProc.convp.conv.kernelDataType;


            if(strcmp(dataType,'int8'))
                deployableDataType='uint32';
            else
                deployableDataType=dataType;
            end


            debugMemDepth=fpgaLayer.getProcessor.getCC.debug.debugMemDepth;
            this.writeHWMemDMA_integration(fpgaLayer,'profilerTSmem',zeros(1,debugMemDepth),1);
            this.writeHWMemDMA_integration(fpgaLayer,'profilerMSGmem',zeros(1,debugMemDepth),1);




            switch this.Verbose
            case 1

                this.writeHWMemDMA_integration(fpgaLayer,'profilerControl',bin2dec('1100001111111100011001000000'),36);
            case 2

                this.writeHWMemDMA_integration(fpgaLayer,'profilerControl',bin2dec('1100001111111101111111001100'),36);
            case 3

                this.writeHWMemDMA_integration(fpgaLayer,'profilerControl',bin2dec('1111111111111100011001111111'),36);
            otherwise
                error(message('dnnfpga:quantization:UnsuppVerboseMode'));
            end

        end

        function pulseSignal(this,addressInHex)

            hT=this.getTarget;
            dnnfpga.hwutils.writeSignal(1,addressInHex,false,hT);
            dnnfpga.hwutils.writeSignal(1,addressInHex,true,hT);
            dnnfpga.hwutils.writeSignal(1,addressInHex,false,hT);
        end
        function writeRegSignal(this,addressInHex,value)
            hT=this.getTarget;
            dnnfpga.hwutils.writeSignal(1,addressInHex,value,hT);
        end
        function value=readRegSignal(this,addressInHex)
            hT=this.getTarget;
            value=dnnfpga.hwutils.readSignal(1,addressInHex,1,zeros(1,1),hT,'OutputDataType','uint32');
        end

        function[wroteInput,readOutput]=handleData(this,addrMap,dataHolder,dataType)
            wroteInput=false;
            readOutput=false;
            inputValid=this.readRegSignal(dnnfpga.hwutils.numTo8Hex(addrMap('InputValid')));
            if inputValid
                wroteInput=true;
                hT=this.getTarget;
                inputAddr=addrMap('ddrbase')+this.readRegSignal(dnnfpga.hwutils.numTo8Hex(addrMap('InputAddr')));
                data=dataHolder.getInputData();
                dnnfpga.hwutils.writeSignal(1,dnnfpga.hwutils.numTo8Hex(inputAddr),data,hT,'OutputDataType',dataType);
                this.pulseSignal(dnnfpga.hwutils.numTo8Hex(addrMap('InputNext')));
            end
            outputValid=this.readRegSignal(dnnfpga.hwutils.numTo8Hex(addrMap('OutputValid')));
            if outputValid
                readOutput=true;
                hT=this.getTarget;
                outputAddr=addrMap('ddrbase')+this.readRegSignal(dnnfpga.hwutils.numTo8Hex(addrMap('OutputAddr')));
                outputSize=this.readRegSignal(dnnfpga.hwutils.numTo8Hex(addrMap('OutputSize')));
                outputSize=outputSize/4;
                data=dnnfpga.hwutils.readSignal(1,dnnfpga.hwutils.numTo8Hex(outputAddr),outputSize,cast(zeros(1,outputSize),dataType),hT,'OutputDataType',dataType);
                dataHolder.addOutputData(data);
                this.pulseSignal(dnnfpga.hwutils.numTo8Hex(addrMap('OutputNext')));
            end
        end
    end
end





