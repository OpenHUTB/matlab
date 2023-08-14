classdef cnn4ProcessorBackend<dnnfpga.compiler.abstractDNNCompilerStage




    properties(Access=protected)
        verbose=1;


        hDDROffsetMap=[];
    end

    properties(Constant)


        AddrBlockSize=hex2dec('400000');

    end

    methods(Access=public,Hidden=true)
        function obj=cnn4ProcessorBackend(verbose)
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
            obj.verbose=verbose;


            obj.hDDROffsetMap=containers.Map('KeyType','char','ValueType','uint32');
        end

    end

    methods(Access=public)

        function deployableNW=doit(this,deployableLayerParams,processor,varargin)




            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'InputFrameNumberLimit',30,@isnumeric);


            addParameter(p,'ExternalMemorySize',[],@isnumeric);

            parse(p,varargin{:});
            inputFrameNumberLimit=p.Results.InputFrameNumberLimit;
            externalMemorySize=p.Results.ExternalMemorySize;



            this.preCalculateDDRBufferOffsets(deployableLayerParams,inputFrameNumberLimit);


            deployableLayerParams=this.allocateConvDDR(deployableLayerParams,processor);



            deployableNW=this.constructDeployableNetwork(deployableLayerParams,processor,varargin{:});



            allocatedMemorySize=this.postCalculateDDRBufferOffsets(deployableNW);

            table=this.getDDROffsetTable;
            this.displayDDROffsetTable(this.verbose);





            if allocatedMemorySize>externalMemorySize
                error(message('dnnfpga:dnnfpgacompiler:DLNetworkMemSizeTooLarge',dec2hex(allocatedMemorySize),dec2hex(externalMemorySize)));
            end



            deployableNW.setDDROffsetTable(table);




            deployableNW.setInputFrameNumberLimit(inputFrameNumberLimit);

        end
    end

    methods(Access=protected)

        function preCalculateDDRBufferOffsets(this,deployableLayerParams,inputFrameNumberLimit)













            startOffset=hex2dec('00000000');


            [hasConv,hasFC,convModuleIR,fcModuleIR]=dnnfpga.bitstreambase.checkDeployableIRParams(deployableLayerParams);
            assert(hasConv,'DDR offset calculation expect conv layer exist');
            convLayerIRs=convModuleIR.params;
            assert(length(convLayerIRs)>=1,'DDR offset calculation expect conv layer exist');
            if hasFC
                fcLayerIRs=fcModuleIR.params;
            end




            inputDataOffset=startOffset;


            firstConvLayerIR=convLayerIRs{1};
            dataTransNum=convModuleIR.processor.getCC.convp.ip0.dataTransNum;
            firstConvInputSizeLimit=this.calculateConvLayerInputSizeLimit(firstConvLayerIR,dataTransNum);


            totalInputBufferSize=this.getAlignedSize(firstConvInputSizeLimit*inputFrameNumberLimit*4);


            outputResultOffset=inputDataOffset+totalInputBufferSize;


            lastConvLayerIR=convLayerIRs{end};
            lastConvLayerOutputSizeLimit=this.calculateConvLayerOutputSizeLimit(convModuleIR,lastConvLayerIR,dataTransNum);


            if~hasFC

                lastLayerOutputSizeLimit=lastConvLayerOutputSizeLimit;
            else

                lastFCLayerIR=fcLayerIRs{end};
                lastLayerOutputSizeLimit=this.calculateFCLayerOutputSizeLimit(lastFCLayerIR);
            end
            totalOutputBufferSize=this.getAlignedSize(lastLayerOutputSizeLimit*inputFrameNumberLimit*4);


            this.hDDROffsetMap('InputDataOffset')=inputDataOffset;
            this.hDDROffsetMap('OutputResultOffset')=outputResultOffset;




            systemBridgeBufferOffset=outputResultOffset+totalOutputBufferSize;


            totalBridgeBufferSize=this.getAlignedSize(lastConvLayerOutputSizeLimit*4);


            convInputBufferOffset=systemBridgeBufferOffset+totalBridgeBufferSize;







            maxConvIntermActivationSizeLimit=firstConvInputSizeLimit;
            for ii=1:length(convLayerIRs)
                convLayerIR=convLayerIRs{ii};
                convLayerOutputSizeLimit=this.calculateConvLayerOutputSizeLimit(convModuleIR,convLayerIR,dataTransNum);
                if convLayerOutputSizeLimit>maxConvIntermActivationSizeLimit
                    maxConvIntermActivationSizeLimit=convLayerOutputSizeLimit;
                end
            end


            totalConvIntermBufferSize=this.getAlignedSize(maxConvIntermActivationSizeLimit*4);


            convOutputBufferOffset=convInputBufferOffset+totalConvIntermBufferSize;


            debuggerScratchOffset=convOutputBufferOffset+totalConvIntermBufferSize;


            this.hDDROffsetMap('SystemBufferOffset')=systemBridgeBufferOffset;
            this.hDDROffsetMap('convInputBufferOffset')=convInputBufferOffset;
            this.hDDROffsetMap('convOutputBufferOffset')=convOutputBufferOffset;
            this.hDDROffsetMap('debuggerScratchOffset')=debuggerScratchOffset;

        end

        function deployableLayerParams=allocateConvDDR(this,deployableLayerParams,processor)


            for i=1:length(deployableLayerParams)
                layerType=deployableLayerParams{i}.type;
                switch layerType
                case 'FPGA_Conv'
                    DDRAddrA=this.hDDROffsetMap('convInputBufferOffset');
                    DDRAddrB=this.hDDROffsetMap('convOutputBufferOffset');
                    DDRAddrInput=this.hDDROffsetMap('InputDataOffset');
                    DDRAddrBridge=this.hDDROffsetMap('SystemBufferOffset');
                    DDRAddrResult=this.hDDROffsetMap('OutputResultOffset');


                    if(isfield(processor.getBCC().convp.conv,'ConvDDRInputAddr'))
                        DDRAddrA=processor.getBCC().convp.conv.ConvDDRInputAddr;
                        DDRAddrInput=cnnp.getBCC().convp.conv.ConvDDRInputAddr;
                    end
                    if(isfield(processor.getBCC().convp.conv,'ConvDDROutputAddr'))
                        DDRAddrB=processor.getBCC().convp.conv.ConvDDROutputAddr;
                        DDRAddrBridge=cnnp.getBCC().convp.conv.ConvDDROutputAddr;
                    end

                    for jj=1:length(deployableLayerParams{i}.params)




                        if(jj==1)
                            deployableLayerParams{i}.params{jj}.DDRAddrA=DDRAddrInput;
                            deployableLayerParams{i}.params{jj}.DDRAddrB=DDRAddrB;
                        elseif(jj==length(deployableLayerParams{i}.params))
                            deployableLayerParams{i}.params{jj}.DDRAddrA=DDRAddrA;
                            if DDRAddrBridge~=DDRAddrA
                                deployableLayerParams{i}.params{jj}.DDRAddrB=DDRAddrBridge;
                            else
                                deployableLayerParams{i}.params{jj}.DDRAddrB=DDRAddrB;
                            end
                        else
                            deployableLayerParams{i}.params{jj}.DDRAddrA=DDRAddrA;
                            deployableLayerParams{i}.params{jj}.DDRAddrB=DDRAddrB;
                        end



                        deployableLayerParams{i}.params{jj}.DDRAddrResult=DDRAddrResult;
                        tmpDDRAddr=DDRAddrA;
                        DDRAddrA=DDRAddrB;
                        DDRAddrB=tmpDDRAddr;
                    end
                otherwise

                end
            end
        end

        function allocatedMemorySize=postCalculateDDRBufferOffsets(this,deployableNW)



            fpgaLayer=deployableNW.getSingletonFPGALayer;
            [~,hasFC]=dnnfpga.bitstreambase.checkDeployableIR(fpgaLayer);



            totalDebuggerScrachBufferSize=this.getAlignedSize(hex2dec('01000000'));


            instructionDataOffset=this.hDDROffsetMap('debuggerScratchOffset')+totalDebuggerScrachBufferSize;


            convLCData=fpgaLayer.getData.seqLC.conv;
            convLCDataAll=[convLCData.ip0,convLCData.conv,convLCData.op0];
            convWeightDataSize=length(fpgaLayer.getData.seqOp.conv.conv);


            if hasFC
                fcModuleLCData=fpgaLayer.getData.moduleSeqLC.fc;
            else
                fcModuleLCData=[];
            end


            LCDataAll=[convLCDataAll,fcModuleLCData];
            LCDataSize=length(LCDataAll);


            totalLCBufferSize=this.getAlignedSize(LCDataSize*4);


            convWeightDataOffset=instructionDataOffset+totalLCBufferSize;


            totalConvWeightBufferSize=this.getAlignedSize(convWeightDataSize*4);



            if hasFC

                fcWeightDataOffset=convWeightDataOffset+totalConvWeightBufferSize;
                this.hDDROffsetMap('FCWeightDataOffset')=fcWeightDataOffset;


                fcWeightDataSize=length(fpgaLayer.getData.seqOp.fc);
                totalFCWeightBufferSize=this.getAlignedSize(fcWeightDataSize*4);
                endOffset=fcWeightDataOffset+totalFCWeightBufferSize;
            else


                endOffset=convWeightDataOffset+totalConvWeightBufferSize;
            end


            this.hDDROffsetMap('InstructionDataOffset')=instructionDataOffset;
            this.hDDROffsetMap('ConvWeightDataOffset')=convWeightDataOffset;
            this.hDDROffsetMap('EndOffset')=endOffset;


            allocatedMemorySize=endOffset;

        end

        function displayDDROffsetTable(this,verbose)

            tableOut=this.getDDROffsetTable();
            if 1<=this.verbose
                fprintf("\n");
            end
            dnnfpga.disp(char("Allocating external memory buffers:"+newline),1,this.verbose);
            strOutput=evalc('disp(tableOut)');
            if 1<=this.verbose
                fprintf("%s",strOutput);
            end
        end

        function tableOut=getDDROffsetTable(this)
            tableOut=dnnfpga.format.getDDROffsetTableForPrint(this.hDDROffsetMap,this.verbose);
        end

        function alignedOffset=getAlignedSize(this,offsetIn)

            alignedOffset=ceil(offsetIn/this.AddrBlockSize)*this.AddrBlockSize;
        end



        function convLayerInputSizeLimit=calculateConvLayerInputSizeLimit(~,convLayerIR,dataTransNum)

            convLayerInputSize=[convLayerIR.origImgSize(1:2);convLayerIR.inputFeatureNum];



            if(dataTransNum>1)
                convLayerInputSize(3)=ceil(convLayerInputSize(3)/dataTransNum)*dataTransNum;
            end
            convLayerInputSizeLimit=prod(convLayerInputSize);
        end

        function convLayerOutputSizeLimit=calculateConvLayerOutputSizeLimit(~,convModuleIR,convLayerIR,dataTransNum)

            conv2Processor=convModuleIR.processor.getConvProcessor.getConvProcessor;
            convResultSize=conv2Processor.resolveOutputSizeLayerWithoutPadding(convLayerIR);



            if(dataTransNum>1)
                convResultSize(3)=ceil(convResultSize(3)/dataTransNum)*dataTransNum;
            end
            convLayerOutputSizeLimit=prod(convResultSize);

        end

        function fcLayerInputSizeLimit=calculateFCLayerInputSizeLimit(~,fcLayerIR)

            fcLayerInputSizeLimit=fcLayerIR.matrixSize(1);
        end

        function fcLayerOutputSizeLimit=calculateFCLayerOutputSizeLimit(~,fcLayerIR)

            fcLayerOutputSizeLimit=fcLayerIR.matrixSize(2);
        end

        function deployableNW=constructDeployableNetwork(this,deployableLayerParams,cnnp,varargin)

            layers={};
            convData=[];
            fcData=[];
            state=0;

            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'ActivationLayer','',@ischar);
            addParameter(p,'ActivationTile',[]);

            parse(p,varargin{:});

            activationLayer=p.Results.ActivationLayer;
            tileActivation=p.Results.ActivationTile;
            notRunTiledLayerPos=[];
            for i=1:length(deployableLayerParams)
                dlp=deployableLayerParams{i};
                layerType=dlp.type;
                switch state
                case 0
                    switch layerType
                    case 'SW_SeriesNetwork2FPGA'
                        assert(i<length(deployableLayerParams));
                        dlpNext=deployableLayerParams{i+1};
                        layers{end+1}=this.createSN2FPGALayer(dlp,dlpNext,cnnp);
                        state=1;
                    case 'FPGA_Conv'
                        [convData,notRunTiledLayerPos]=cnnp.getConvProcessor().backend(dlp.params,this.verbose,tileActivation);
                        convData.params=dlp;
                        state=2;

                    case 'FPGA_FC'
                        fcData=cnnp.getFCProcessor().backend(dlp.params);
                        fcData.params=dlp;
                        state=6;

                    case 'SW_SeriesNetwork'



                        switch dlp.params{1}.internal_type
                        case 'SW_Sigmoid'
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.processorbase.processorUtils.sigmoidLayerPredict(dlp.params{1}.snLayer,input)));
                        case 'SW_Exponential'
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.processorbase.processorUtils.exponentialLayerPredict(dlp.params{1}.snLayer,input)));
                        otherwise
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.compiler.compilerUtils.SNLayerPredict(dlp.params{1}.snLayer,input)));
                        end

                        if(strcmpi(dlp.params{1}.internal_type,'SW_SeriesNetwork_Input')&&(dlp.params{1}.WL==8))
                            layers{end+1}=this.QuantizeInput(dlp,cnnp);
                        end

                        state=0;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                case 1
                    switch layerType
                    case 'FPGA_Conv'
                        conv4p=cnnp.getConvProcessor;



                        [~,hasFC,~,~,~]=dnnfpga.bitstreambase.checkDeployableIRParams(deployableLayerParams);
                        [convData,notRunTiledLayerPos]=conv4p.backend(dlp.params,this.verbose,tileActivation,hasFC);
                        convData.params=dlp;
                        state=1;

                    case 'FPGA_FC'
                        fc4p=cnnp.getFCProcessor;
                        convDataTransNum=cnnp.getConvProcessor.getCC.op0.dataTransNum;
                        convLastLayerDDROffset=convData.params.params{end}.DDRAddrB;
                        fcOutputResultOffset=this.hDDROffsetMap('OutputResultOffset');
                        fcData=fc4p.backend(dlp.params,convDataTransNum,convLastLayerDDROffset,fcOutputResultOffset);
                        fcData.params=dlp;
                        state=2;

                    case 'SW_FPGA2SeriesNetwork'
                        layers{end+1}=dnnfpga.compiler.cnn4ProcessorBackend.createFPGALayer(cnnp,convData,fcData,deployableLayerParams,this.hDDROffsetMap,activationLayer,notRunTiledLayerPos);
                        convData=[];
                        fcData=[];
                        if((dlp.params{1}.WL==8))
                            layers{end+1}=this.QuantizeOutput(dlp,cnnp);
                        end


                        state=3;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                case 2
                    switch layerType
                    case 'FPGA_Conv'
                        conv4p=cnnp.getConvProcessor;

                        [convData,notRunTiledLayerPos]=conv4p.backend(dlp.params,this.verbose,tileActivation);
                        convData.params=dlp;
                        state=1;

                    case 'FPGA_FC'

                        fc4p=cnnp.getFCProcessor;
                        fcData=fc4p.backend(dlp.params);
                        fcData.params=dlp;
                        state=2;

                    case 'SW_FPGA2SeriesNetwork'
                        layers{end+1}=dnnfpga.compiler.cnn4ProcessorBackend.createFPGALayer(cnnp,convData,fcData,deployableLayerParams,this.hDDROffsetMap,activationLayer,notRunTiledLayerPos);
                        convData=[];
                        fcData=[];
                        notRunTiledLayerPos=[];
                        if((dlp.params{1}.WL==8))
                            layers{end+1}=this.QuantizeOutput(dlp,cnnp);
                        end
                        layers{end+1}=dnnfpga.deployablenetwork.swLayer('InputToFPGA',@(input)(dnnfpga.compiler.cnn4ProcessorBackend.reshapeMulti({input,false})));
                        state=3;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end

                case 3
                    switch layerType
                    case 'SW_SeriesNetwork'
                        switch strcmpi(dlp.params{1}.internal_type)
                        case 'SW_Sigmoid'
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.processorbase.processorUtils.sigmoidLayerPredict(dlp.params{1}.snLayer,input)));
                        case 'SW_Exponential'
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.processorbase.processorUtils.exponentialLayerPredict(dlp.params{1}.snLayer,input)));
                        otherwise
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.compiler.compilerUtils.SNLayerPredict(dlp.params{1}.snLayer,input)));
                        end
                        state=3;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                otherwise
                    assert(false,'Unexpected state: %d',state);
                end

            end



            if(~isempty(convData)||~isempty(fcData))
                layers{end+1}=dnnfpga.compiler.cnn4ProcessorBackend.createFPGALayer(cnnp,convData,fcData,deployableLayerParams,this.hDDROffsetMap,activationLayer,notRunTiledLayerPos);
            end
            deployableNW=dnnfpga.deployablenetwork.deployableNetwork(layers);
        end
    end

    methods(Access=protected,Static=true)

        function layer=createSN2FPGALayer(~,dlpNext,processor)




            if~isa(processor,'dnnfpga.processorbase.cnn5Processor')


                assert(isequal(dlpNext.type,'FPGA_Conv'),'SW_SeriesNetwork2FPGA followed by %s is not supported.',dlpNext.type);
                assert(isequal(dlpNext.params{1}.type,'FPGA_Conv2D'),'SW_SeriesNetwork2FPGA followed by %s is not supported.',dlpNext.params{1}.type);
            end


            conv2Processor=processor.getConvProcessor().getConvProcessor();
            convThreadNum=conv2Processor.getCC.threadNumLimit;
            dataTransNum=processor.getConvProcessor().getCC.ip0.dataTransNum;






            foo=@(input)(dnnfpga.processorbase.conv4Processor.getSeqImage(input,convThreadNum,dataTransNum));
            layer=dnnfpga.deployablenetwork.swLayer('InputToFPGA',foo);
        end

        function layer=QuantizeInput(dlp,processor)
            foo=@(input)(dnnfpga.processorbase.processorUtils.singleToInt8Conversion(dlp.params{1},input,dlp.params{1}.singleToInt8Exp));
            layer=dnnfpga.deployablenetwork.swLayer('QuantizeInput',foo);
        end

        function layer=QuantizeOutput(dlp,processor)
            foo=@(input)(dnnfpga.processorbase.processorUtils.int8ToSingleConversion(dlp.params{1},input,dlp.params{1}.int8ToSingleExp));
            layer=dnnfpga.deployablenetwork.swLayer('QuantizeOutput',foo);
        end

        function output=reshapeMulti(cellInput)
            input=cellInput{1};





            if ndims(input)<2
                assert(false,'unsupported input tensor shape\n');
            else
                output=input;
            end
        end
    end

    methods(Access=private,Static=true)

        function fl=createFPGALayer(cnnp,convData,fcData,deployableLayerParams,hDDROffsetMap,activationLayer,notRunTiledLayerPos)



            if nargin<5
                hDDROffsetMap=containers.Map('KeyType','char','ValueType','uint32');
            end
            if nargin<7
                notRunTiledLayerPos=[];
            end
            seqOp=[];
            seqLC=[];
            NC=[];
            moduleSeqLC=[];
            fpgaLayerParams=[];
            if(~isempty(convData))
                seqOp.conv=convData.seqOp;
                seqLC.conv=convData.seqLC;
                NC.conv=convData.NC;
                syncSeqLC=convData.syncSeqLC;
                fpgaLayerParams{end+1}=convData.params;
            end
            if(~isempty(fcData))
                seqOp.fc=fcData.seqOp;
                seqLC.fc=fcData.seqLC;
                moduleSeqLC.fc=fcData.moduleSeqLC;
                NC.fc=fcData.NC;
                fpgaLayerParams{end+1}=fcData.params;
            end

            initData.seqOp=seqOp;
            initData.seqLC=seqLC;
            initData.NC=NC;
            initData.syncSeqLC=syncSeqLC;
            initData.moduleSeqLC=moduleSeqLC;
            forwardArgs.params=fpgaLayerParams;























































            fl=dnnfpga.deployablenetwork.fpgaLayer('FPGA_CNN',cnnp,initData,forwardArgs,deployableLayerParams,hDDROffsetMap,activationLayer,notRunTiledLayerPos);

        end

        function ed=createEmptyData()
            ed.seqOp=[];
            ed.seqLC=[];
            ed.NC=[];
        end
    end
end



