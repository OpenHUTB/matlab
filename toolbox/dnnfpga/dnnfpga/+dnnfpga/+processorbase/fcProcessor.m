classdef fcProcessor<dnnfpga.processorbase.abstractProcessor



    methods(Access=public,Hidden=true)
        function obj=fcProcessor(bcc)
            obj@dnnfpga.processorbase.abstractProcessor(bcc);
        end
    end


    methods(Access=public)
        function cycles=estimateThroughput(this,params,~)
            cycles=[];
        end


        function nc=resolveNC(~,params)
            nc.layerNumMinusOne=length(params)-1;
            weightSize=0;

            for i=1:length(params)
                if(strcmp(params{i}.type,'FPGA_FC'))
                    weightSize=weightSize+prod(params{i}.matrixSize+[1,0]);
                end
            end
            nc.WeightSize=weightSize;
            nc.result_length=params{end}.matrixSize(2);
            nc.result_count=3;
        end

        function s=resolveOutputSizeLayer(~,param)
            s=param.matrixSize(2)-param.outputNumToPadForRAWHazard;
        end

        function s=resolveInputSize(this,params)
            s=this.resolveInputSizeLayer(params{1});
        end


        function s=resolveOutputSize(this,params)
            s=this.resolveOutputSizeLayer(params{end});
        end

        function output=cosim(this,param,input)
            switch param.type
            case{'SW_Cosim_FPGA_FC','SW_Emulation_FPGA_FC'}
                output=this.cosimFCLayer(param.params{1},input,this.getCC());
            case 'SW_Cosim_FPGA_GAP2D'
                output=this.cosimGAP2DLayer(param.params{1},input,this.getCC());
            otherwise
                assert(false,'Unexpected layer type %s',param.type);
            end
        end

        function processor=getFCProcessor(this)
            processor=this;
        end

        function logs=sanityCheckNetwork(this,params)
            logs={};

            layerNum=length(params);
            layerNumLimit=this.getCC().layerNumWLimit;
            if(layerNum>layerNumLimit)
                logs{end+1}=sprintf('The number of FC layers(%d) is greater than the limit (%d).',layerNum,layerNumLimit);
            end

        end

        function s=resolveInputSizeLayer(this,param)

            matrixSize=param.matrixSize;

            s=matrixSize(1);
        end

        function logs=sanityCheckLayer(this,param)
            logs={};

            switch param.type
            case{'FPGA_Output','FPGA_GAP2D','FPGA_Softmax','FPGA_Sigmoid','FPGA_Exponential'}
                logs=logs;
            case 'FPGA_FC'
                if param.memDirection
                    if param.matrixSize(1)>this.getCC.matrixSizeLimit(1)
                        msg=message('dnnfpga:dnnfpgacompiler:InActivationExceedsMemLimit',...
                        dnnfpga.compiler.compilerUtils.getCorrespondingSNLayer(param),...
                        param.matrixSize(1),...
                        this.getCC.matrixSizeLimit(1));
                        logs{end+1}=msg.getString;

                    end
                    if param.matrixSize(2)>this.getCC.matrixSizeLimit(2)
                        msg=message('dnnfpga:dnnfpgacompiler:OutActivationExceedsMemLimit',...
                        dnnfpga.compiler.compilerUtils.getCorrespondingSNLayer(param),...
                        param.matrixSize(2),...
                        this.getCC.matrixSizeLimit(2));
                        logs{end+1}=msg.getString;
                    end
                else
                    if param.matrixSize(2)>this.getCC.matrixSizeLimit(1)
                        msg=message('dnnfpga:dnnfpgacompiler:InActivationExceedsMemLimit',...
                        dnnfpga.compiler.compilerUtils.getCorrespondingSNLayer(param),...
                        param.matrixSize(2),...
                        this.getCC.matrixSizeLimit(1));
                        logs{end+1}=msg.getString;
                    end
                    if param.matrixSize(1)>this.getCC.matrixSizeLimit(2)
                        msg=message('dnnfpga:dnnfpgacompiler:OutActivationExceedsMemLimit',...
                        dnnfpga.compiler.compilerUtils.getCorrespondingSNLayer(param),...
                        param.matrixSize(1),...
                        this.getCC.matrixSizeLimit(2));
                        logs{end+1}=msg.getString;
                    end
                end
            otherwise
                assert(false,'Unknown layer type "%s"',param.type);
            end
        end

        function data=getSeqLCAndOpPerLayer(this,param)
            if(strcmp(param.type,'FPGA_Output')||strcmp(param.type,'FPGA_GAP2D')||...
                strcmp(param.type,'FPGA_Softmax')||strcmp(param.type,'FPGA_Sigmoid')||strcmp(param.type,'FPGA_Exponential'))
                data.seqOp=[];
                param.MinWeight=single(0);
                param.MaxWeight=single(0);
                param.WeightDiff=single(0);
                layerConfig=dnnfpga.processorbase.processorUtils.resolveLCPerLayerFC(param,this.getCC());
                data.seqLC=dnnfpga.processorbase.fcProcessor.seqLayerConfig(layerConfig,'single');
                return;
            end
            chipConfig=this.getCC();
            [importedOp,importedBias]=dnnfpga.processorbase.fcProcessor.importOperator(param.weights,param.bias);
            ParamCalWeightCat=dnnfpga.processorbase.fcProcessor.seqOperator(importedOp,importedBias,chipConfig);
            param.MinWeight=((min(min(ParamCalWeightCat))));
            param.MaxWeight=((max(max(ParamCalWeightCat))));
            param.WeightDiff=param.MaxWeight-param.MinWeight;
            [paddedOp,paddedBias]=dnnfpga.processorbase.fcProcessor.padForRAWHazard(importedOp,importedBias,param.inputNumToPadForRAWHazard,param.outputNumToPadForRAWHazard);


            if(chipConfig.IsFixedPt)
                data.seqOp=dnnfpga.processorbase.fcProcessor.seqOperator(paddedOp,paddedBias);
                if(chipConfig.opBitWidthLimit==16)
                    data.seqOp=typecast(int16(data.seqOp),'uint32');
                elseif(chipConfig.opBitWidthLimit==8)
                    data.seqOp=typecast(int8(data.seqOp),'uint32');
                end
            else
                data.seqOp=dnnfpga.processorbase.fcProcessor.seqOperator(paddedOp,paddedBias);
            end
            layerConfig=dnnfpga.processorbase.processorUtils.resolveLCPerLayerFC(param,this.getCC());
            data.seqLC=dnnfpga.processorbase.fcProcessor.seqLayerConfig(layerConfig,'single');
        end
    end

    methods(Access=protected)
        function cc=resolveCC(this)
            bcc=this.getBCC();
            cc.kernelDataType=bcc.kernelDataType;
            cc.RoundingMode=bcc.RoundingMode;
            cc.MemoryMinDepth=bcc.MemoryMinDepth;
            cc.resultNumWLimit=bcc.resultNumWLimit;
            cc.layerModeNumWLimit=bcc.layerModeNumWLimit;
            cc.matrixSizeLimit=bcc.matrixSizeLimit;
            cc.resultMemDepthLimit=ceil((bcc.resultMemDepthLimit)/bcc.threadNumLimit);
            cc.inputMemDepthLimit=ceil((bcc.inputMemDepthLimit)/bcc.threadNumLimit);
            cc.layerNumWLimit=bcc.layerNumWLimit;
            cc.layerConfigNumWLimit=bcc.layerConfigNumWLimit;
            cc.debugIDNumWLimit=bcc.debugIDNumWLimit;
            cc.debugBankNumWLimit=bcc.debugBankNumWLimit;


            if(strcmp(cc.kernelDataType,'single'))
                cc.MadLatency=bcc.MADLatency;
                cc.ProdLatency=bcc.ProdLatency;
                cc.SumLatency=bcc.SumLatency;
                cc.CmpLatency=bcc.CmpLatency;
            else

                cc.MadLatency=1;
                cc.ProdLatency=1;
                cc.SumLatency=1;
                cc.CmpLatency=1;
            end


            cc.Fixdt_0_16_0_To_SingleLatency=bcc.Fixdt_0_16_0_To_SingleLatency;
            if((strcmpi(bcc.kernelDataType,'uint16'))||(strcmpi(bcc.kernelDataType,'int8')))
                cc.IsFixedPt=1;
            else
                cc.IsFixedPt=0;
            end
            cc.OutDataType=bcc.fcOpDataType;


            if(strcmpi(class(this),'dnnfpga.processorbase.fc4Processor')||...
                strcmpi(class(this),'dnnfpga.processorbase.fc5Processor'))
                cc.RemapLatency=1;
            else
                cc.RemapLatency=0;
            end




            if(strcmpi(bcc.kernelDataType,'int8'))
                cc.PipelineLatency=1;
                cc.Int16_To_SingleLatency=cc.Fixdt_0_16_0_To_SingleLatency;



                cc.InputOutputLatency=4*cc.PipelineLatency+2*cc.Int16_To_SingleLatency;
            else
                cc.PipelineLatency=0;
                cc.Int16_To_SingleLatency=0;
                cc.InputOutputLatency=0;
            end
            cc.RelationalOpLatency=3;


            cc.SingleSumLatency=bcc.SumLatency;
            cc.DivideLatency=32;
            cc.SingleProdLatency=6;
            cc.ExpLatency=26;
            cc.MemReadLatency=bcc.MemReadLatency;
            cc.MemWriteLatency=bcc.MemReadLatency;
            cc.DataMemReadLatency=bcc.DataMemReadLatency;
            cc.DataMemWriteLatency=bcc.DataMemReadLatency;
            cc.DebugMemReadLatency=bcc.DebugMemReadLatency;
            cc.DebugMemRegularReadLatency=bcc.DebugMemRegularReadLatency;
            cc.iterCounterSizeLimit=[bcc.matrixSizeLimit;bcc.threadNumLimit];
            cc.iterCounterWLimit=ceil(log2(max(cc.iterCounterSizeLimit)));
            cc.debugIDAddrW=ceil(log2(bcc.debugIDNumWLimit));
            cc.debugBankAddrW=ceil(log2(bcc.debugBankNumWLimit));
            cc.debugSelectionAddrW=cc.debugIDAddrW+cc.debugBankAddrW;
            cc.debugCounterWLimit=bcc.debugCounterWLimit;
            cc.debugDMADepthLimit=bcc.debugDMADepthLimit;
            cc.debugDMAWidthLimit=bcc.debugDMAWidthLimit;
            cc.dataMemAddrW=ceil(log2(max([bcc.resultMemDepthLimit;bcc.inputMemDepthLimit])));
            cc.lcMemAddrW=ceil(log2(bcc.layerNumWLimit*bcc.layerConfigNumWLimit));
            cc.debugMemAddrW=max(ceil(log2(max(prod(bcc.resultMemDepthLimit),prod(bcc.inputMemDepthLimit)))),cc.lcMemAddrW);






            cc.RAWHazardLatencyThreshold=cc.DataMemReadLatency+cc.DataMemWriteLatency+cc.SumLatency+cc.ProdLatency+cc.CmpLatency+10*cc.RemapLatency;
            cc.ControlLogicInputFeatureAddrIdx=bcc.ControlLogicInputFeatureAddrIdx;
            cc.ControlLogicOutputFeatureAddrIdx=bcc.ControlLogicOutputFeatureAddrIdx;

            cc.coefFifoSizeLimit=bcc.coefFifoSizeLimit;
            cc.coefFifoAddrWLimit=ceil(log2(bcc.coefFifoSizeLimit));

            if(strcmpi(bcc.kernelDataType,'uint16'))
                cc.opBitWidthLimit=16;
            elseif(strcmpi(bcc.kernelDataType,'int8'))
                cc.opBitWidthLimit=8;
            else
                cc.opBitWidthLimit=32;
            end

            cc.fixedBitSlice=32/cc.opBitWidthLimit;
            cc.opDDRRatio=(bcc.opDDRBitWidthLimit)/(cc.opBitWidthLimit*cc.fixedBitSlice);
            cc.opDUTBitWidthLimit=bcc.opDUTBitWidthLimit;
            cc.opDDRBitWidthLimit=bcc.opDDRBitWidthLimit;
            cc.opFCBitSlice=cc.opDUTBitWidthLimit/cc.opBitWidthLimit;
            cc.threadNumLimit=bcc.threadNumLimit;

            cc.NewMin=int32(-(2^(cc.opBitWidthLimit-1)));
            cc.NewMaxMinDiff=(((2^(cc.opBitWidthLimit-1))-1)-(-(2^(cc.opBitWidthLimit-1))));
            cc.lcParam=bcc.lcParam;
            cc.DebugParams=bcc.DebugParams;
            cc.supportedDebugMem=bcc.supportedDebugMem;
            cc.offset=bcc.offset;
            cc.halfProgLCFIFODepth=bcc.halfProgLCFIFODepth;

        end

        function lc=resolveLCPerLayer(this,param)
            lc=dnnfpga.processorbase.processorUtils.resolveLCPerLayerFC(param,this.getCC());
        end

        function output=cosimFCLayer(this,param,input,chipConfig)

            quantDataTypes={'int4','int8'};
            if(any(strcmpi(chipConfig.kernelDataType,quantDataTypes)))
                input=reshape(input,[numel(input),1]);
            end
            [ParamCalseqOp,ParamCalseqOpBias]=dnnfpga.processorbase.fcProcessor.importOperator(param.weights,param.bias);
            ParamCalWeightCat=dnnfpga.processorbase.fcProcessor.seqOperator(ParamCalseqOp,ParamCalseqOpBias,chipConfig);
            param.MinWeight=((min(min(ParamCalWeightCat))));
            param.MaxWeight=((max(max(ParamCalWeightCat))));
            param.WeightDiff=param.MaxWeight-param.MinWeight;
            [paddedOp,seqOp]=dnnfpga.processorbase.fcProcessor.preprocessOperator(chipConfig,param);%#ok<ASGLU>
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqOpFC.mat'],'seqOp');
            end
            [paddedImg,seqImg]=dnnfpga.processorbase.fcProcessor.preprocessOInput(input,param);%#ok<ASGLU>
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqImgFC.mat'],'seqImg');
            end

            xResult=dnnfpga.processorbase.fcProcessor.calBaseline(param,paddedImg,paddedOp,param.reLUMode,param.reLUValue,param.reLUScaleExp);
            seqResult=reshape(xResult,[1,numel(xResult)]);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResultFC.mat'],'seqResult');
            end
            output=dnnfpga.convbase.exportImage(xResult);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_outputFC.mat'],'output');
            end
        end

        function output=cosimGAP2DLayer(this,param,input,chipConfig)
            param.MinWeight=0;
            param.MaxWeight=0;
            param.WeightDiff=0;
            xResult=dnnfpga.processorbase.fcProcessor.calBaselineGAP2D(input,chipConfig.threadNumLimit,param.gapMultiplier);
            output=dnnfpga.convbase.exportImage(xResult);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_outputGAP2D.mat'],'output');
            end
        end

    end

    methods(Access=public,Static=true)
        function[importedOp,importedBias]=importOperator(weights,bias)
            s=size(weights);
            importedOp=reshape(weights,[s(end-1),s(end)]);
            importedBias=reshape(bias,[1,length(bias)]);
        end

        function seqLC=seqLayerConfig(lcs,storedType)
            fieldNames={
            'memDirection',...
'reLUMode'...
            ,'iterCounterSize',...
            'iterCounterSizeMinusOne',...
            'RemapWeightDiffFraction',...
            'RemapMinweightMultiplyConstant',...
            'layerMode',...
            'memSelect',...
            'int32ToInt8Exp',...
            'reLUValue',...
            'fcBias',...
'reLUScaleExp'...
            };

            seqLC=dnnfpga.assembler.seqLayerConfigPrivate(lcs,storedType,fieldNames);
        end

        function lc=typeLayerConfig(cc,layerConfig)
            lc.memSelect=logical(layerConfig.memSelect);
            lc.layerMode=fi(layerConfig.layerMode,0,cc.layerModeNumWLimit,0);
            lc.memDirection=logical(layerConfig.memDirection);
            lc.iterCounterSize=fi(layerConfig.iterCounterSize,0,cc.iterCounterWLimit,0);
            lc.iterCounterSizeMinusOne=fi(layerConfig.iterCounterSizeMinusOne,0,cc.iterCounterWLimit,0);
            lc.reLUMode=fi(layerConfig.reLUMode,0,3,0);
            lc.RemapWeightDiffFraction=fi(typecast(layerConfig.WeightDiff/cc.NewMaxMinDiff,'uint32'),0,32,0);
            lc.RemapMinweightMultiplyConstant=fi(typecast(layerConfig.MinWeight-single(cc.NewMin)*(layerConfig.WeightDiff/cc.NewMaxMinDiff),'uint32'),0,32,0);

            lc.int32ToInt8Exp=fi(layerConfig.int32ToInt8Exp,1,8,0);


            lc.fcBias=fi(typecast(layerConfig.fcBias,'uint32'),0,32,0);
            if(strcmp(cc.kernelDataType,'single'))
                lc.reLUValue=fi(typecast(single(layerConfig.reLUValue),'uint32'),0,32,0);
            else
                lc.reLUValue=fi(typecast(int32(layerConfig.reLUValue),'uint32'),0,32,0);
            end
            lc.reLUScaleExp=fi(layerConfig.reLUScaleExp,1,8,0);
        end

        function seqOp=seqOperator(importedOp,importedBias,chipConfig)







            if(isfi(importedOp))
                seqOp=zeros(1,length(importedOp)+length(importedBias),'like',importedOp);
            else
                seqOp=zeros(1,length(importedOp)+length(importedBias),'single');
            end
            inputSize=size(importedOp,1);
            outputSize=size(importedOp,2);
            seqOp(1:inputSize*outputSize)=reshape(importedOp',1,[]);
            seqOp(inputSize*outputSize+1:(inputSize+1)*outputSize)=importedBias;
        end

        function[paddedOp,paddedBias]=padForRAWHazard(importedOp,importedBias,inputToPad,outputToPad)
            inputSize=size(importedOp);
            paddedOp=zeros(size(importedOp)+[inputToPad,outputToPad]);
            paddedOp(1:inputSize(1),1:inputSize(2))=importedOp;
            paddedBias=zeros(1,inputSize(2)+outputToPad);
            paddedBias(1:inputSize(2))=importedBias;
        end
    end

    methods(Access=protected,Static=true)
        function[paddedOp,seqOp]=preprocessOperator(chipConfig,param)
            [importedOp,importedBias]=dnnfpga.processorbase.fcProcessor.importOperator(param.weights,param.bias);
            if(isfi(importedOp))

                seqOp=[];
            else
                if(chipConfig.IsFixedPt)
                    seqOp=dnnfpga.processorbase.fcProcessor.seqOperator(importedOp,importedBias);
                    if(chipConfig.opBitWidthLimit==16)
                        seqOp=typecast(int16(seqOp),'uint32');
                    else
                        seqOp=typecast(int8(seqOp),'uint8');
                    end

                    if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                        save([param.phase,'_seqOpFC.mat'],'seqOp');
                    end
                else
                    seqOp=dnnfpga.processorbase.fcProcessor.seqOperator(importedOp,importedBias);
                    if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                        save([param.phase,'_seqOpFC.mat'],'seqOp');
                    end
                end
            end
            paddedOp=dnnfpga.processorbase.fcProcessor.setupCosimOp(importedOp,importedBias);

        end

        function paddedOp=setupCosimOp(weights,bias)
            paddedOp=[weights;bias];
        end
        function[paddedImg,seqImg]=preprocessOInput(input,param)



            importedImg=dnnfpga.processorbase.fcProcessor.importImage(input);
            paddedImg=dnnfpga.processorbase.fcProcessor.setupCosimImage(importedImg,param);
            seqImg=dnnfpga.processorbase.fcProcessor.seqImage(importedImg);
        end

        function importedInput=importImage(input)
            importedInput=reshape(input,[1,numel(input)]);
        end

        function paddedImg=setupCosimImage(importedImg,param)
            if(isinteger(importedImg))

                importedImg=int32(importedImg);
                oneInt32=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(1,param.ExpData);


                paddedImg=[importedImg,oneInt32];
            else
                paddedImg=[importedImg,1];
            end
        end

        function seqImg=seqImage(importedImg)
            seqImg=importedImg;
        end

        function xResult=calBaseline(param,seqImg,seqOp,reLUMode,reLUValue,reLUScaleExp)



            rowLimit=size(seqOp,1);
            colLimit=size(seqOp,2);

            if(isfi(seqImg))
                xfi=fi(0,1,param.WLA,param.fiMath.SumFractionLength,param.fiMath);
            else
                xfi=[];
            end





            if(isinteger(seqImg))
                seqImg=int32(seqImg);
                seqOp=int32(seqOp);
                xResult=int32(zeros(1,colLimit));
                dResult=int32(zeros(1,rowLimit));
            elseif(isfi(seqImg))
                xResult=zeros(1,colLimit,'like',xfi);
                dResult=zeros(1,rowLimit,'like',xfi);
            else
                dResult=zeros(1,rowLimit);
            end

            for i=1:colLimit
                for j=1:rowLimit
                    dResult(1,j)=seqImg(1,j)*seqOp(j,i);
                end
                xResult(1,i)=sum(dResult);
            end
            if(isfi(xResult))
                xResult=removefimath(xResult);
            end
            if(reLUMode)
                xResult=dnnfpga.processorbase.fcProcessor.reLUOutput(reLUMode,seqImg,xResult,reLUValue,reLUScaleExp);
            end
        end
        function reLUResults=reLUOutput(reLUMode,seqImg,reLUInput,reLUValue,reLUScaleExp)
            if(reLUMode==3)
                if(isinteger(seqImg))
                    reLUResults=(reLUInput.*int32(reLUInput<0)*(0)+int32(reLUInput>=reLUValue)*int32(reLUValue)+reLUInput.*int32(reLUInput>0&(reLUInput<reLUValue))*1);
                else
                    reLUResults=(reLUInput.*(reLUInput<0)*(0)+(reLUInput>=reLUValue)*(reLUValue)+reLUInput.*((reLUInput>0&reLUInput<reLUValue))*1);
                end
            else
                if(isinteger(seqImg))


                    reLUResults=((reLUInput.*int32(int32(reLUInput<0)*int32(reLUValue)))*2^(double(reLUScaleExp)))+(reLUInput.*(int32(reLUInput>=0)*(1)));
                else
                    reLUResults=reLUInput.*((reLUInput<0)*(reLUValue)+(reLUInput>=0)*(1));
                end
            end
        end

        function xResult=calBaselineGAP2D(image,threadNum,gapMultiplier)
            iterations=ceil(size(image,3)/threadNum);
            additionalFeaturesForZeroPadding=threadNum*iterations-size(image,3);

            if(isinteger(image))
                featureSize=int32(size(image,1)*size(image,2));
            else
                featureSize=single(size(image,1)*size(image,2));
            end

            if(additionalFeaturesForZeroPadding)
                if(isinteger(image))
                    zeroImage=int32(zeros([size(image,1),size(image,2),additionalFeaturesForZeroPadding]));
                    paddedImage=int32(cat(3,image,zeroImage));
                else
                    zeroImage=single(zeros([size(image,1),size(image,2),additionalFeaturesForZeroPadding]));
                    paddedImage=single(cat(3,image,zeroImage));
                end
            else
                if(isinteger(image))
                    paddedImage=int32(image);
                else
                    paddedImage=single(image);
                end
            end

            xResult=[];
            for i=1:iterations

                index=(i-1)*featureSize*threadNum+1;

                if(isinteger(image))
                    op=int32(zeros(1,threadNum));
                else
                    op=single(zeros(1,threadNum));
                end
                for j=0:featureSize-1

                    for k=1:threadNum



                        op(1,k)=op(1,k)+paddedImage(index+j+(k-1)*featureSize)*gapMultiplier;
                    end
                end
                xResult=[xResult,op];
            end


            xResult=xResult(1:(size(image,3)));
        end

    end

    methods(Access=public,Static=true)
        function DDRRespTime=getBoardResposeTime(BurstSize,ClockValue,boardType)
            switch boardType
            case 'Intel Arria 10 SoC development kit'
                DDRRespTime=dnnfpga.processorbase.fcProcessor.getArria10ResponseTime(BurstSize,ClockValue);
            case 'Xilinx Kintex-Ultrascale KCU105 evaluation board'
                DDRRespTime=dnnfpga.processorbase.fcProcessor.getXilinxKcu105ResponseTime(BurstSize,ClockValue);
            case 'Xilinx Zynq ZC706 evaluation kit'
                DDRRespTime=dnnfpga.processorbase.fcProcessor.getXilinxZc706ResponseTime(BurstSize,ClockValue);
            case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'
                DDRRespTime=dnnfpga.processorbase.fcProcessor.getXilinxZcu102ResponseTime(BurstSize,ClockValue);
            otherwise
                DDRRespTime=dnnfpga.processorbase.fcProcessor.getArria10ResponseTime(BurstSize,ClockValue);
            end
        end

        function RespTime=getArria10ResponseTime(BurstSize,ClockValue)


            ReadTimerOffset=[0,1,3,7,15,31,63,127,255,511,1023,2047,4095,8191];
            BurstLength=[8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536];
            InFrequency=[50,100,150,200,250,300];
            ReadTimerOffsetConst=[22,29,36,44,52,60];

            if(isempty(find(ClockValue==InFrequency))&&(ClockValue<InFrequency(end)))
                FreqMinBound=find(ClockValue>InFrequency);
                FreqMinBound=FreqMinBound(end);
                FreqMaxBound=find(ClockValue<InFrequency);
                FreqMaxBound=FreqMaxBound(1);
            elseif(isempty(find(ClockValue==InFrequency)))
                FreqMinBound=ReadTimerOffsetConst(end-1);
                FreqMaxBound=ReadTimerOffsetConst(end);
            end

            if(ClockValue==50)
                RespTime=BurstSize+ReadTimerOffsetConst(1);
            elseif(ClockValue==100)
                RespTime=BurstSize+(ReadTimerOffsetConst(2));
            elseif(ClockValue==150)
                RespTime=BurstSize+ReadTimerOffsetConst(3)+ReadTimerOffset(find(BurstSize==BurstLength));
            elseif((ClockValue==200)||(ClockValue==300))
                RespTime=BurstSize+ReadTimerOffsetConst(find(ClockValue==InFrequency))+(ReadTimerOffset(find(BurstSize==BurstLength))*((ClockValue-100)/50));
            else
                RespTime=BurstSize+ReadTimerOffsetConst(1)+((ClockValue-50)/50)*(ReadTimerOffsetConst(FreqMaxBound)-ReadTimerOffsetConst(FreqMinBound)-1)+(ReadTimerOffset(find(BurstSize==BurstLength))*((ClockValue-100)/50));
            end
            if(BurstSize==256)
                RespTime=RespTime-1;
            end
        end

        function RespTime=getXilinxKcu105ResponseTime(BurstSize,ClockValue)

            InitialOverhead=20;
            RespTime=ceil(BurstSize+InitialOverhead+(ClockValue/50));
        end

        function RespTime=getXilinxZc706ResponseTime(BurstSize,ClockValue)

            InitialOverhead=[40,62,87,103];
            if(ClockValue==50)
                RespTime=ceil(BurstSize+InitialOverhead(1)+2);
            elseif(ClockValue==100)
                RespTime=ceil(BurstSize+InitialOverhead(2)+6);
            elseif((ClockValue>50)&&(ClockValue<100))
                RespTime=ceil(BurstSize+InitialOverhead(1)+(InitialOverhead(2)-InitialOverhead(1))*((ClockValue-50)/50));
            else
                fprintf('Greater than 100MHz is not supported for estimation');
            end
        end

        function RespTime=getXilinxZcu102ResponseTime(BurstSize,ClockValue)

            InitialOverhead=150;
            RespTime=ceil(BurstSize+InitialOverhead+(ClockValue/50));
        end
    end

end
