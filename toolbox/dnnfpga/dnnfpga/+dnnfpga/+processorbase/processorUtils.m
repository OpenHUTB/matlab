classdef processorUtils




    methods(Static=true)

        function bcc=getAlexnetBCCConv2(varargin)

            bcc=dnnfpga.bcc.getBCCDefaultConv2(varargin{:});
        end

        function bcc=getAlexnetBCCFC(varargin)

            bcc=dnnfpga.bcc.getBCCDefaultFC(varargin{:});
        end

        function bcc=getAlexnetBCCInputP(varargin)

            bcc=dnnfpga.bcc.getBCCDefaultInputP(varargin{:});
        end

        function bcc=getAlexnetBCCOutputP(varargin)

            bcc=dnnfpga.bcc.getBCCDefaultOutputP(varargin{:});
        end

        function bcc=getBCCFC4(varargin)

            bcc=dnnfpga.bcc.getBCCDefaultFC4(varargin{:});
        end

        function bcc=getAlexnetBCCCNN4(varargin)

            bcc=dnnfpga.bcc.getBCCDefaultCNN4(varargin{:});
        end

        function bcc=getAlexnetBCCCNN2(varargin)

            bcc=dnnfpga.bcc.getBCCDefaultCNN2(varargin{:});
        end

        function bcc=getBCCConv4(varargin)

            bcc=dnnfpga.bcc.getBCCDefaultConv4(varargin{:});
        end

        function bcc=resolveIPLatencies(bcc,library,libraryParams,targetFrequency,deviceInfo)
            kernelDataType=bcc.kernelDataType;
            switch upper(library)
            case 'ALTERAFPFUNCTIONS'
                latencies=dnnfpga.assembler.getHwfpLatency(targetFrequency,deviceInfo,kernelDataType);
            case 'NATIVEFLOATINGPOINT'
                latencies=dnnfpga.processorbase.processorUtils.getNfpLatency(targetFrequency,libraryParams,deviceInfo,kernelDataType);
            otherwise
                assert(false,'"%s" is not a supported floating-point library.  Choose from "ALTERAFPFUNCTIONS" and "NATIVEFLOATINGPOINT".',library);
            end

            for i=1:length(latencies)
                lInfo=latencies(i);
                fieldName=sprintf('%sLatency',lInfo.name);
                bcc.(fieldName)=lInfo.latency;
            end
        end


        function latencies=getNfpLatency(~,libraryParams,~,kernelDataType)
            if(nargin<4)
                kernelDataType='SINGLE';
            end
            if(strcmpi(kernelDataType,'int8')||strcmpi(kernelDataType,'int4'))
                kernelDataType='single';
            end
            latencies=struct('name',{},'latency',{});
            switch lower(kernelDataType)
            case 'single'

                switch lower(libraryParams)
                case 'maxlatency'
                    lInfo.name='Sum';
                    lInfo.latency=11;
                    latencies(end+1)=lInfo;
                    lInfo.name='Prod';
                    lInfo.latency=8;
                    latencies(end+1)=lInfo;
                    lInfo.name='Cmp';
                    lInfo.latency=3;
                    latencies(end+1)=lInfo;
                    lInfo.name='MAD';
                    lInfo.latency=19;
                    latencies(end+1)=lInfo;
                    lInfo.name='Exp';
                    lInfo.latency=26;
                    latencies(end+1)=lInfo;
                    lInfo.name='Log';
                    lInfo.latency=27;
                    latencies(end+1)=lInfo;
                    lInfo.name='Divide';
                    lInfo.latency=32;
                    latencies(end+1)=lInfo;
                    lInfo.name='Fixdt_0_16_0_To_Single';
                    lInfo.latency=6;
                    latencies(end+1)=lInfo;
                case 'minlatency'
                    lInfo.name='Sum';
                    lInfo.latency=6;
                    latencies(end+1)=lInfo;
                    lInfo.name='Prod';
                    lInfo.latency=6;
                    latencies(end+1)=lInfo;
                    lInfo.name='Cmp';
                    lInfo.latency=1;
                    latencies(end+1)=lInfo;
                    lInfo.name='MAD';
                    lInfo.latency=12;
                    latencies(end+1)=lInfo;
                    lInfo.name='Exp';
                    lInfo.latency=16;
                    latencies(end+1)=lInfo;
                    lInfo.name='Log';
                    lInfo.latency=20;
                    latencies(end+1)=lInfo;
                    lInfo.name='Divide';
                    lInfo.latency=17;
                    latencies(end+1)=lInfo;
                    lInfo.name='Fixdt_0_16_0_To_Single';
                    lInfo.latency=6;
                    latencies(end+1)=lInfo;
                otherwise
                    assert(false,'unknown latency type %s',latency);
                end
            case 'half'
                switch lower(libraryParams)
                case 'maxlatency'
                    lInfo.name='Sum';
                    [~,lInfo.latency]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('AddSub','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Prod';
                    [~,lInfo.latency]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('Mul','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Cmp';
                    lInfo.latency=2;
                    latencies(end+1)=lInfo;
                    lInfo.name='MAD';
                    [~,lInfo.latency]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('MultAdd','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Exp';
                    [~,lInfo.latency]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('Exp','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Log';
                    [~,lInfo.latency]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('Log','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Divide';
                    [~,lInfo.latency]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('Div','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Fixdt_0_16_0_To_Single';
                    lInfo.latency=6;
                    latencies(end+1)=lInfo;
                case 'minlatency'
                    lInfo.name='Sum';
                    lInfo.latency=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('AddSub','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Prod';
                    lInfo.latency=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('Mul','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Cmp';
                    lInfo.latency=1;
                    latencies(end+1)=lInfo;
                    lInfo.name='MAD';
                    lInfo.latency=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('MultAdd','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Exp';
                    lInfo.latency=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('Exp','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Log';
                    lInfo.latency=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('Log','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Divide';
                    lInfo.latency=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('Div','HALF','nativefloatingpoint');
                    latencies(end+1)=lInfo;
                    lInfo.name='Fixdt_0_16_0_To_Single';
                    lInfo.latency=6;
                    latencies(end+1)=lInfo;
                otherwise
                    assert(false,'unknown latency type %s',latency);
                end
            otherwise
                assert(false,'unknown latency type %s',latency);
            end
        end
    end

    methods(Static=true)
        function lc=resolveLCPerLayerConv(param,chipConfig)
            param=dnnfpga.processorbase.processorUtils.padForSplit(param);
            switch(param.type)
            case 'FPGA_Conv2D'

                lc=dnnfpga.processorbase.processorUtils.resolveConvLayerConfigConv(param,chipConfig);
            otherwise
                assert(false,'unknown layer type %s',param.type);
            end
        end

        function output=cosim(param,input)
            switch param.type
            case 'SW_Cosim_BFPScaling'
                output=dnnfpga.processorbase.processorUtils.int32Toint8Conversion(param,input);
            case 'SW_Cosim_Scaling'
                output=dnnfpga.processorbase.processorUtils.singleToInt8Conversion(param,input,param.params{1}.singleToInt8Exp);
            case 'SW_Cosim_Rescaling'
                output=dnnfpga.processorbase.processorUtils.int8ToSingleConversion(param,input,param.params{1}.int8ToSingleExp);
            otherwise
                assert(false,'Unexpected layer type %s',param.type);
            end
        end

        function lc=resolveLCPerLayerConv2(param,chipConfig)



            if~isfield(param,'weightBaseAddrOffset')
                param.weightBaseAddrOffset=0;
            end

            param=dnnfpga.processorbase.processorUtils.padForSplit(param);

            switch(param.type)
            case 'FPGA_Conv2D'

                lc=dnnfpga.processorbase.processorUtils.resolveConvLayerConfigConv2(param,chipConfig);
            case 'FPGA_Maxpool2D'

                lc=dnnfpga.processorbase.processorUtils.resolveMaxpoolLayerConfigConv2(param,chipConfig);
            case 'FPGA_Avgpool2D'

                lc=dnnfpga.processorbase.processorUtils.resolveAveragepoolLayerConfigConv2(param,chipConfig);
            case 'FPGA_Lrn2D'

                lc=dnnfpga.processorbase.processorUtils.resolveLrnConfigConv2(param,chipConfig);
            case 'FPGA_ConvND'

                lc=dnnfpga.processorbase.processorUtils.resolveConvLayerConfigConvN(param,chipConfig);
            case{'FPGA_Unpool2D','FPGA_TransposedConv'}

                lc=dnnfpga.processorbase.processorUtils.resolveUnpoolLayerConfigConv2(param,chipConfig);
            otherwise
                assert(false,'unknown layer type %s',param.type);
            end
        end

        function lc=resolveLCPerLayerFC(param,chipConfig)
            switch(param.type)
            case 'FPGA_GAP2D'
                lc=dnnfpga.processorbase.processorUtils.resolveGAP2DLayer(param,chipConfig);
            case 'FPGA_Softmax'
                lc=dnnfpga.processorbase.processorUtils.resolveSoftmaxLayer(param,chipConfig);
            case 'FPGA_Sigmoid'
                lc=dnnfpga.processorbase.processorUtils.resolveSigmoidLayer(param,chipConfig);
            case 'FPGA_Exponential'
                lc=dnnfpga.processorbase.processorUtils.resolveExponentialLayer(param,chipConfig);
            otherwise
                lc=dnnfpga.processorbase.processorUtils.resolveFCLayer(param,chipConfig);
            end
        end

        function lc=resolveFCLayer(param,chipConfig)
            layerConfig.memDirection=param.memDirection;

            iterCounterSize(1)=ceil((param.matrixSize(1)+1));
            iterCounterSize(2)=ceil(param.matrixSize(2)/chipConfig.threadNumLimit);
            iterCounterSize(3)=1;
            if strcmp(param.type,'FPGA_FC')
                layerConfig.layerMode=3;
            else
                assert(false,'unknown layer: %s',param.type);
            end
            layerConfig.iterCounterSize=iterCounterSize;
            layerConfig.iterCounterSizeMinusOne=layerConfig.iterCounterSize-1;

            layerConfig.numberOfPaddedZeros=param.numberOfPaddedZeros;
            layerConfig.denominatorAddressSizeMinusOne=param.denominatorAddressSizeMinusOne;

            layerConfig.reLUMode=param.reLUMode;
            if isfield(param,'reLUValue')
                layerConfig.reLUValue=param.reLUValue;
            else
                layerConfig.reLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.WeightDiff=param.WeightDiff;
            layerConfig.MinWeight=param.MinWeight;
            layerConfig.memSelect=~param.memDirection;


            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int32ToInt8Exp=0;
                layerConfig.fcBias=single(1);
            else
                layerConfig.int32ToInt8Exp=-param.rescaleExp;


                layerConfig.fcBias=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(1,param.ExpData);


            end

            lc=dnnfpga.processorbase.fcProcessor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveGAP2DLayer(param,chipConfig)
            layerConfig.memDirection=param.memDirection;
            iterCounterSize(1)=param.featureSize;
            iterCounterSize(2)=ceil(param.matrixSize(2)/chipConfig.threadNumLimit);
            iterCounterSize(3)=1;

            layerConfig.layerMode=6;
            layerConfig.iterCounterSize=iterCounterSize;
            layerConfig.iterCounterSizeMinusOne=layerConfig.iterCounterSize-1;

            layerConfig.numberOfPaddedZeros=param.numberOfPaddedZeros;
            layerConfig.denominatorAddressSizeMinusOne=param.denominatorAddressSizeMinusOne;


            if isfield(param,'reLUMode')
                layerConfig.reLUMode=param.reLUMode;
            else
                layerConfig.reLUMode=0;
            end
            if isfield(param,'reLUValue')
                layerConfig.reLUValue=param.reLUValue;
            else
                layerConfig.reLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.WeightDiff=param.WeightDiff;
            layerConfig.MinWeight=param.MinWeight;
            layerConfig.memSelect=~param.memDirection;

            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int32ToInt8Exp=0;
                layerConfig.fcBias=single(1);
            else
                layerConfig.int32ToInt8Exp=-param.rescaleExp;


                layerConfig.fcBias=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(1,param.ExpData);
            end
            lc=dnnfpga.processorbase.fcProcessor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveSoftmaxLayer(param,chipConfig)
            layerConfig.memDirection=param.memDirection;


            layerConfig.layerMode=7;

            iterCounterSize(1)=2;
            iterCounterSize(2)=param.denominatorAddressSizeMinusOne+1;
            iterCounterSize(3)=1;

            iterCounterSizeMinusOne(1)=2;
            iterCounterSizeMinusOne(2)=param.denominatorAddressSizeMinusOne+1;
            iterCounterSizeMinusOne(3)=6;

            layerConfig.iterCounterSize=iterCounterSize;
            layerConfig.iterCounterSizeMinusOne=iterCounterSizeMinusOne;

            layerConfig.numberOfPaddedZeros=param.numberOfPaddedZeros;
            layerConfig.denominatorAddressSizeMinusOne=param.denominatorAddressSizeMinusOne;


            if isfield(param,'reLUMode')
                layerConfig.reLUMode=param.reLUMode;
            else
                layerConfig.reLUMode=0;
            end
            if isfield(param,'reLUValue')
                layerConfig.reLUValue=param.reLUValue;
            else
                layerConfig.reLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.WeightDiff=param.WeightDiff;
            layerConfig.MinWeight=param.MinWeight;
            layerConfig.memSelect=~param.memDirection;

            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int32ToInt8Exp=0;
                layerConfig.fcBias=single(1);
            else
                layerConfig.int32ToInt8Exp=-param.rescaleExp;


                layerConfig.fcBias=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(1,param.ExpData);
            end
            lc=dnnfpga.processorbase.fcProcessor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveSigmoidLayer(param,chipConfig)
            layerConfig.memDirection=param.memDirection;


            layerConfig.layerMode=8;

            iterCounterSize(1)=1;
            iterCounterSize(2)=param.denominatorAddressSizeMinusOne+1;
            iterCounterSize(3)=1;

            iterCounterSizeMinusOne(1)=1;
            iterCounterSizeMinusOne(2)=param.denominatorAddressSizeMinusOne+1;
            iterCounterSizeMinusOne(3)=1;

            layerConfig.iterCounterSize=iterCounterSize;
            layerConfig.iterCounterSizeMinusOne=iterCounterSizeMinusOne;

            layerConfig.numberOfPaddedZeros=param.numberOfPaddedZeros;
            layerConfig.denominatorAddressSizeMinusOne=param.denominatorAddressSizeMinusOne;

            if isfield(param,'reLUMode')
                layerConfig.reLUMode=param.reLUMode;
            else
                layerConfig.reLUMode=0;
            end
            if isfield(param,'reLUValue')
                layerConfig.reLUValue=param.reLUValue;
            else
                layerConfig.reLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.WeightDiff=param.WeightDiff;
            layerConfig.MinWeight=param.MinWeight;
            layerConfig.memSelect=~param.memDirection;

            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int32ToInt8Exp=0;
                layerConfig.fcBias=single(1);
            else
                layerConfig.int32ToInt8Exp=-param.rescaleExp;


                layerConfig.fcBias=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(1,param.ExpData);
            end
            lc=dnnfpga.processorbase.fcProcessor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveExponentialLayer(param,chipConfig)
            layerConfig.memDirection=param.memDirection;


            layerConfig.layerMode=9;

            iterCounterSize(1)=1;
            iterCounterSize(2)=param.denominatorAddressSizeMinusOne+1;
            iterCounterSize(3)=1;

            iterCounterSizeMinusOne(1)=1;
            iterCounterSizeMinusOne(2)=param.denominatorAddressSizeMinusOne+1;
            iterCounterSizeMinusOne(3)=1;

            layerConfig.iterCounterSize=iterCounterSize;
            layerConfig.iterCounterSizeMinusOne=iterCounterSizeMinusOne;

            layerConfig.numberOfPaddedZeros=param.numberOfPaddedZeros;
            layerConfig.denominatorAddressSizeMinusOne=param.denominatorAddressSizeMinusOne;

            if isfield(param,'reLUMode')
                layerConfig.reLUMode=param.reLUMode;
            else
                layerConfig.reLUMode=0;
            end
            if isfield(param,'reLUValue')
                layerConfig.reLUValue=param.reLUValue;
            else
                layerConfig.reLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.WeightDiff=param.WeightDiff;
            layerConfig.MinWeight=param.MinWeight;
            layerConfig.memSelect=~param.memDirection;

            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int32ToInt8Exp=0;
                layerConfig.fcBias=single(1);
            else
                layerConfig.int32ToInt8Exp=-param.rescaleExp;


                layerConfig.fcBias=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(1,param.ExpData);
            end
            lc=dnnfpga.processorbase.fcProcessor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveModuleLCPerLayerFC(param,chipConfig,networkConfig,convDataTransNum,convLastLayerDDROffset,fcOutputResultOffset)





            if(strcmp(chipConfig.kernelDataType,'single'))
                AddrIncBuffOffset=4;
            else
                AddrIncBuffOffset=1;
            end







            lc.ip_ddr_addr=uint32(convLastLayerDDROffset);
            lc.ip_ddr_len=uint32(ceil(networkConfig.fc_ip_ddr_len/convDataTransNum));
            lc.ip_dir=false;


            lc.op_ddr_len=uint32(ceil(networkConfig.fc_op_ddr_len/convDataTransNum));
            lc.op_ddr_addr=uint32(fcOutputResultOffset);

            if(strcmp(chipConfig.kernelDataType,'single'))
                lc.op_ddr_offset=uint32(AddrIncBuffOffset*ceil(networkConfig.result_count/convDataTransNum)*convDataTransNum);
            else
                lc.op_ddr_offset=uint32(AddrIncBuffOffset*ceil(networkConfig.result_count/chipConfig.threadNumLimit)*chipConfig.threadNumLimit);
            end
            lc.op_dir=logical(networkConfig.fc_op_dir);










            lc.fcOutputExp=fi(param.fcOutputExp,1,8,0);
            lc.fcInputExp=fi(param.fcInputExp,1,8,0);

            if(strcmp(chipConfig.kernelDataType,'single'))
                lc.gapMultiplier=fi(typecast(single(param.gapMultiplier),'uint32'),0,32,0);
            else

                lc.gapMultiplier=fi(typecast(int32(param.gapMultiplier),'uint32'),0,32,0);
            end
            lc.numberOfPaddedZeros=uint8(param.numberOfPaddedZeros);
            lc.denominatorAddressSizeMinusOne=fi(param.denominatorAddressSizeMinusOne,0,param.iterCounterWLimit,0);


            lc.weightSize=uint32(networkConfig.fc_weightSize);
            lc.layerNum=uint32(networkConfig.layerNumMinusOne);
        end

        function lc=resolveModuleLCPerFCModule(param,networkConfig,dataTransNum,fcthreadNum)






            if(param.WL==8)
                AddrIncBuffOffset=1;
            else
                AddrIncBuffOffset=4;
            end









            lc.ip_ddr_addr=uint32(1111);
            lc.ip_ddr_len=uint32(ceil(networkConfig.fc_ip_ddr_len/dataTransNum));
            lc.ip_dir=false;


            lc.op_ddr_len=uint32(ceil(networkConfig.fc_op_ddr_len/dataTransNum));
            lc.op_ddr_addr=uint32(2222);
            if(param.WL==8)
                lc.op_ddr_offset=uint32(AddrIncBuffOffset*ceil(networkConfig.result_count/fcthreadNum)*fcthreadNum);
            else
                lc.op_ddr_offset=uint32(AddrIncBuffOffset*ceil(networkConfig.result_count/dataTransNum)*dataTransNum);
            end

            lc.op_dir=logical(networkConfig.fc_op_dir);









            lc.fcOutputExp=fi(param.fcOutputExp,1,8,0);
            lc.fcInputExp=fi(param.fcInputExp,1,8,0);

            if(param.WL==8)

                lc.gapMultiplier=fi(typecast(int32(param.gapMultiplier),'uint32'),0,32,0);
            else
                lc.gapMultiplier=fi(typecast(single(param.gapMultiplier),'uint32'),0,32,0);
            end

            lc.numberOfPaddedZeros=uint8(param.numberOfPaddedZeros);
            lc.denominatorAddressSizeMinusOne=fi(param.denominatorAddressSizeMinusOne,0,param.iterCounterWLimit,0);


            lc.weightSize=uint32(networkConfig.fc_weightSize);
            lc.layerNum=uint32(networkConfig.layerNumMinusOne);

        end


        function lcs=resolveLCPerLayerInputP(param,chipConfig)




            assert(log2(ceil(chipConfig.imgSizeLimit(1)/chipConfig.opW))<=32);
            assert(log2(ceil(chipConfig.imgSizeLimit(2)/chipConfig.opW))<=32);
            assert((ceil(log2(chipConfig.opW))+1)<=32);
            assert((ceil(log2(chipConfig.threadNumLimit))+1)<=32);
            assert(ceil(log2(max(prod(chipConfig.inputMemDepthLimit),prod(chipConfig.resultMemDepthLimit))))<=32);
            assert(ceil(log2(max(prod(chipConfig.resultMemDepthLimit),chipConfig.inputMemDepthLimit)))<=32);
            assert(ceil(log2(max(prod(chipConfig.resultMemDepthLimit),chipConfig.inputMemDepthLimit)))<=32);





            if(chipConfig.dataTransNum>1)
                param.deltaZ=ceil(param.deltaZ/chipConfig.threadNumLimit)*chipConfig.dataTransNum;
            end

            lc.Xdiv3=uint32(ceil(param.deltaX/chipConfig.opW));
            lc.Ydiv3=uint32(ceil(param.deltaY/chipConfig.opW));
            lc.BLOCK_LIMIT=uint32(1);
            lc.Xmod3=uint32(mod(param.deltaX,chipConfig.opW));
            lc.Ymod3=uint32(mod(param.deltaY,chipConfig.opW));
            if lc.Xmod3==0
                lc.Xmod3=uint32(chipConfig.opW);
            end
            if lc.Ymod3==0
                lc.Ymod3=uint32(chipConfig.opW);
            end
            lc.loop_times=uint32(chipConfig.opW);
            lc.memSelect=uint32(param.memSelect);


            lcss=cell(1,ceil(param.deltaZ/chipConfig.dataTransNum)*param.deltaY);
            cellIdx=1;


            addr_offset=ceil(param.deltaX/chipConfig.opW)*ceil(param.deltaY/chipConfig.opW);
            if param.inputSource==1
                lc.datapath_sel=uint32(true);


                for j=1:param.deltaZ/chipConfig.dataTransNum
                    lc_z=lc;





                    if(strcmp(chipConfig.kernelDataType,'single'))
                        AddrIncBuffOffset=4;
                    else
                        AddrIncBuffOffset=1;
                    end










                    curDeltaZ=chipConfig.dataTransNum;





                    lc_z.Z=uint32(param.firstLayer);
                    lc_z.request_len=uint32(param.deltaX);
                    lc_z.addroffset=uint32((j-1)*addr_offset);





                    start_addr_bias=param.DDR_request_start_addr+AddrIncBuffOffset*curDeltaZ*param.Xlimit*param.Y+param.X*curDeltaZ*AddrIncBuffOffset+(j-1)*param.Xlimit*param.Ylimit*chipConfig.dataTransNum*AddrIncBuffOffset;

                    for i=1:param.deltaY
                        lc_temp=lc_z;
                        lc_temp.request_start_addr=uint32(start_addr_bias+(i-1)*curDeltaZ*param.Xlimit*AddrIncBuffOffset);
                        lc_temp.Ydiv3offset=uint32(floor((i-1)/chipConfig.opW));
                        lc_temp.Ymod3offset=uint32(mod(i-1,chipConfig.opW));
                        lcss{cellIdx}=lc_temp;
                        cellIdx=cellIdx+1;
                    end
                end
            else
                lc.datapath_sel=uint32(false);
                lc.request_len=uint32(param.deltaY*param.deltaX*param.deltaZ);
                lc.Z=uint32(param.firstLayer);
                lc.request_start_addr=uint32(param.DDR_request_start_addr);
                lc.Ydiv3offset=uint32(0);
                lc.Ymod3offset=uint32(0);
                lc.addroffset=uint32(0);

                lcss{cellIdx}=lc;
            end
            lcs=cell2mat(lcss);
        end

        function lcs=resolveLCPerLayerOutputP(param,chipConfig)



            assert(log2(ceil(chipConfig.imgSizeLimit(1)/chipConfig.opW))<=32);
            assert(log2(ceil(chipConfig.imgSizeLimit(2)/chipConfig.opW))<=32);
            assert((ceil(log2(chipConfig.opW))+1)<=32);
            assert((ceil(log2(chipConfig.threadNumLimit))+1)<=32);
            assert(ceil(log2(max(prod(chipConfig.inputMemDepthLimit),prod(chipConfig.resultMemDepthLimit))))<=32);
            assert(ceil(log2(max(prod(chipConfig.resultMemDepthLimit),chipConfig.inputMemDepthLimit)))<=32);
            assert(ceil(log2(max(prod(chipConfig.resultMemDepthLimit),chipConfig.inputMemDepthLimit)))<=32);





            if(chipConfig.dataTransNum>1)
                param.deltaZ=ceil(param.deltaZ/chipConfig.threadNumLimit)*chipConfig.dataTransNum;
            end

            lc.Xdiv3=uint32(ceil(param.deltaX/chipConfig.opW));
            lc.Ydiv3=uint32(ceil(param.deltaY/chipConfig.opW));
            lc.BLOCK_LIMIT=uint32(1);
            lc.Xmod3=uint32(mod(param.deltaX,chipConfig.opW));
            lc.Ymod3=uint32(mod(param.deltaY,chipConfig.opW));

            if mod(param.deltaX,chipConfig.opW)==0
                lc.Xmod3=uint32(chipConfig.opW);
            end
            if mod(param.deltaY,chipConfig.opW)==0
                lc.Ymod3=uint32(chipConfig.opW);
            end
            lc.loop_times=uint32(chipConfig.opW);
            lc.memSelect=uint32(param.memSelect);
            lcss=cell(1,ceil(param.deltaZ/chipConfig.dataTransNum)*param.deltaY);



            cellIdx=1;
            addr_offset=ceil(param.deltaX/chipConfig.opW)*ceil(param.deltaY/chipConfig.opW);
            if param.inputSource==1
                lc.datapath_sel=uint32(param.lastLayer);


                for j=1:param.deltaZ/chipConfig.dataTransNum
                    lc_z=lc;







                    if(strcmp(chipConfig.kernelDataType,'single'))
                        AddrIncBuffOffset=4;
                    else
                        AddrIncBuffOffset=1;
                    end










                    curDeltaZ=chipConfig.dataTransNum;

                    lc_z.Z=uint32(curDeltaZ);
                    lc_z.request_len=uint32(param.deltaX);
                    lc_z.addroffset=uint32((j-1)*addr_offset);




                    start_addr_bias=param.DDR_request_start_addr+AddrIncBuffOffset*curDeltaZ*param.Xlimit*param.Y+param.X*curDeltaZ*AddrIncBuffOffset+(j-1)*param.Xlimit*param.Ylimit*chipConfig.dataTransNum*AddrIncBuffOffset;

                    for i=1:param.deltaY
                        lc_temp=lc_z;




                        lc_temp.request_start_addr=uint32(start_addr_bias+(i-1)*curDeltaZ*param.Xlimit*AddrIncBuffOffset);


                        lc_temp.Ydiv3offset=uint32(floor((i-1)/chipConfig.opW));
                        lc_temp.Ymod3offset=uint32(mod(i-1,chipConfig.opW));

                        lcss{cellIdx}=lc_temp;
                        cellIdx=cellIdx+1;
                    end
                end
            else
                lc.datapath_sel=uint32(param.lastLayer);
                lc.request_len=uint32(param.deltaY*param.deltaX*param.deltaZ);
                lc.Z=uint32(2);
                lc.request_start_addr=uint32(param.DDR_request_start_addr);
                lc.Ydiv3offset=uint32(0);
                lc.Ymod3offset=uint32(0);
                lc.addroffset=uint32(0);

                lcss{cellIdx}=lc;
            end
            lcs=cell2mat(lcss);
        end

        function lc=resolveConvLayerConfigConv(param,chipConfig)
            inputFeatureNum=param.inputFeatureNum;
            outputFeatureNum=param.outputFeatureNum;
            origImgSize=param.origImgSize;
            origOpSizeValue=param.origOpSizeValue;

            layerConfig.memDirection=param.memDirection;
            layerConfig.convMode=true;
            layerConfig.strideMode=log2(param.strideMode);
            layerConfig.reLUMode=param.reLUMode;
            if isfield(param,'reLUValue')
                layerConfig.convReLUValue=param.reLUValue;
            else
                layerConfig.convReLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.paddingMode=param.paddingMode;
            superConvolutionSize=ones(6,1);
            if(~param.convSplitMode)
                layerConfig.halfInputFeatureNum=0;
                layerConfig.halfOutputFeatureNum=0;

                superConvolutionSize(1)=1;
                superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)=ceil(inputFeatureNum/chipConfig.threadNumLimit);
                superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=ceil(outputFeatureNum/chipConfig.threadNumLimit);
                superConvolutionSize(chipConfig.ControlLogicTileXAddrIdx:chipConfig.ControlLogicTileYAddrIdx)=ceil(origOpSizeValue(1:2)./chipConfig.opSize(1:2));
            else
                assert(mod(inputFeatureNum,2)==0);
                layerConfig.halfInputFeatureNum=ceil(inputFeatureNum/2/chipConfig.threadNumLimit);
                assert(mod(outputFeatureNum,2)==0);
                layerConfig.halfOutputFeatureNum=ceil(outputFeatureNum/2/chipConfig.threadNumLimit);

                superConvolutionSize(1)=2;
                superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)=ceil((inputFeatureNum/2)/chipConfig.threadNumLimit);
                superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=ceil((outputFeatureNum/2)/chipConfig.threadNumLimit);
                superConvolutionSize(chipConfig.ControlLogicTileXAddrIdx:chipConfig.ControlLogicTileYAddrIdx)=ceil(origOpSizeValue(1:2)./chipConfig.opSize(1:2));
            end
            layerConfig.convTileSize=superConvolutionSize;
            layerConfig.convTileThreadExpansionSize=[1;ceil(superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)/chipConfig.threadNumLimit);chipConfig.threadNumLimit];
            layerConfig.convImgSize=origImgSize;
            layerConfig.convOpSize=origOpSizeValue;
            layerConfig.leftMemSize=[ceil((inputFeatureNum/2)/chipConfig.threadNumLimit);origImgSize(1:2)];
            if(numel(param.paddingMode)==1)
                param.paddingMode=ones(1,4)*param.paddingMode;
            end
            assert(param.paddingMode(1)==param.paddingMode(2)&&param.paddingMode(1)==param.paddingMode(3)&&param.paddingMode(1)==param.paddingMode(4));
            resultSize=floor((origImgSize+[2*param.paddingMode(1);2*param.paddingMode(1);0]-origOpSizeValue+1-1)./dnnfpga.convbase.resolveStrideMode(param.strideMode))+1;
            layerConfig.rightMemSize=[ceil((outputFeatureNum/2)/chipConfig.threadNumLimit);resultSize(1:2)];

            lc=dnnfpga.processorbase.convProcessor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveInputLayerConfigConv(param,chipConfig)
            lc=dnnfpga.processorbase.processorUtils.resolveConvLayerConfigConv(param,chipConfig);
            lc.convMode=4;
            lc=dnnfpga.processorbase.convProcessor.typeLayerConfig(chipConfig,lc);
        end

        function lc=resolveMaxpoolLayerConfigConv(param,chipConfig)
            inputFeatureNum=param.inputFeatureNum;
            origImgSize=param.origImgSize;

            layerConfig.memDirection=param.memDirection;
            layerConfig.convMode=false;
            layerConfig.strideMode=log2(param.strideMode);
            layerConfig.reLUMode=false;
            if isfield(param,'reLUValue')
                layerConfig.convReLUValue=param.reLUValue;
            else
                layerConfig.convReLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.paddingMode=0;
            layerConfig.halfInputFeatureNum=0;
            layerConfig.halfOutputFeatureNum=0;
            superConvolutionSize=ones(6,1);
            superConvolutionSize(1)=1;
            superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)=ceil(inputFeatureNum/chipConfig.threadNumLimit);
            superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=1;
            superConvolutionSize(chipConfig.ControlLogicTileXAddrIdx:chipConfig.ControlLogicTileYAddrIdx)=[1;1];
            layerConfig.convTileSize=superConvolutionSize;
            layerConfig.convTileThreadExpansionSize=[1;superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx);1];
            layerConfig.convImgSize=origImgSize;
            layerConfig.convOpSize=chipConfig.opSize;
            layerConfig.leftMemSize=[inputFeatureNum;origImgSize(1:2)];
            resultSize=floor((origImgSize-chipConfig.opSize+1-1)./dnnfpga.convbase.resolveStrideMode(param.strideMode))+1;
            layerConfig.rightMemSize=[inputFeatureNum;resultSize(1:2)];

            lc=dnnfpga.processorbase.convProcessor.typeLayerConfig(chipConfig,layerConfig);
        end


        function lc=resolveConvLayerConfigConv2(param,chipConfig)
            layerConfig.activeFIFOEn=false;
            layerConfig.activeFIFOMemSel=false;
            inputFeatureNum=param.inputFeatureNum;
            outputFeatureNum=param.outputFeatureNum;
            origImgSize=param.origImgSize;
            origOpSizeValue=param.origOpSizeValue;

            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;
                layerConfig.int32ToInt8Exp=0;
            else
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;
                layerConfig.int32ToInt8Exp=-param.rescaleExp;

            end

            layerConfig.avgpoolMultiplier=1;
            layerConfig.memDirection=param.memDirection;
            layerConfig.convMode=1;
            layerConfig.strideMode=param.strideMode;
            layerConfig.reLUMode=param.reLUMode;
            if isfield(param,'reLUValue')
                layerConfig.convReLUValue=param.reLUValue;
            else
                layerConfig.convReLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.paddingMode=param.paddingMode(1);
            superConvolutionSize=ones(6,1);
            if(~param.convSplitMode)
                layerConfig.halfInputFeatureNum=0;
                layerConfig.halfOutputFeatureNum=0;

                superConvolutionSize(1)=1;
                superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)=ceil(inputFeatureNum/chipConfig.threadNumLimit);
                superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=ceil(outputFeatureNum/chipConfig.threadNumLimit);
                superConvolutionSize(chipConfig.ControlLogicTileXAddrIdx:chipConfig.ControlLogicTileYAddrIdx)=ceil(origOpSizeValue(1:2)./chipConfig.opSize(1:2));
            else
                assert(mod(inputFeatureNum,2)==0);
                layerConfig.halfInputFeatureNum=ceil(inputFeatureNum/2/chipConfig.threadNumLimit);
                assert(mod(outputFeatureNum,2)==0);
                layerConfig.halfOutputFeatureNum=ceil(outputFeatureNum/2/chipConfig.threadNumLimit);

                superConvolutionSize(1)=2;
                superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)=ceil((inputFeatureNum/2)/chipConfig.threadNumLimit);
                superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=ceil((outputFeatureNum/2)/chipConfig.threadNumLimit);
                superConvolutionSize(chipConfig.ControlLogicTileXAddrIdx:chipConfig.ControlLogicTileYAddrIdx)=ceil(origOpSizeValue(1:2)./chipConfig.opSize(1:2));
            end
            layerConfig.convTileSize=superConvolutionSize;
            layerConfig.convTileThreadExpansionSize=[1;ceil(superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)/chipConfig.threadNumLimit);chipConfig.threadNumLimit];
            layerConfig.convImgSize=origImgSize;
            layerConfig.convOpSize=origOpSizeValue;
            layerConfig.leftMemSize=[ceil((inputFeatureNum/2)/chipConfig.threadNumLimit);prod(ceil(origImgSize./chipConfig.opSize));1];

            layerConfig.stride=param.strideMode;
            layerConfig.padding=param.paddingMode;


            layerConfig.dilation=param.dilationMode(1);
            [resultSize,resultSizeDivByOpW,imgSizeDivByOpW,xy0,rxy0,...
            wAddr0,dw,dr,dz,rzLimitOriginal]=...
            dnnfpga.processorbase.initCtrlData(...
            layerConfig.padding,layerConfig.stride,param.stridePhase,...
            layerConfig.dilation,param.origImgSize(1:2),...
            param.origOpSizeValue,chipConfig.wSizeLimit,chipConfig.opW);
            if(isempty(param.firstWritePos))
                layerConfig.firstWritePos=[0;resultSize(1);0;resultSize(2)];
            else
                layerConfig.firstWritePos=param.firstWritePos;
            end
            if(isempty(param.finalWriteSize))
                layerConfig.finalWriteSize=resultSize;
            else
                layerConfig.finalWriteSize=param.finalWriteSize;
            end
            layerConfig.resultSize=resultSize;
            layerConfig.resultSizeDivByOpW=resultSizeDivByOpW;
            layerConfig.resultSizeDivByOpWSquared=prod(resultSizeDivByOpW);
            layerConfig.imgSize=origImgSize(1:2);
            layerConfig.imgSizeDivByOpW=imgSizeDivByOpW;
            layerConfig.imgSizeDivByOpWSquared=prod(imgSizeDivByOpW);
            layerConfig.xy0=xy0;
            layerConfig.rxy0=rxy0;
            layerConfig.wAddr0=0;
            layerConfig.dw=dw;
            layerConfig.dr=dr;
            layerConfig.dz=dz;
            layerConfig.rzLimitOriginal=rzLimitOriginal;

            layerConfig.rightMemSize=[ceil((outputFeatureNum/2)/chipConfig.threadNumLimit);ceil(resultSize(1)/chipConfig.opW)*ceil(resultSize(2)/chipConfig.opW);1];
            param.lrnPadddingSize(1:2)=mod(-(size(resultSize,1)),chipConfig.opSize(1));
            param.lrnPadddingSize(3)=mod(-param.outputFeatureNum,chipConfig.threadNumLimit);
            param.convOutputFeature=param.outputFeatureNum;
            layerConfig.lrnLocalSize=param.lrnLocalSize;
            layerConfig.lrnAlpha=param.lrnAlpha;
            layerConfig.lrnBeta=param.lrnBeta;
            layerConfig.lrnK=param.lrnK;
            layerConfig.lrnFeaturePadding=param.lrnFeaturePadding;

            layerConfig.convOutputFeature=param.convOutputFeature;
            layerConfig.lrnPadddingSize=param.lrnPadddingSize;

            layerConfig.accumulateRightMem=false;

            layerConfig.inputMemZAdapterActive=param.inputMemZAdapterActive;

            layerConfig.convTileSizeMinusOne=layerConfig.convTileSize(1:5)-1;
            layerConfig.convTileSizeMinusTwo=layerConfig.convTileSize(1:5)-2;
            layerConfig.convOpSizePlusPaddingSizeMinusOne=layerConfig.convOpSize-layerConfig.paddingMode-1;
            layerConfig.convImgSizeMinusOne=layerConfig.convImgSize-1;
            layerConfig.convImgSizeMinusOpSizePlusTwoPaddingSize=layerConfig.convImgSize-layerConfig.convOpSize+2*layerConfig.paddingMode;


            layerConfig.smallPoolLayerEn=param.smallLayerEn;


            layerConfig.IndexActsSelectorOffsetInit=0;
            layerConfig.IndexActsDimensionalOffsetsInit=zeros(1,3);

            layerConfig.isMaxpoolIndexLeg=0;
            layerConfig.fullFeatureSize=0;
            layerConfig.fullColumnsSize=0;





            layerConfig.weightBaseAddrOffset=param.weightBaseAddrOffset;
            layerConfig.nextTileOffset=0;

            lc=dnnfpga.processorbase.conv2Processor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveConvLayerConfigConvN(param,chipConfig)

            layerConfig.activeFIFOEn=false;
            layerConfig.activeFIFOMemSel=false;
            inputFeatureNum=param.inputFeatureNum;
            outputFeatureNum=param.outputFeatureNum;
            origImgSize=param.origImgSize;
            origOpSizeValue=param.origOpSizeValue;

            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;
                layerConfig.int32ToInt8Exp=0;
            else
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;



                layerConfig.int32ToInt8Exp=0;

            end

            layerConfig.avgpoolMultiplier=1;
            layerConfig.memDirection=param.memDirection;
            layerConfig.convMode=5;
            layerConfig.strideMode=param.strideMode;
            layerConfig.reLUMode=param.reLUMode;
            if isfield(param,'reLUValue')
                layerConfig.convReLUValue=param.reLUValue;
            else
                layerConfig.convReLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.paddingMode=param.paddingMode(1);
            superConvolutionSize=ones(6,1);

            layerConfig.halfInputFeatureNum=0;
            layerConfig.halfOutputFeatureNum=0;

            superConvolutionSize(1)=1;
            superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)=ceil(inputFeatureNum/chipConfig.threadNumLimit);
            superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=1;
            superConvolutionSize(chipConfig.ControlLogicTileXAddrIdx:chipConfig.ControlLogicTileYAddrIdx)=ceil(origOpSizeValue(1:2)./chipConfig.opSize(1:2));

            layerConfig.convTileSize=superConvolutionSize;
            layerConfig.convTileThreadExpansionSize=[1;ceil(superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)/chipConfig.threadNumLimit);chipConfig.threadNumLimit];
            layerConfig.convImgSize=origImgSize;
            layerConfig.convOpSize=origOpSizeValue;
            layerConfig.leftMemSize=[ceil((inputFeatureNum/2)/chipConfig.threadNumLimit);prod(ceil(origImgSize./chipConfig.opSize));1];

            layerConfig.stride=param.strideMode;
            layerConfig.padding=param.paddingMode;


            layerConfig.dilation=param.dilationMode(1);
            [resultSize,resultSizeDivByOpW,imgSizeDivByOpW,xy0,rxy0,...
            wAddr0,dw,dr,dz,rzLimitOriginal]=...
            dnnfpga.processorbase.initCtrlData(...
            layerConfig.padding,layerConfig.stride,param.stridePhase,...
            layerConfig.dilation,param.origImgSize(1:2),...
            param.origOpSizeValue,chipConfig.wSizeLimit,chipConfig.opW);
            if(isempty(param.firstWritePos))
                layerConfig.firstWritePos=[0;resultSize(1);0;resultSize(2)];
            else
                layerConfig.firstWritePos=param.firstWritePos;
            end
            if(isempty(param.finalWriteSize))
                layerConfig.finalWriteSize=resultSize;
            else
                layerConfig.finalWriteSize=param.finalWriteSize;
            end
            layerConfig.resultSize=resultSize;
            layerConfig.resultSizeDivByOpW=resultSizeDivByOpW;
            layerConfig.resultSizeDivByOpWSquared=prod(resultSizeDivByOpW);
            layerConfig.imgSize=origImgSize(1:2);
            layerConfig.imgSizeDivByOpW=imgSizeDivByOpW;
            layerConfig.imgSizeDivByOpWSquared=prod(imgSizeDivByOpW);
            layerConfig.xy0=xy0;
            layerConfig.rxy0=rxy0;
            layerConfig.wAddr0=0;
            layerConfig.dw=dw;
            layerConfig.dr=dr;
            layerConfig.dz=dz;
            layerConfig.rzLimitOriginal=rzLimitOriginal;

            layerConfig.rightMemSize=[ceil((outputFeatureNum/2)/chipConfig.threadNumLimit);ceil(resultSize(1)/chipConfig.opW)*ceil(resultSize(2)/chipConfig.opW);1];
            param.lrnPadddingSize(1:2)=mod(-(size(resultSize,1)),chipConfig.opSize(1));
            param.lrnPadddingSize(3)=mod(-param.outputFeatureNum,chipConfig.threadNumLimit);
            param.convOutputFeature=param.outputFeatureNum;
            layerConfig.lrnLocalSize=param.lrnLocalSize;
            layerConfig.lrnAlpha=param.lrnAlpha;
            layerConfig.lrnBeta=param.lrnBeta;
            layerConfig.lrnK=param.lrnK;
            layerConfig.lrnFeaturePadding=param.lrnFeaturePadding;

            layerConfig.convOutputFeature=param.convOutputFeature;
            layerConfig.lrnPadddingSize=param.lrnPadddingSize;

            layerConfig.accumulateRightMem=false;

            layerConfig.inputMemZAdapterActive=param.inputMemZAdapterActive;

            layerConfig.convTileSizeMinusOne=layerConfig.convTileSize(1:5)-1;
            layerConfig.convTileSizeMinusTwo=layerConfig.convTileSize(1:5)-2;
            layerConfig.convOpSizePlusPaddingSizeMinusOne=layerConfig.convOpSize-layerConfig.paddingMode-1;
            layerConfig.convImgSizeMinusOne=layerConfig.convImgSize-1;
            layerConfig.convImgSizeMinusOpSizePlusTwoPaddingSize=layerConfig.convImgSize-layerConfig.convOpSize+2*layerConfig.paddingMode;
            layerConfig.smallPoolLayerEn=param.smallLayerEn;


            layerConfig.IndexActsSelectorOffsetInit=0;
            layerConfig.IndexActsDimensionalOffsetsInit=zeros(1,3);

            layerConfig.isMaxpoolIndexLeg=0;
            layerConfig.fullFeatureSize=0;
            layerConfig.fullColumnsSize=0;





            layerConfig.weightBaseAddrOffset=param.weightBaseAddrOffset;
            layerConfig.nextTileOffset=0;

            lc=dnnfpga.processorbase.conv2Processor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveMaxpoolLayerConfigConv2(param,chipConfig)
            layerConfig.activeFIFOEn=false;
            layerConfig.activeFIFOMemSel=false;
            inputFeatureNum=param.inputFeatureNum;
            origImgSize=param.origImgSize;
            origOpSizeValue=param.origOpSizeValue;

            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;
                layerConfig.int32ToInt8Exp=0;
            else
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;
                layerConfig.int32ToInt8Exp=-param.rescaleExp;

            end

            layerConfig.avgpoolMultiplier=-1;
            layerConfig.memDirection=param.memDirection;
            layerConfig.convMode=0;
            layerConfig.strideMode=param.strideMode;
            layerConfig.reLUMode=false;
            if isfield(param,'reLUValue')
                layerConfig.convReLUValue=param.reLUValue;
            else
                layerConfig.convReLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.paddingMode=0;
            layerConfig.halfInputFeatureNum=0;
            layerConfig.halfOutputFeatureNum=0;
            superConvolutionSize=ones(6,1);
            superConvolutionSize(1)=1;
            superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)=ceil(inputFeatureNum/chipConfig.threadNumLimit);
            superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=1;

            superConvolutionSize(chipConfig.ControlLogicTileXAddrIdx:chipConfig.ControlLogicTileYAddrIdx)=ceil(origOpSizeValue(1:2)./chipConfig.opSize(1:2));
            layerConfig.convTileSize=superConvolutionSize;
            layerConfig.convTileThreadExpansionSize=[1;superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx);1];
            layerConfig.convImgSize=origImgSize;
            layerConfig.convOpSize=origOpSizeValue;
            layerConfig.leftMemSize=[inputFeatureNum;origImgSize(1:2)];

            layerConfig.stride=param.strideMode;
            layerConfig.padding=param.paddingMode;
            layerConfig.dilation=param.dilationMode;
            [resultSize,resultSizeDivByOpW,imgSizeDivByOpW,xy0,rxy0,...
            wAddr0,dw,dr,dz,rzLimitOriginal]=...
            dnnfpga.processorbase.initCtrlData(...
            layerConfig.padding,layerConfig.stride,param.stridePhase,...
            layerConfig.dilation,param.origImgSize(1:2),...
            param.origOpSizeValue,chipConfig.wSizeLimit,chipConfig.opW);
            if(isempty(param.firstWritePos))
                layerConfig.firstWritePos=[0;resultSize(1);0;resultSize(2)];
            else
                layerConfig.firstWritePos=param.firstWritePos;
            end
            if(isempty(param.finalWriteSize))
                layerConfig.finalWriteSize=resultSize;
            else
                layerConfig.finalWriteSize=param.finalWriteSize;
            end
            layerConfig.resultSize=resultSize;
            layerConfig.resultSizeDivByOpW=resultSizeDivByOpW;
            layerConfig.resultSizeDivByOpWSquared=prod(resultSizeDivByOpW);
            layerConfig.imgSize=origImgSize(1:2);
            layerConfig.imgSizeDivByOpW=imgSizeDivByOpW;
            layerConfig.imgSizeDivByOpWSquared=prod(imgSizeDivByOpW);
            layerConfig.xy0=xy0;
            layerConfig.rxy0=rxy0;
            layerConfig.wAddr0=0;
            layerConfig.dw=dw;
            layerConfig.dr=dr;
            layerConfig.dz=dz;
            layerConfig.rzLimitOriginal=rzLimitOriginal;

            layerConfig.rightMemSize=[inputFeatureNum;resultSize];
            lps=mod(-resultSize,chipConfig.opSize(1:2));
            param.lrnPadddingSize(1:2)=lps(1:2);
            param.lrnPadddingSize(3)=mod(-param.outputFeatureNum,chipConfig.threadNumLimit);
            param.convOutputFeature=param.outputFeatureNum;
            layerConfig.lrnLocalSize=param.lrnLocalSize;
            layerConfig.lrnAlpha=param.lrnAlpha;
            layerConfig.lrnBeta=param.lrnBeta;
            layerConfig.lrnK=param.lrnK;
            layerConfig.lrnFeaturePadding=param.lrnFeaturePadding;

            layerConfig.convOutputFeature=param.convOutputFeature;
            layerConfig.lrnPadddingSize=param.lrnPadddingSize;

            layerConfig.accumulateRightMem=false;

            layerConfig.inputMemZAdapterActive=param.inputMemZAdapterActive;

            layerConfig.convTileSizeMinusOne=layerConfig.convTileSize(1:5)-1;
            layerConfig.convTileSizeMinusTwo=layerConfig.convTileSize(1:5)-2;
            layerConfig.convOpSizePlusPaddingSizeMinusOne=layerConfig.convOpSize-layerConfig.paddingMode-1;
            layerConfig.convImgSizeMinusOne=layerConfig.convImgSize-1;
            layerConfig.convImgSizeMinusOpSizePlusTwoPaddingSize=layerConfig.convImgSize-layerConfig.convOpSize+2*layerConfig.paddingMode;
            layerConfig.smallPoolLayerEn=param.smallLayerEn;


            layerConfig.IndexActsSelectorOffsetInit=0;
            layerConfig.IndexActsDimensionalOffsetsInit=zeros(1,3);

            layerConfig.isMaxpoolIndexLeg=(param.maxpoolType==1);
            layerConfig.fullFeatureSize=0;
            layerConfig.fullColumnsSize=0;





            layerConfig.weightBaseAddrOffset=param.weightBaseAddrOffset;
            layerConfig.nextTileOffset=0;

            lc=dnnfpga.processorbase.conv2Processor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveAveragepoolLayerConfigConv2(param,chipConfig)
            layerConfig.activeFIFOEn=false;
            layerConfig.activeFIFOMemSel=false;
            inputFeatureNum=param.inputFeatureNum;
            origImgSize=param.origImgSize;
            origOpSizeValue=param.origOpSizeValue;

            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;
                layerConfig.int32ToInt8Exp=0;


                layerConfig.avgpoolMultiplier=1/(origOpSizeValue(1)*origOpSizeValue(2));
            else
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;
                layerConfig.int32ToInt8Exp=-param.rescaleExp;
                layerConfig.avgpoolMultiplier=param.avgMultiplier;
            end

            layerConfig.memDirection=param.memDirection;
            layerConfig.convMode=3;
            layerConfig.strideMode=param.strideMode;
            layerConfig.reLUMode=false;
            if isfield(param,'reLUValue')
                layerConfig.convReLUValue=param.reLUValue;
            else
                layerConfig.convReLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.paddingMode=0;
            layerConfig.halfInputFeatureNum=0;
            layerConfig.halfOutputFeatureNum=0;
            superConvolutionSize=ones(6,1);
            superConvolutionSize(1)=1;
            superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)=ceil(inputFeatureNum/chipConfig.threadNumLimit);
            superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=1;

            superConvolutionSize(chipConfig.ControlLogicTileXAddrIdx:chipConfig.ControlLogicTileYAddrIdx)=ceil(origOpSizeValue(1:2)./chipConfig.opSize(1:2));
            layerConfig.convTileSize=superConvolutionSize;
            layerConfig.convTileThreadExpansionSize=[1;superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx);1];
            layerConfig.convImgSize=origImgSize;
            layerConfig.convOpSize=origOpSizeValue;
            layerConfig.leftMemSize=[inputFeatureNum;origImgSize(1:2)];

            layerConfig.stride=param.strideMode;
            layerConfig.padding=param.paddingMode;
            layerConfig.dilation=param.dilationMode;
            [resultSize,resultSizeDivByOpW,imgSizeDivByOpW,xy0,rxy0,...
            wAddr0,dw,dr,dz,rzLimitOriginal]=...
            dnnfpga.processorbase.initCtrlData(...
            layerConfig.padding,layerConfig.stride,param.stridePhase,...
            layerConfig.dilation,param.origImgSize(1:2),...
            param.origOpSizeValue,chipConfig.wSizeLimit,chipConfig.opW);
            if(isempty(param.firstWritePos))
                layerConfig.firstWritePos=[0;resultSize(1);0;resultSize(2)];
            else
                layerConfig.firstWritePos=param.firstWritePos;
            end
            if(isempty(param.finalWriteSize))
                layerConfig.finalWriteSize=resultSize;
            else
                layerConfig.finalWriteSize=param.finalWriteSize;
            end
            layerConfig.resultSize=resultSize;
            layerConfig.resultSizeDivByOpW=resultSizeDivByOpW;
            layerConfig.resultSizeDivByOpWSquared=prod(resultSizeDivByOpW);
            layerConfig.imgSize=origImgSize(1:2);
            layerConfig.imgSizeDivByOpW=imgSizeDivByOpW;
            layerConfig.imgSizeDivByOpWSquared=prod(imgSizeDivByOpW);
            layerConfig.xy0=xy0;
            layerConfig.rxy0=rxy0;
            layerConfig.wAddr0=0;
            layerConfig.dw=dw;
            layerConfig.dr=dr;
            layerConfig.dz=dz;
            layerConfig.rzLimitOriginal=rzLimitOriginal;

            layerConfig.rightMemSize=[inputFeatureNum;resultSize];
            lps=mod(-resultSize,chipConfig.opSize(1:2));
            param.lrnPadddingSize(1:2)=lps(1:2);
            param.lrnPadddingSize(3)=mod(-param.outputFeatureNum,chipConfig.threadNumLimit);
            param.convOutputFeature=param.outputFeatureNum;
            layerConfig.lrnLocalSize=param.lrnLocalSize;
            layerConfig.lrnAlpha=param.lrnAlpha;
            layerConfig.lrnBeta=param.lrnBeta;
            layerConfig.lrnK=param.lrnK;
            layerConfig.lrnFeaturePadding=param.lrnFeaturePadding;

            layerConfig.convOutputFeature=param.convOutputFeature;
            layerConfig.lrnPadddingSize=param.lrnPadddingSize;

            layerConfig.accumulateRightMem=false;

            layerConfig.inputMemZAdapterActive=param.inputMemZAdapterActive;

            layerConfig.convTileSizeMinusOne=layerConfig.convTileSize(1:5)-1;
            layerConfig.convTileSizeMinusTwo=layerConfig.convTileSize(1:5)-2;
            layerConfig.convOpSizePlusPaddingSizeMinusOne=layerConfig.convOpSize-layerConfig.paddingMode-1;
            layerConfig.convImgSizeMinusOne=layerConfig.convImgSize-1;
            layerConfig.convImgSizeMinusOpSizePlusTwoPaddingSize=layerConfig.convImgSize-layerConfig.convOpSize+2*layerConfig.paddingMode;
            layerConfig.smallPoolLayerEn=param.smallLayerEn;


            layerConfig.IndexActsSelectorOffsetInit=0;
            layerConfig.IndexActsDimensionalOffsetsInit=zeros(1,3);

            layerConfig.isMaxpoolIndexLeg=0;
            layerConfig.fullFeatureSize=0;
            layerConfig.fullColumnsSize=0;





            layerConfig.weightBaseAddrOffset=param.weightBaseAddrOffset;
            layerConfig.nextTileOffset=0;

            lc=dnnfpga.processorbase.conv2Processor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveUnpoolLayerConfigConv2(param,chipConfig)
            layerConfig.activeFIFOEn=false;
            layerConfig.activeFIFOMemSel=false;
            inputFeatureNum=param.inputFeatureNum;
            origImgSize=param.origImgSize;
            origOpSizeValue=param.origOpSizeValue;

            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;
                layerConfig.int32ToInt8Exp=0;
            else
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;
                layerConfig.int32ToInt8Exp=-param.rescaleExp;
            end


            layerConfig.avgpoolMultiplier=1;
            layerConfig.memDirection=param.memDirection;
            if(strcmp(param.type,'FPGA_TransposedConv'))
                layerConfig.convMode=7;
            else
                layerConfig.convMode=6;
            end
            layerConfig.strideMode=param.strideMode;

            layerConfig.reLUMode=param.reLUMode;
            if isfield(param,'reLUValue')
                layerConfig.convReLUValue=param.reLUValue;
            else
                layerConfig.convReLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.paddingMode=param.paddingMode(1);
            layerConfig.halfInputFeatureNum=0;
            layerConfig.halfOutputFeatureNum=0;
            superConvolutionSize=ones(6,1);
            superConvolutionSize(1)=1;
            unpoolRemainderInput=ceil(param.unpoolRemainder./param.origOpSizeValue(1:2));
            superConvolutionSize(chipConfig.ControlLogicTileXAddrIdx)=origImgSize(1)+unpoolRemainderInput(1);
            superConvolutionSize(chipConfig.ControlLogicTileYAddrIdx)=ceil((origImgSize(2)+unpoolRemainderInput(2))./chipConfig.convIndexActsBurstLength);
            superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)=ceil(inputFeatureNum/chipConfig.threadNumLimit);
            superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=1;
            layerConfig.convTileSize=superConvolutionSize;
            layerConfig.convTileThreadExpansionSize=[1;superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx);1];
            layerConfig.convImgSize=origImgSize;
            layerConfig.convOpSize=origOpSizeValue;
            layerConfig.leftMemSize=[inputFeatureNum;origImgSize(1:2)];
            layerConfig.stride=param.strideMode;
            layerConfig.padding=zeros([4,1]);
            layerConfig.dilation=param.dilationMode(1);
            [resultSize,resultSizeDivByOpW,imgSizeDivByOpW,xy0,rxy0,...
            wAddr0,dw,dr,dz,rzLimitOriginal]=...
            dnnfpga.processorbase.initCtrlDataUnpool(...
            param.paddingMode,layerConfig.stride,param.stridePhase,...
            layerConfig.dilation,param.origImgSize(1:2),...
            param.origOpSizeValue,chipConfig.wSizeLimit,...
            chipConfig.opW,param.unpoolRemainder);
            if(isempty(param.firstWritePos))
                layerConfig.firstWritePos=[0;resultSize(1);0;resultSize(2)];
            else
                layerConfig.firstWritePos=param.firstWritePos;
            end
            if(isempty(param.finalWriteSize))
                layerConfig.finalWriteSize=resultSize;
            else
                layerConfig.finalWriteSize=param.finalWriteSize;
            end
            layerConfig.resultSize=resultSize;
            layerConfig.resultSizeDivByOpW=resultSizeDivByOpW;
            layerConfig.resultSizeDivByOpWSquared=prod(resultSizeDivByOpW);
            layerConfig.imgSize=origImgSize(1:2);
            layerConfig.imgSizeDivByOpW=imgSizeDivByOpW;
            layerConfig.imgSizeDivByOpWSquared=prod(imgSizeDivByOpW);
            layerConfig.xy0=xy0;
            layerConfig.rxy0=rxy0;
            layerConfig.wAddr0=0;
            layerConfig.dw=dw;
            layerConfig.dr=dr;
            layerConfig.dz=dz;
            layerConfig.rzLimitOriginal=rzLimitOriginal;

            layerConfig.rightMemSize=[inputFeatureNum;resultSize];
            lps=mod(-resultSize,chipConfig.opSize(1:2));
            param.lrnPadddingSize(1:2)=lps(1:2);
            param.lrnPadddingSize(3)=mod(-param.outputFeatureNum,chipConfig.threadNumLimit);
            param.convOutputFeature=param.outputFeatureNum;
            layerConfig.lrnLocalSize=param.lrnLocalSize;
            layerConfig.lrnAlpha=param.lrnAlpha;
            layerConfig.lrnBeta=param.lrnBeta;
            layerConfig.lrnK=param.lrnK;
            layerConfig.lrnFeaturePadding=param.lrnFeaturePadding;

            layerConfig.convOutputFeature=param.convOutputFeature;
            layerConfig.lrnPadddingSize=param.lrnPadddingSize;

            layerConfig.accumulateRightMem=false;

            layerConfig.inputMemZAdapterActive=param.inputMemZAdapterActive;

            layerConfig.convTileSizeMinusOne=layerConfig.convTileSize(1:5)-1;
            layerConfig.convTileSizeMinusTwo=layerConfig.convTileSize(1:5)-2;
            layerConfig.convOpSizePlusPaddingSizeMinusOne=layerConfig.convOpSize-layerConfig.paddingMode-1;
            layerConfig.convImgSizeMinusOne=layerConfig.convImgSize-1;
            layerConfig.convImgSizeMinusOpSizePlusTwoPaddingSize=layerConfig.convImgSize-layerConfig.convOpSize+2*layerConfig.paddingMode;
            layerConfig.smallPoolLayerEn=param.smallLayerEn;

            layerConfig.isMaxpoolIndexLeg=0;

            opByteLength=chipConfig.opBitWidthLimit/8;
            ADDRESSSCALINGFACTOR=opByteLength*chipConfig.threadNumLimit;

            mpoolSize=floor(param.outputSize(1:2).'./param.origOpSizeValue(1:2));
            layerConfig.fullFeatureSize=prod(mpoolSize)*ADDRESSSCALINGFACTOR;
            layerConfig.fullColumnsSize=mpoolSize(2)*ADDRESSSCALINGFACTOR;












            layerConfig.IndexActsDimensionalOffsetsInit=zeros(1,3);

            layerConfig.IndexActsDimensionalOffsetsInit(1)=mod(mpoolSize(2)*chipConfig.threadNumLimit,chipConfig.opDDRRatio);

            layerConfig.IndexActsDimensionalOffsetsInit(2)=mod(chipConfig.convIndexActsBurstLength*chipConfig.threadNumLimit,chipConfig.opDDRRatio);

            layerConfig.IndexActsDimensionalOffsetsInit(3)=mod(prod(mpoolSize)*chipConfig.threadNumLimit,chipConfig.opDDRRatio);





            assert(mod(param.weightBaseAddrOffset,opByteLength)==0,'Most Unpool calculations will fail.')





            layerConfig.weightBaseAddrOffset=param.weightBaseAddrOffset+...
            (param.imageTilePos(1)*mpoolSize(2)+param.imageTilePos(3))*ADDRESSSCALINGFACTOR;
            layerConfig.nextTileOffset=((param.nextTilePos(1)-param.imageTilePos(1))*mpoolSize(2)...
            +(param.nextTilePos(3)-param.imageTilePos(3)))*ADDRESSSCALINGFACTOR;

            temp=layerConfig.weightBaseAddrOffset/opByteLength;
            temp=mod(temp,chipConfig.opDDRRatio);
            layerConfig.IndexActsSelectorOffsetInit=temp;

            lc=dnnfpga.processorbase.conv2Processor.typeLayerConfig(chipConfig,layerConfig);
        end

        function lc=resolveLrnConfigConv2(param,chipConfig)
            layerConfig.activeFIFOEn=false;
            layerConfig.activeFIFOMemSel=false;
            layerConfig.accumulateRightMem=false;
            inputFeatureNum=param.inputFeatureNum;
            origImgSize=param.origImgSize;
            param.lrnPadddingSize(3)=mod(-param.outputFeatureNum,chipConfig.threadNumLimit);
            param.convOutputFeature=param.outputFeatureNum;
            layerConfig.lrnLocalSize=param.lrnLocalSize;
            layerConfig.lrnAlpha=param.lrnAlpha;
            layerConfig.lrnBeta=param.lrnBeta;
            layerConfig.lrnK=param.lrnK;

            layerConfig.convOutputFeature=param.convOutputFeature;
            layerConfig.lrnFeaturePadding=param.convOutputFeature+param.lrnFeaturePadding+mod(-(param.lrnFeaturePadding+param.convOutputFeature),chipConfig.threadNumLimit);

            if(strcmp(chipConfig.kernelDataType,'single'))
                layerConfig.int8ToSingleExp=0;
                layerConfig.singleToInt8Exp=0;
                layerConfig.int32ToInt8Exp=0;
            else
                layerConfig.int8ToSingleExp=param.int8ToSingleExp;
                layerConfig.singleToInt8Exp=param.singleToInt8Exp;
                layerConfig.int32ToInt8Exp=-param.rescaleExp;
            end


            layerConfig.avgpoolMultiplier=1;
            layerConfig.memDirection=param.memDirection;
            layerConfig.convMode=2;
            layerConfig.strideMode=1;
            layerConfig.reLUMode=false;
            if isfield(param,'reLUValue')
                layerConfig.convReLUValue=param.reLUValue;
            else
                layerConfig.convReLUValue=0;
            end
            if isfield(param,'reLUScaleExp')
                layerConfig.reLUScaleExp=-param.reLUScaleExp;
            else
                layerConfig.reLUScaleExp=0;
            end
            layerConfig.paddingMode=0;


            if(param.outputFeatureNumToPadForSplit~=0)
                layerConfig.halfInputFeatureNum=(param.inputFeatureNum-param.outputFeatureNumToPadForSplit)/2;
                layerConfig.halfOutputFeatureNum=(param.outputFeatureNum)/2;
            else
                layerConfig.halfInputFeatureNum=param.inputFeatureNum;
                layerConfig.halfOutputFeatureNum=param.outputFeatureNum;
            end
            superConvolutionSize=ones(6,1);
            superConvolutionSize(1)=1;
            superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx)=ceil(inputFeatureNum/chipConfig.threadNumLimit);


            if(mod(param.convOutputFeature,chipConfig.threadNumLimit)==0)
                superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=ceil(layerConfig.convOutputFeature/chipConfig.threadNumLimit);
            else
                superConvolutionSize(chipConfig.ControlLogicOutputFeatureAddrIdx)=ceil(layerConfig.lrnFeaturePadding/chipConfig.threadNumLimit);
            end












            superConvolutionSize(chipConfig.ControlLogicTileXAddrIdx:chipConfig.ControlLogicTileYAddrIdx)=[1;1];
            layerConfig.convTileSize=superConvolutionSize;
            layerConfig.convTileThreadExpansionSize=[1;superConvolutionSize(chipConfig.ControlLogicInputFeatureAddrIdx);1];
            layerConfig.convImgSize=origImgSize;
            layerConfig.convOpSize=chipConfig.opSize;
            layerConfig.leftMemSize=[inputFeatureNum;origImgSize(1:2)];

            layerConfig.stride=layerConfig.strideMode;
            layerConfig.padding=[1;1;1;1];
            layerConfig.dilation=param.dilationMode;
            [resultSize,~,imgSizeDivByOpW,xy0,rxy0,~,dw,dr,dz,...
            rzLimitOriginal]=dnnfpga.processorbase.initCtrlData(...
            layerConfig.padding,layerConfig.stride,[0;0],...
            layerConfig.dilation,param.origImgSize(1:2),param.origOpSizeValue,...
            chipConfig.wSizeLimit,chipConfig.opW);
            if(isempty(param.firstWritePos))
                layerConfig.firstWritePos=[0;resultSize(1);0;resultSize(2)];
            else
                layerConfig.firstWritePos=param.firstWritePos;
            end
            if(isempty(param.finalWriteSize))
                layerConfig.finalWriteSize=resultSize;
            else
                layerConfig.finalWriteSize=param.finalWriteSize;
            end
            layerConfig.resultSize=origImgSize(1:2);
            layerConfig.resultSizeDivByOpW=imgSizeDivByOpW;
            layerConfig.resultSizeDivByOpWSquared=prod(imgSizeDivByOpW);
            layerConfig.imgSize=origImgSize(1:2);
            layerConfig.imgSizeDivByOpW=imgSizeDivByOpW;
            layerConfig.imgSizeDivByOpWSquared=prod(imgSizeDivByOpW);
            layerConfig.xy0=xy0;
            layerConfig.rxy0=rxy0;
            layerConfig.wAddr0=0;
            layerConfig.dw=dw;
            layerConfig.dr=dr;
            layerConfig.dz=dz;
            layerConfig.rzLimitOriginal=rzLimitOriginal;

            layerConfig.rightMemSize=[inputFeatureNum;resultSize];
            param.lrnPadddingSize(1:2)=mod(-(size(resultSize,1)),chipConfig.opSize(1));
            layerConfig.lrnPadddingSize=param.lrnPadddingSize;
            layerConfig.accumulateRightMem=false;

            layerConfig.inputMemZAdapterActive=param.inputMemZAdapterActive;

            layerConfig.convTileSizeMinusOne=layerConfig.convTileSize(1:5)-1;
            layerConfig.convTileSizeMinusTwo=layerConfig.convTileSize(1:5)-2;
            layerConfig.convOpSizePlusPaddingSizeMinusOne=layerConfig.convOpSize-layerConfig.paddingMode-1;
            layerConfig.convImgSizeMinusOne=layerConfig.convImgSize-1;
            layerConfig.convImgSizeMinusOpSizePlusTwoPaddingSize=layerConfig.convImgSize-layerConfig.convOpSize+2*layerConfig.paddingMode;
            layerConfig.smallPoolLayerEn=param.smallLayerEn;


            layerConfig.IndexActsSelectorOffsetInit=0;
            layerConfig.IndexActsDimensionalOffsetsInit=zeros(1,3);
            layerConfig.isMaxpoolIndexLeg=0;
            layerConfig.fullFeatureSize=0;
            layerConfig.fullColumnsSize=0;
            layerConfig.nextTileOffset=0;

            lc=dnnfpga.processorbase.conv2Processor.typeLayerConfig(chipConfig,layerConfig);
        end


        function param=padForSplit(param)
            if(param.inputFeatureNumToPadForSplit>0)
                param.inputFeatureNum=param.inputFeatureNum+param.inputFeatureNumToPadForSplit;
            end
            if(param.outputFeatureNumToPadForSplit>0)
                param.outputFeatureNum=param.outputFeatureNum+param.outputFeatureNumToPadForSplit;
            end
        end

    end
    methods(Static=true)


        function output=Unpool(~,input,outputSize)
            data=input{1};
            index=input{2};
            if~isinteger(index)
                index=single(index);
                index=reshape(typecast(index(:),'int32'),size(index));
            end
            output=zeros(outputSize,'like',data);
            for b=1:size(output,4)
                for c=1:size(output,3)
                    tmp=output(:,:,c,b);
                    tmp=tmp.';
                    tmp(index(:,:,c,b))=data(:,:,c,b);
                    tmp=tmp.';
                    output(:,:,c,b)=tmp;
                end
            end
        end


        function output=int8ToSingleConversion(param,input,int8ToSingleExp)
            outputMatrix=double(input)*2^(double(int8ToSingleExp));
            output=single(reshape(outputMatrix,size(input)));
        end



        function output=singleToInt8Conversion(param,input,singleToInt8Exp)
            utils=dlquantization.Utils;
            storedIntegers=utils.scale(single(input(:)),(singleToInt8Exp),false);
            qData=reshape(storedIntegers,size(input));
            output=qData;
        end
        function[output,exponents]=singleToInt8ConversionCW(param,input,wordLength)

            [numChannels,numGroups]=dnnfpga.processorbase.processorUtils.getNumChannels(input);

            if wordLength==8
                type='int8';
            else
                type='int32';
            end

            output=zeros(size(input),type);
            exponents=zeros(numChannels,1);
            for grp=0:numGroups-1
                for idx=1:numChannels

                    data=dnnfpga.processorbase.processorUtils.getInput(input,idx,grp);
                    minData=min(data(:));
                    maxData=max(data(:));

                    bfp=dlquantization.BlockFloatingPoint([minData,maxData],wordLength);

                    exponents(numChannels*grp+idx)=bfp.getExponent;

                    utils=dlquantization.Utils;
                    if wordLength==8
                        storedIntegers=utils.scale(single(data(:)),exponents(numChannels*grp+idx),false);
                    else
                        storedIntegers=utils.scaleToInt32(single(data(:)),exponents(numChannels*grp+idx),false);
                    end

                    qData=reshape(storedIntegers,size(data));

                    output=dnnfpga.processorbase.processorUtils.writeOutput(output,idx,grp,qData);
                end
            end
        end


        function data=getInput(input,idx,group)
            numdims=size(input);
            switch(numel(numdims))
            case 2
                data=input(idx,group+1);
            case 3
                data=input(:,idx,group+1);
            case 4
                data=input(:,:,idx,group+1);
            case 5
                data=input(:,:,:,idx,group+1);
            otherwise
                data=input;
                warning('getInput in otherwise branch');
            end
        end

        function[numChannels,numGroups]=getNumChannels(input)


            dimsInput=size(input);
            numChannels=dimsInput(end-1);
            numGroups=dimsInput(end);
        end


        function output=writeOutput(output,idx,group,qData)
            numdims=size(output);
            switch(numel(numdims))
            case 2
                output(idx,group+1)=qData;
            case 3
                output(:,idx,group+1)=qData;
            case 4
                output(:,:,idx,group+1)=qData;
            case 5
                output(:,:,:,idx,group+1)=qData;
            otherwise
                output=qData;
                warning('getoutput in otherwise branch');
            end
        end




        function output=singleToInt32Conversion(input,singleToInt32Exp)
            utils=dlquantization.Utils;
            if isscalar(singleToInt32Exp)
                storedIntegers=utils.scaleToInt32(single(input(:)),(singleToInt32Exp),false);
                qData=reshape(storedIntegers,size(input));
                output=qData;
            else
                if(isscalar(input))


                    numChannels=numel(singleToInt32Exp);
                    output=input;
                    for idx=1:numChannels
                        storedIntegers=utils.scaleToInt32(single(input),singleToInt32Exp(idx),false);

                        output=dnnfpga.processorbase.processorUtils.writeOutput(output,idx,0,storedIntegers);
                    end
                end
            end
        end



        function output=int32Toint8Conversion(param,input)

            utils=dlquantization.Utils;
            if isscalar(param.params{1}.rescaleExp)
                storedIntegers=utils.scale(int32(input(:)),(-param.params{1}.rescaleExp),false);
                qData=reshape(storedIntegers,size(input));
                output=qData;
            else



                dimsInput=size(input);
                numChannels=dimsInput(end);
                output=input;
                for idx=1:numChannels
                    data=input(:,:,idx);
                    storedIntegers=utils.scale(int32(data(:)),(-param.params{1}.rescaleExp(idx)),false);
                    qData=reshape(storedIntegers,size(data));
                    output(:,:,idx)=qData;
                end
            end
        end


        function output=sigmoidLayerPredict(param,input)
            output=1/(1+exp(-input));
        end

        function output=exponentialLayerPredict(param,input)
            output=exp(input);
        end








        function seqImg_temp2=generateCameraCompatibleImage(data)
            data=dnnfpga.processorbase.conv2Processor.makeInputSquare(data);


            temp2=data;
            temp=fi(temp2,0,32,0);
            tempD=bitshift(temp(:,:,3),-8);
            tempC=bitshift(temp(:,:,3),24);
            tempB=bitshift(temp(:,:,2),12);
            tempA=bitshift(temp(:,:,1),0);

            [w,h,~]=size(temp);

            formatted_imageA(:,:)=uint32(bitor(tempC,bitor(tempB,tempA)));
            formatted_imageB(:,:)=uint32(tempD);

            seqImg_tempA=reshape(formatted_imageA,1,w*h);
            seqImg_tempB=reshape(formatted_imageB,1,w*h);
            seqImg_temp2=uint32(zeros(1,w*h*2));

            for i=0:w*h-1
                seqImg_temp2(i*2+1)=seqImg_tempA(i+1);
                seqImg_temp2(i*2+1+1)=seqImg_tempB(i+1);
            end
        end

    end
end






