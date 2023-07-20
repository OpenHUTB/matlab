classdef cnn5ProcessorBackend<dnnfpga.compiler.cnn4ProcessorBackend




    methods(Access=public,Hidden=true)
        function obj=cnn5ProcessorBackend(verbose)
            obj@dnnfpga.compiler.cnn4ProcessorBackend(verbose);
        end

    end

    methods(Access=public)

        function deployableNW=doit(this,hIR,processor,varargin)







            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'InputFrameNumberLimit',2,@isnumeric);

            addParameter(p,'ExternalMemorySize',[],@isnumeric);
            addParameter(p,'ProcessorConfig',[]);

            parse(p,varargin{:});
            inputFrameNumberLimit=p.Results.InputFrameNumberLimit;
            externalMemorySize=p.Results.ExternalMemorySize;
            hPC=p.Results.ProcessorConfig;



            chipConfig=processor.getCC;
            dataTransNum=chipConfig.dataTransNum;


            [~,isQuantized]=dnnfpga.compiler.processorKernelType(processor);

            outputComponents=hIR.sgraph.getSortedOutputComponents();


            index=1;
            inputImageSizes={};
            for i=1:numel(hIR.network.Layers)
                if dnnfpga.dagCompile.Layers.isInput(hIR.network.Layers(i))
                    inputImageSize=hIR.network.Layers(i).InputSize;
                    if isscalar(inputImageSize)
                        inputImageSize=[1,1,inputImageSize];
                    end
                    inputImageSizes{index}=inputImageSize;
                    index=index+1;
                end
            end
            outputImageSizes=cell(numel(outputComponents),1);
            for i=1:numel(outputComponents)
                outputImageSizes{i}=outputComponents{i}.inputs.net.size;
                outputImageSizes{i}(3)=ceil(outputImageSizes{i}(3)/dataTransNum)*dataTransNum;
            end

            this.preCalculateDDRBufferOffsets(hIR,processor,inputImageSizes,outputImageSizes,...
            inputFrameNumberLimit,hIR.ddrSupport);

            [deployableNW,scheduleData]=this.constructDeployableNetwork(hIR,processor,varargin{:});

            this.addSchedule(hIR,deployableNW,scheduleData,processor,hPC);



            allocatedMemorySize=this.postCalculateDDRBufferOffsets(hIR,deployableNW,isQuantized);


            table=this.getDDROffsetTable;
            this.displayDDROffsetTable(this.verbose);





            if allocatedMemorySize>externalMemorySize
                error(message('dnnfpga:dnnfpgacompiler:DLNetworkMemSizeTooLarge',dec2hex(allocatedMemorySize),dec2hex(externalMemorySize)));
            end



            deployableNW.getSingletonFPGALayer.generateNetworkChecksum;




            deployableNW.getSingletonFPGALayer.setDDROffsetMap(this.hDDROffsetMap);







            params=struct();
            params.sgraph=hIR.sgraph;
            params.inputs=hIR.inputs;
            params.outputs=hIR.outputs;
            params.states=hIR.states;
            params.activations=hIR.activations;
            params.values=hIR.values;
            params.isRNN=hIR.isRNN;
            deployableNW.getSingletonFPGALayer.setDepolyableIR(params);



            deployableNW.setDDROffsetTable(table);
            deployableNW.setInputFrameNumberLimit(inputFrameNumberLimit);




            deployableNW.setOutputComponentsList(hIR.ngraph.getOutputComponents);

        end
    end

    methods(Access=protected)

        function preCalculateDDRBufferOffsets(this,hIR,processor,inputImageSizes,outputImageSizes,inputFrameNumberLimit,ddrSupport)












            startOffset=hex2dec('00000000');

            chipConfig=processor.getCC;
            dataTransNum=chipConfig.dataTransNum;
            [~,isQuantized]=dnnfpga.compiler.processorKernelType(processor);
            if(isQuantized)


                scaleFactorForAddr=1;
            else
                scaleFactorForAddr=4;
            end



            inputDataOffset=startOffset;


            totalInputSize=0;
            for i=1:numel(inputImageSizes)
                totalInputSize=totalInputSize+dnnfpga.format.ceilSizeToDataParallelTransferNumber(inputImageSizes{i},dataTransNum);
            end
            totalOutputSize=0;
            for i=1:numel(outputImageSizes)
                totalOutputSize=totalOutputSize+prod(outputImageSizes{i});
            end


            totalInputBufferSize=this.getAlignedSize(totalInputSize*inputFrameNumberLimit*scaleFactorForAddr);

            outputResultOffset=inputDataOffset+totalInputBufferSize;


            this.hDDROffsetMap('InputDataOffset')=ddrSupport.hDDROffsetMap('InputDataOffset');
            this.hDDROffsetMap('OutputResultOffset')=ddrSupport.hDDROffsetMap('OutputResultOffset');
            this.hDDROffsetMap('OutputResultEndOffset')=ddrSupport.hDDROffsetMap('OutputResultEndOffset');
            this.hDDROffsetMap('SchedulerDataOffset')=ddrSupport.hDDROffsetMap('SchedulerDataOffset');
            this.hDDROffsetMap('SchedulerDataEndOffset')=ddrSupport.hDDROffsetMap('SchedulerDataEndOffset');

            systemBridgeBufferOffset=ddrSupport.hDDROffsetMap('EndOffset');
            debuggerScratchOffset=ddrSupport.hDDROffsetMap('EndOffset');


            this.hDDROffsetMap('SystemBufferOffset')=systemBridgeBufferOffset;






            totalBridgeBufferSize=this.getAlignedSize(totalOutputSize*scaleFactorForAddr);

            convInputBufferOffset=systemBridgeBufferOffset+totalBridgeBufferSize;





            maxConvIntermActivationSizeLimit=totalInputSize;




            hasConv=false;
            for currComponent=hIR.ngraph.components'
                if currComponent.hasKind(dnnfpga.dagCompile.LayerKind.Conv)
                    for i=1:numel(currComponent.outputs)
                        pinst=currComponent.outputs(i);
                        currComponentOutputSize=hIR.ddrSupport.normalizeSize(pinst.net.size,pinst.net.dataFormat);
                        convLayerOutputSizeLimit=prod(currComponentOutputSize);
                        if convLayerOutputSizeLimit>maxConvIntermActivationSizeLimit
                            maxConvIntermActivationSizeLimit=convLayerOutputSizeLimit;
                        end
                    end
                    hasConv=true;
                end
            end
            if hasConv

                totalConvIntermBufferSize=this.getAlignedSize(maxConvIntermActivationSizeLimit*scaleFactorForAddr);

                convOutputBufferOffset=convInputBufferOffset+totalConvIntermBufferSize;

                debuggerScratchOffset=convOutputBufferOffset+totalConvIntermBufferSize;

                this.hDDROffsetMap('convInputBufferOffset')=convInputBufferOffset;
                this.hDDROffsetMap('convOutputBufferOffset')=convOutputBufferOffset;
            else


                debuggerScratchOffset=systemBridgeBufferOffset+totalBridgeBufferSize;
            end
            this.hDDROffsetMap('debuggerScratchOffset')=debuggerScratchOffset;

        end
        function allocatedMemorySize=postCalculateDDRBufferOffsets(this,hIR,deployableNW,isQuantized)









            if(isQuantized)


                scaleFactorForAddr=4;
            else
                scaleFactorForAddr=4;
            end

            function v=alignUp(value)
                v=hIR.ddrSupport.align.roundUp(value);
            end


            fpgaLayer=deployableNW.getSingletonFPGALayer;
            fpgaData=fpgaLayer.getData;



            totalDebuggerScrachBufferSize=alignUp(hex2dec('01000000'));


            instructionDataOffset=this.hDDROffsetMap('debuggerScratchOffset')+totalDebuggerScrachBufferSize;

            this.hDDROffsetMap('InstructionDataOffset')=instructionDataOffset;

            currentOffset=instructionDataOffset;

            convLCDataAll=[];
            fcLCDataAll=[];
            adderLCDataAll=[];
            hasConv=isfield(fpgaData.weights,'conv');
            hasFC=isfield(fpgaData.weights,'fc');

            if hasConv

                convLCData=fpgaData.instructions.conv;
                convLCDataAll=[convLCData.ip,convLCData.conv,convLCData.op];
                this.hDDROffsetMap('ConvIPInstructionDataOffset')=currentOffset;
                this.hDDROffsetMap('ConvInstructionDataOffset')=this.hDDROffsetMap('ConvIPInstructionDataOffset')+4*numel(convLCData.ip);
                this.hDDROffsetMap('ConvOPInstructionDataOffset')=this.hDDROffsetMap('ConvInstructionDataOffset')+4*numel(convLCData.conv);
                currentOffset=this.hDDROffsetMap('ConvOPInstructionDataOffset')+4*numel(convLCData.op);
            end
            if hasFC

                fcLCDataAll=fpgaData.instructions.fc;
                this.hDDROffsetMap('FCInstructionDataOffset')=currentOffset;
                currentOffset=this.hDDROffsetMap('FCInstructionDataOffset')+4*numel(fcLCDataAll);
            end

            if isfield(fpgaData.instructions,'adder')
                adderLCDataAll=fpgaData.instructions.adder;
                this.hDDROffsetMap('AdderInstructionDataOffset')=currentOffset;
                currentOffset=this.hDDROffsetMap('AdderInstructionDataOffset')+4*numel(adderLCDataAll);
            end


            skdLCDataAll=fpgaData.instructions.scheduler;



            this.hDDROffsetMap('SkdInstructionDataOffset')=currentOffset;

            currentOffset=this.hDDROffsetMap('SkdInstructionDataOffset')+4*numel(skdLCDataAll);
            currentOffset=alignUp(currentOffset);


            LCDataAll=[convLCDataAll,fcLCDataAll,adderLCDataAll,skdLCDataAll];
            LCDataSize=length(LCDataAll);


            totalLCBufferSize=alignUp(LCDataSize*4);

            if hasConv

                convWeightDataOffset=currentOffset;
                convWeightDataSize=length(fpgaData.weights.conv);
                this.hDDROffsetMap('ConvWeightDataOffset')=convWeightDataOffset;


                totalConvWeightBufferSize=alignUp(convWeightDataSize*scaleFactorForAddr);
                currentOffset=currentOffset+totalConvWeightBufferSize;
            end







            if hasFC

                fcWeightDataOffset=currentOffset;
                this.hDDROffsetMap('FCWeightDataOffset')=fcWeightDataOffset;


                fcWeightDataSize=length(fpgaData.weights.fc);
                totalFCWeightBufferSize=this.getAlignedSize(fcWeightDataSize*scaleFactorForAddr);
                currentOffset=currentOffset+totalFCWeightBufferSize;
            end







            this.hDDROffsetMap('EndOffset')=currentOffset;


            allocatedMemorySize=currentOffset;

        end

        function layerOutputFromFPGA=insertOutputFromFPGA(this)

            layerOutputFromFPGA=dnnfpga.deployablenetwork.swLayer('OutputFromFPGA',@(input)(dnnfpga.compiler.cnn5LegBackend.reshapeMulti(input)));
        end

        function layerInputToFPGA=insertInputToFPGA(this,cnnp)


            processor=cnnp;
            conv2Processor=processor.getConvProcessor().getConvProcessor();
            convThreadNum=conv2Processor.getCC.threadNumLimit;
            dataTransNum=processor.getCC.dataTransNum;
            layerInputToFPGA=dnnfpga.deployablenetwork.swLayer('InputToFPGA',@(input)(dnnfpga.processorbase.conv4Processor.getSeqImage(input,convThreadNum,dataTransNum)));
        end

        function layer=insertQuantizeInput(this,singleToInt8Exp)


            foo=@(input)(dnnfpga.processorbase.processorUtils.singleToInt8Conversion([],input,singleToInt8Exp));
            layer=dnnfpga.deployablenetwork.swLayer('QuantizeInput',foo);
        end
        function layer=insertQuantizeOutput(this,int8ToSingleExp)


            foo=@(input)(dnnfpga.processorbase.processorUtils.int8ToSingleConversion([],input,int8ToSingleExp));
            layer=dnnfpga.deployablenetwork.swLayer('QuantizeOutput',foo);
        end


        function layer=insertUnpool(~,outputSize)

            foo=@(input)(dnnfpga.processorbase.processorUtils.Unpool([],input,outputSize));
            layer=dnnfpga.deployablenetwork.swLayer('Unpool',foo);
        end

        function[deployableNW,scheduleData]=constructDeployableNetwork(this,hIR,cnnp,varargin)


            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'ActivationLayer','',@ischar);
            parse(p,varargin{:});
            activationLayer=p.Results.ActivationLayer;

            scheduleData=[];



            import dnnfpga.dagCompile.*;

            deployableNWData=struct('weights',[],'instructions',[],'registers',[]);
            hasFPGALayer=false;
            fpgaLayerIndex=0;
            topLevelLayers={};
            fcWeightBaseAddrOffset=0;

            convWeightBaseAddrOffset=0;
            [dataType,isQuantized]=dnnfpga.compiler.processorKernelType(cnnp);
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'InputFrameNumberLimit',30,@isnumeric);
            addParameter(p,'exponentData',[]);
            parse(p,varargin{:});
            exponentsData=p.Results.exponentData;




            sortedComponents=hIR.sgraph.sortedComponents;

            topLevelSyncInstruction=this.initialzeTopLevelSyncInstruction;

            for i=1:numel(sortedComponents)
                component=sortedComponents(i);
                if dnnfpga.dagCompile.SeriesCompiler.canCreateSeriesNetwork(component)











                    strOutput=sprintf('Compiling layer group: %s ...',component.name);
                    dnnfpga.disp(strOutput,1,this.verbose);

                    sn=dnnfpga.dagCompile.SeriesCompiler.createSeriesNework(component);
                    if(isQuantized)





















                        getInput=strsplit(component.inputs(1).net.name,'/');
                        if(strcmp(getInput(1),'SWToFPGA'))





                            parent_lvl1=component.inputs(1).net.driver.component;
                            parent_lvl2=parent_lvl1.inputs.net.driver.component;
                            parent_lvl3=parent_lvl2.inputs.net.driver.component;
                            newInputLayer=imageInputLayer([sn.Layers(1).InputSize],'Normalization','none','Name',parent_lvl3.name);
                        else
                            inputLayerName=getInput{1};
                            newInputLayer=imageInputLayer([sn.Layers(1).InputSize],'Normalization','none','Name',inputLayerName);
                        end

                        layers=[newInputLayer
                        sn.Layers(2:end)];
                        sn=assembleNetwork(layers);













                    end







                    sn=dnnfpga.compiler.optimizations.optimizeNetwork(sn);

                    strOutput=evalc('disp(sn.Layers)');
                    dnnfpga.disp(strOutput,2,this.verbose);










                    hLegLevelDDRAddrOffsetMap=containers.Map('KeyType','char','ValueType','uint32');
                    hLegLevelDDRAddrOffsetMap('InputBufferOffset')=hIR.ddrSupport.memoryRegions(component.inputs(1).net.id).getAddr;
                    hLegLevelDDRAddrOffsetMap('OutputBufferOffset')=hIR.ddrSupport.memoryRegions(component.outputs.net.id).getAddr;


                    maxpoolType=0;
                    if component.hasKind(LayerKind.MaxpoolIndex)
                        maxpoolType=1;
                    elseif component.hasKind(LayerKind.MaxpoolData)
                        maxpoolType=2;
                    end
                    hasUnpool=false;
                    if component.hasKind(LayerKind.Unpool)
                        hasUnpool=true;
                    end

                    hasTransposedConv=component.hasKind(LayerKind.TransposedConv);


                    if hasUnpool


                        netid=component.inputs(2).net.id;
                        convWeightOffset=hIR.ddrSupport.memoryRegions(netid).baseAddr;
                        unpoolRemainder=component.outputs.net.size(1:2)-component.inputs(1).net.size(1:2).*component.nLayer.FilterSize;
                        unpoolRemainder=unpoolRemainder.';
                    else


                        convWeightOffset=convWeightBaseAddrOffset;
                        unpoolRemainder=[0;0];
                    end





                    if(~isempty(component.outputExp))
                        for pp=1:numel(exponentsData)
                            if(strcmpi(exponentsData(pp).Name,component.nLayer(end).Name))
                                exponentsData(pp).Exponent=component.outputExp;
                                break;
                            end
                        end
                    end





                    parentDataFormat=component.inputs(1).net.dataFormat;

                    legLevelDeployableNW=dnnfpga.compiler.codegenfpga(sn,cnnp,...
                    'Verbose',this.verbose,...
                    'LegLevel',true,...
                    'ParentDataFormat',parentDataFormat,...
                    'FCWeightBaseAddrOffset',fcWeightBaseAddrOffset,...
                    'convWeightBaseAddrOffset',convWeightOffset,...
                    'TopLevelDDRAddrOffsetMap',this.hDDROffsetMap,...
                    'LegLevelDDRAddrOffsetMap',hLegLevelDDRAddrOffsetMap,...
                    'exponentData',exponentsData,...
                    'hasTrueOutputLayer',false,...
                    'hasTrueInputLayer',false,...
                    'maxpoolType',maxpoolType,...
                    'hasUnpool',hasUnpool,...
                    'unpoolRemainder',unpoolRemainder,...
                    'hasTransposedConv',hasTransposedConv);




                    if~hasFPGALayer

                        topLevelLayers{end+1}=dnnfpga.deployablenetwork.fpgaLayer('FPGA_CNN',cnnp,[]);

                        fpgaLayerIndex=numel(topLevelLayers);
                        hasFPGALayer=true;
                    end

                    legLevelFPGALayer=legLevelDeployableNW.getSingletonFPGALayer;


                    component.LegLevelIR=legLevelFPGALayer.getForwardArgs.params;

                    stitchNewData=legLevelFPGALayer.getData;
                    [deployableNWData,opData]=this.stitchDeployableNetworkData(deployableNWData,stitchNewData);


                    [topLevelSyncInstruction]=this.stitchSyncInstruction(topLevelSyncInstruction,stitchNewData,component.name);
                    scheduleData{end+1}=opData;


                    if isfield(stitchNewData.weightBaseAddrOffset,'fc')
                        fcWeightBaseAddrOffset=stitchNewData.weightBaseAddrOffset.fc;
                    end


                    if hasUnpool
                        difference=stitchNewData.weightBaseAddrOffset.conv-convWeightOffset;
                        convWeightBaseAddrOffset=convWeightBaseAddrOffset+difference;
                    else
                        if isfield(stitchNewData.weightBaseAddrOffset,'conv')
                            convWeightBaseAddrOffset=stitchNewData.weightBaseAddrOffset.conv;
                        end
                    end


                    strOutput=sprintf('Compiling layer group: %s ... complete.',component.name);
                    dnnfpga.disp(strOutput,1,this.verbose);

                elseif component.isJoin||component.hasKind(LayerKind.CustomLayer)
                    if~hasFPGALayer

                        topLevelLayers{end+1}=dnnfpga.deployablenetwork.fpgaLayer('FPGA_CNN',cnnp,[]);

                        fpgaLayerIndex=numel(topLevelLayers);
                        hasFPGALayer=true;
                    end
                    if component.hasKind(LayerKind.Add)||component.hasKind(LayerKind.CustomLayer)



                        param=struct;
                        param.type='FPGA_Adder';
                        param.phase=component.nLayer(1).Name;
                        param.params={param};
                        component.LegLevelIR={param};


                        stitchNewData.seqOp=[];
                        stitchNewData.adder=dnnfpga.processorbase.adderProcessor.getModuleSeqLC(component,hIR.ddrSupport);
                        deployableNWData=this.stitchDeployableNetworkData(deployableNWData,stitchNewData);

                    elseif isa(component.nLayer,'nnet.cnn.layer.MaxUnpooling2DLayer')


                        topLevelLayers{end+1}=this.insertUnpool(component.outputs.net.size);
                    else

                        strOutput=sprintf('Do nothing: %s',component.name);
                        dnnfpga.disp(strOutput,2,this.verbose);
                    end
                elseif component.hasKind(LayerKind.HardToSoft)
                    topLevelLayers{end+1}=this.insertOutputFromFPGA();
                    nextComponent=component.outputs.net.receivers.component;
                    while(~nextComponent.isOutput)






                        topLevelLayers=this.insertOutputLayer(nextComponent,topLevelLayers);


                        nextComponent.deployableLayerCreated=true;
                        nextComponent=nextComponent.outputs.net.receivers.component;
                    end

                    for nLayerIdx=1:numel(nextComponent.nLayer)
                        layer=nextComponent.nLayer(nLayerIdx);
                        topLevelLayers{end+1}=dnnfpga.deployablenetwork.swLayer(layer,@(input)(dnnfpga.compiler.compilerUtils.SNLayerPredict(layer,input)));
                    end
                    nextComponent.deployableLayerCreated=true;
                elseif component.hasKind(LayerKind.SoftToHard)

                    topLevelLayers{end+1}=this.insertInputToFPGA(cnnp);
                elseif component.hasKind(LayerKind.QuantIn)

                    topLevelLayers{end+1}=this.insertQuantizeInput(component.inputExp);
                elseif component.hasKind(LayerKind.Hard)

                else
                    if(~component.deployableLayerCreated)
                        for nLayerIdx=1:numel(component.nLayer)
                            layer=component.nLayer(nLayerIdx);
                            topLevelLayers{end+1}=dnnfpga.deployablenetwork.swLayer(layer,@(input)(dnnfpga.compiler.compilerUtils.SNLayerPredict(layer,input)));
                        end
                    end

                    strOutput=sprintf('Skipping: %s',component.name);
                    dnnfpga.disp(strOutput,2,this.verbose);
                end
            end

            if hasFPGALayer


                deployableNWData=this.emitSyncInstruction(topLevelSyncInstruction,cnnp,deployableNWData);



                values={};
                for i=1:length(hIR.values)
                    values={values,hIR.values(i).constValue};
                end
                deployableNWData.constantData=values;
                topLevelLayers{fpgaLayerIndex}.setData(deployableNWData);
            end


            deployableNW=dnnfpga.deployablenetwork.deployableNetwork(topLevelLayers);


            deployableNW.getSingletonFPGALayer.setActivationLayer(activationLayer);
        end

        function topLevelLayers=insertOutputLayer(this,component,topLevelLayers)

            if component.hasKind(dnnfpga.dagCompile.LayerKind.QuantOut)

                topLevelLayers{end+1}=this.insertQuantizeOutput(component.outputExp);
            else
                for nLayerIdx=1:numel(component.nLayer)
                    layer=component.nLayer(nLayerIdx);
                    if(isa(layer,'nnet.cnn.layer.SigmoidLayer'))
                        topLevelLayers{end+1}=dnnfpga.deployablenetwork.swLayer(layer,@(input)(dnnfpga.processorbase.processorUtils.sigmoidLayerPredict(layer,input)));
                    elseif(isa(layer,'dnnfpga.layer.ExponentialLayer'))
                        topLevelLayers{end+1}=dnnfpga.deployablenetwork.swLayer(layer,@(input)(dnnfpga.processorbase.processorUtils.exponentialLayerPredict(layer,input)));
                    else
                        topLevelLayers{end+1}=dnnfpga.deployablenetwork.swLayer(layer,@(input)(dnnfpga.compiler.compilerUtils.SNLayerPredict(layer,input)));
                    end
                end
            end

        end

        function addSchedule(this,hIR,deployableNW,scheduleData,processor,hPC)

            hIR.createScheduler(scheduleData,hPC,processor);




            skdData=hIR.emitSchedulerTable();
            skdData=typecast(uint32(skdData),'single');
            deploayableNWData=deployableNW.getSingletonFPGALayer.getData;
            deploayableNWData.instructions.scheduler=skdData;
            deployableNW.getSingletonFPGALayer.setData(deploayableNWData);

        end

        function[topLevelSyncInstruction]=initialzeTopLevelSyncInstruction(~)
            topLevelSyncInstruction=struct();
            topLevelSyncInstruction.conv.head='';
            topLevelSyncInstruction.conv.body='';
            topLevelSyncInstruction.conv.tail='';
            topLevelSyncInstruction.ip0.head='';
            topLevelSyncInstruction.ip0.body='';
            topLevelSyncInstruction.ip0.tail='';
            topLevelSyncInstruction.op0.head='';
            topLevelSyncInstruction.op0.body='';
            topLevelSyncInstruction.op0.tail='';
        end

        function[topLevelSyncInstruction]=stitchSyncInstruction(~,topLevelSyncInstruction,newData,componentName)
            if isempty(newData.syncSeqLC)
                return;
            end

            if~isempty(topLevelSyncInstruction.conv.head)
                assert(strcmp(topLevelSyncInstruction.conv.head,newData.syncSeqLC.stringConv.head));
                assert(strcmp(topLevelSyncInstruction.conv.tail,newData.syncSeqLC.stringConv.tail));
                assert(strcmp(topLevelSyncInstruction.ip0.head,newData.syncSeqLC.stringIP0.head));
                assert(strcmp(topLevelSyncInstruction.ip0.tail,newData.syncSeqLC.stringIP0.tail));
                assert(strcmp(topLevelSyncInstruction.op0.head,newData.syncSeqLC.stringOP0.head));
                assert(strcmp(topLevelSyncInstruction.op0.tail,newData.syncSeqLC.stringOP0.tail));
            end

            topLevelSyncInstruction.conv.head=newData.syncSeqLC.stringConv.head;
            topLevelSyncInstruction.conv.tail=newData.syncSeqLC.stringConv.tail;
            topLevelSyncInstruction.ip0.head=newData.syncSeqLC.stringIP0.head;
            topLevelSyncInstruction.ip0.tail=newData.syncSeqLC.stringIP0.tail;
            topLevelSyncInstruction.op0.head=newData.syncSeqLC.stringOP0.head;
            topLevelSyncInstruction.op0.tail=newData.syncSeqLC.stringOP0.tail;


            delimit=sprintf('\n \\\\ Following for Leg: %s \n',componentName);

            topLevelSyncInstruction.conv.body=[topLevelSyncInstruction.conv.body,delimit,newData.syncSeqLC.stringConv.body];
            topLevelSyncInstruction.ip0.body=[topLevelSyncInstruction.ip0.body,delimit,newData.syncSeqLC.stringIP0.body];
            topLevelSyncInstruction.op0.body=[topLevelSyncInstruction.op0.body,delimit,newData.syncSeqLC.stringOP0.body];
        end

        function[deployableNWData]=emitSyncInstruction(this,topLevelSyncInstruction,cnnp,deployableNWData)
            topLevelSyncInstruction=this.mergeSyncInstruction(topLevelSyncInstruction);
            if isempty(topLevelSyncInstruction)
                deployableNWData.syncInstructions.conv=[];
                deployableNWData.syncInstructions.ip=[];
                deployableNWData.syncInstructions.op=[];
                return;
            end

            maxPCNum=2^(cnnp.getConvProcessor.getCC().syncInstFormat.newPCMax-cnnp.getConvProcessor.getCC().syncInstFormat.newPCMin);
            sa=dnnfpga.processorbase.syncAssembler(cnnp.getConvProcessor.getCC().syncInstFormat,maxPCNum);

            deployableNWData.syncInstructions.conv=sa.build(topLevelSyncInstruction.conv);
            deployableNWData.syncInstructions.ip=sa.build(topLevelSyncInstruction.ip0);
            deployableNWData.syncInstructions.op=sa.build(topLevelSyncInstruction.op0);
            if(strcmpi(dnnfpgafeature('Debug'),'on'))
                dnnfpga.processorbase.syncAssembler.str2file(topLevelSyncInstruction.conv,'scriptConv.s');
                dnnfpga.processorbase.syncAssembler.str2file(topLevelSyncInstruction.ip0,'scriptIP0.s');
                dnnfpga.processorbase.syncAssembler.str2file(topLevelSyncInstruction.op0,'scriptOP0.s');
            end
        end

        function[topLevelSyncInstruction]=mergeSyncInstruction(~,topLevelSyncInstruction)
            if isempty(topLevelSyncInstruction)
                return;
            end
            topLevelSyncInstruction.conv=[topLevelSyncInstruction.conv.head,topLevelSyncInstruction.conv.body,topLevelSyncInstruction.conv.tail];
            topLevelSyncInstruction.ip0=[topLevelSyncInstruction.ip0.head,topLevelSyncInstruction.ip0.body,topLevelSyncInstruction.ip0.tail];
            topLevelSyncInstruction.op0=[topLevelSyncInstruction.op0.head,topLevelSyncInstruction.op0.body,topLevelSyncInstruction.op0.tail];
        end

        function[deployableNWData,opData]=stitchDeployableNetworkData(~,deployableNWData,newData)




            if isfield(newData.seqOp,'conv')


                convWeights=newData.seqOp.conv.conv;
                convIPInstructions=newData.seqLC.conv.ip0;
                convInstructions=newData.seqLC.conv.conv;
                convOPInstructions=newData.seqLC.conv.op0;

                if~isfield(deployableNWData.weights,'conv')
                    deployableNWData.weights.conv=[];
                    deployableNWData.instructions.conv=struct('ip',[],'op',[],'conv',[]);
                    deployableNWData.registers.conv=struct('ip',[],'op',[],'conv',[]);
                end

                deployableNWData.weights.conv=[deployableNWData.weights.conv,convWeights];
                deployableNWData.instructions.conv.ip=[deployableNWData.instructions.conv.ip,convIPInstructions];
                deployableNWData.instructions.conv.conv=[deployableNWData.instructions.conv.conv,convInstructions];
                deployableNWData.instructions.conv.op=[deployableNWData.instructions.conv.op,convOPInstructions];

                opData=struct();
                opData.kind='CONV';

            end


            if isfield(newData.seqOp,'fc')

                fcWeights=newData.seqOp.fc;
                fcInstructions=newData.moduleSeqLC.fc;
                fcRegisters=newData.NC.fc;

                if~isfield(deployableNWData.weights,'fc')
                    deployableNWData.weights.fc=[];
                    deployableNWData.instructions.fc=[];
                    deployableNWData.registers.fc=[];
                end

                deployableNWData.weights.fc=[deployableNWData.weights.fc,fcWeights];
                deployableNWData.instructions.fc=[deployableNWData.instructions.fc,fcInstructions];


                deployableNWData.registers.fc=fcRegisters;

                opData=struct();
                opData.kind='FC';
                opData.layerNumMinusOne=fcRegisters.layerNumMinusOne;

            end


            if isfield(newData,'adder')

                adderInstructions=newData.adder.moduleSeqLC;

                if~isfield(deployableNWData.instructions,'adder')
                    deployableNWData.instructions.adder=[];
                end

                deployableNWData.instructions.adder=[deployableNWData.instructions.adder,adderInstructions];
            end

        end
    end


end




