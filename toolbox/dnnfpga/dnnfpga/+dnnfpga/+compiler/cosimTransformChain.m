classdef cosimTransformChain<dnnfpga.compiler.abstractDNNCompilerStage




    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=cosimTransformChain()
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end

    methods(Access=public)
        function output=doit(~,input,processor,varargin)
            deployableLayerParams=input;
            deployableLayerParams=dnnfpga.compiler.cosimTransformChain.consolidateInputLayer(deployableLayerParams,processor);
            if(~isempty(processor.getConvProcessor()))
                deployableLayerParams=dnnfpga.compiler.compilerUtils.resolvePaddingForSplitForConv(deployableLayerParams,processor.getConvProcessor());
                deployableLayerParams=dnnfpga.compiler.cosimTransformChain.consolidateConvLayers(deployableLayerParams,processor);
            end
            dataType=dnnfpga.compiler.processorKernelType(processor);
            if(strcmpi(dataType.dataTypeConv,'int8')||strcmpi(dataType.dataTypeFC,'int8'))
                deployableLayerParams=dnnfpga.compiler.cosimTransformChain.InsertBFPScalingModule(deployableLayerParams,dataType);
            end
            deployableLayerParams=dnnfpga.compiler.cosimTransformChain.scheduleDeployableLayers(deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.cosimTransformChain.insertFPGA2SNLayer(deployableLayerParams,processor);

            output=deployableLayerParams;
        end
    end

    methods(Access=private,Static=true)
        function fpgaParamLayers=consolidateInputLayer(fpgaParamLayers,~)
            state=0;
            for i=1:length(fpgaParamLayers)
                param=fpgaParamLayers{i};
                layerType=param.type;

                switch state
                case 0
                    switch layerType
                    case{'FPGA_Input'}
                        fpgaParamLayers{i}.outputFeatureNum=fpgaParamLayers{i}.inputFeatureNum;
                        state=0;
                    otherwise
                        state=0;
                    end
                otherwise
                    assert(false,'Unexpected state "%d"',state);
                end
            end
        end
    end

    methods(Access=public,Static=true)
        function fpgaParamLayers=consolidateConvLayers(fpgaParamLayers,processor)
            state=0;
            for i=1:length(fpgaParamLayers)
                param=fpgaParamLayers{i};
                layerType=param.type;

                switch state
                case 0
                    switch layerType
                    case{'FPGA_Conv2D','FPGA_Maxpool2D','FPGA_Input','FPGA_Lrn2D'}
                        if(isempty(param.finalWriteSize))
                            chipConfig=processor.getConvProcessor().getCC();






                            if(isfield(chipConfig,'wSizeLimit'))
                                resultSize=dnnfpga.processorbase.initCtrlData(param.paddingMode,param.strideMode,param.stridePhase,param.dilationMode,param.origImgSize(1:2),param.origOpSizeValue,chipConfig.wSizeLimit,chipConfig.opW);
                                fpgaParamLayers{i}.finalWriteSize=resultSize;
                            end
                        end
                        state=0;
                    otherwise
                        state=0;
                    end
                otherwise
                    assert(false,'Unexpected state "%d"',state);
                end
            end
        end
    end
    methods(Access=private,Static=true)
        function deployableLayerParams=scheduleDeployableLayers(fpgaParamLayers,~)
            deployableLayerParams={};
            state=0;
            for i=1:length(fpgaParamLayers)
                param=fpgaParamLayers{i};
                layerType=param.type;

                switch state
                case 0
                    switch layerType
                    case{'FPGA_Conv2D','FPGA_Maxpool2D','FPGA_Avgpool2D','FPGA_Input','FPGA_FC','FPGA_GAP2D','FPGA_FIFO','FPGA_Lrn2D','FPGA_Output','FPGA_InputP','FPGA_OutputP','FPGA_ConvND','FPGA_TransposedConv'}
                        deployableLayerParams{end+1}=dnnfpga.compiler.cosimTransformChain.getDepolyablelayerParams(['SW_Cosim_',layerType],{param});
                        state=0;
                    case 'SW_SeriesNetwork'
                        deployableLayerParams{end+1}=dnnfpga.compiler.cosimTransformChain.getDepolyablelayerParams('SW_SeriesNetwork',{param});
                        state=0;
                    case 'SW_Cosim_Scaling'
                        deployableLayerParams{end+1}=dnnfpga.compiler.cosimTransformChain.getDepolyablelayerParams('SW_Cosim_Scaling',{param});
                        state=0;
                    case 'SW_Cosim_Rescaling'
                        deployableLayerParams{end+1}=dnnfpga.compiler.cosimTransformChain.getDepolyablelayerParams('SW_Cosim_Rescaling',{param});
                        state=0;
                    case 'SW_Cosim_BFPScaling'
                        deployableLayerParams{end+1}=dnnfpga.compiler.cosimTransformChain.getDepolyablelayerParams('SW_Cosim_BFPScaling',{param});
                        state=0;
                    otherwise
                        assert(false,'Unexpected layers "%s"',layerType);
                    end
                otherwise
                    assert(false,'Unexpected state "%d"',state);
                end
            end
        end
    end
    methods(Access=public,Static=true)
        function deployableLayerParams=insertFPGA2SNLayer(deployableLayerParams,processor)

            if(~any(strcmp(cellfun(@(sas)sas.type,deployableLayerParams,'uni',false),{'SW_Cosim_FPGA_FC'})))
                deployableLayerParams=deployableLayerParams;
                return;
            end
            state=0;
            i=1;
            while(i<=length(deployableLayerParams))
                dlp=deployableLayerParams{i};
                layerType=dlp.type;

                switch state
                case 0
                    switch layerType
                    case 'SW_SeriesNetwork'
                        state=0;
                    otherwise
                        state=1;
                    end
                case 1
                    switch layerType
                    case 'SW_SeriesNetwork'

                        dlp=dnnfpga.compiler.cosimTransformChain.getDepolyablelayerParams('SW_FPGA2SeriesNetwork',{});
                        deployableLayerParams={deployableLayerParams{1:i-1},dlp,deployableLayerParams{i:end}};
                        i=i+1;
                        state=2;
                    otherwise
                        state=1;
                    end
                case 2
                    switch layerType
                    case 'SW_SeriesNetwork'
                        state=1;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                otherwise
                    assert(false,'Unexpected state "%d"',state);
                end
                i=i+1;
            end
        end

        function dlp=getDepolyablelayerParams(type,params)
            dlp.type=type;
            dlp.params=params;
        end
    end
    methods(Access=private,Static=true)



        function deployableLayerParams=InsertBFPScalingModule(fpgaParamLayers,dataType)





            deployableLayerParams={};


            finalRescalingDone=0;
            state=0;
            n=length(fpgaParamLayers);
            for i=1:n
                param=fpgaParamLayers{i};
                layerType=param.type;



                if(i>1)
                    param_prevLayer=fpgaParamLayers{i-1};
                end

                switch state
                case 0
                    switch layerType
                    case{'FPGA_Conv2D','FPGA_Maxpool2D','FPGA_Avgpool2D','FPGA_ConvND'}



                        if(strcmp(dnnfpgafeature('DLHDLTwoStepConversion'),'on'))
                            param1=param;
                            param2=param;

                            param1.type='SW_Cosim_Rescaling';

                            param2.type='SW_Cosim_Scaling';



                            param1.int8ToSingleExp=(param1.rescaleExp);
                            param2.singleToInt8Exp=param.OutputExpData;

                            deployableLayerParams{end+1}=param;
                            deployableLayerParams{end+1}=param1;
                            deployableLayerParams{end+1}=param2;
                        else




                            param1=param;
                            param1.type='SW_Cosim_BFPScaling';
                            NextLayerExp=param.OutputExpData;

                            param1.rescaleExp=(param1.rescaleExp)-(NextLayerExp);
                            deployableLayerParams{end+1}=param;
                            deployableLayerParams{end+1}=param1;
                        end
                        state=0;

                    case{'FPGA_FC','FPGA_GAP2D'}
                        if(strcmpi(dataType.dataTypeFC,'single'))



                            if(finalRescalingDone)
                                deployableLayerParams{end+1}=param;
                                continue;
                            end
                            if(strcmp(dnnfpgafeature('DLHDLTwoStepConversion'),'on'))
                                param1=deployableLayerParams{end};


                                if(strcmp(param1.type,'SW_Cosim_Scaling'))
                                    deployableLayerParams{end}=param;
                                    finalRescalingDone=1;
                                    continue;
                                end
                            end
                            param1=param;
                            param1.type='SW_Cosim_Rescaling';
                            param1.int8ToSingleExp=param1.ExpData;
                            deployableLayerParams{end+1}=param1;
                            deployableLayerParams{end+1}=param;
                            finalRescalingDone=1;
                            continue;
                        end




                        if(strcmp(dnnfpgafeature('DLHDLTwoStepConversion'),'on'))
                            param1=param;
                            param2=param;

                            param1.type='SW_Cosim_Rescaling';

                            param2.type='SW_Cosim_Scaling';



                            param1.int8ToSingleExp=(param1.rescaleExp);
                            param2.singleToInt8Exp=param.OutputExpData;

                            deployableLayerParams{end+1}=param;
                            deployableLayerParams{end+1}=param1;
                            deployableLayerParams{end+1}=param2;
                        else




                            param1=param;
                            param1.type='SW_Cosim_BFPScaling';
                            NextLayerExp=param.OutputExpData;

                            param1.rescaleExp=(param1.rescaleExp)-(NextLayerExp);
                            deployableLayerParams{end+1}=param;
                            deployableLayerParams{end+1}=param1;
                        end
                        state=0;
                    case{'FPGA_Lrn2D'}





                        param1=param;
                        param1.type='SW_Cosim_Rescaling';
                        param1.int8ToSingleExp=param1.ExpData;

                        param2=param;
                        param2.type='SW_Cosim_Scaling';
                        param2.singleToInt8Exp=param.OutputExpData;

                        deployableLayerParams{end+1}=param1;
                        deployableLayerParams{end+1}=param;
                        deployableLayerParams{end+1}=param2;
                        state=0;
                    case{'SW_SeriesNetwork'}

                        if(strcmpi(param.internal_type,'SW_SeriesNetwork_Input'))




                            if(param.hasTrueInputLayer)
                                param1=param;
                                param1.type='SW_Cosim_Scaling';
                                param1.singleToInt8Exp=param.OutputExpData;
                                deployableLayerParams{end+1}=param;
                                deployableLayerParams{end+1}=param1;
                            else

                                deployableLayerParams{end+1}=param;
                            end
                            state=0;
                            continue;
                        end




                        if(finalRescalingDone)
                            deployableLayerParams{end+1}=param;
                            continue;
                        end
                        if(param.hasTrueOutputLayer)
                            param1=param;
                            param1.type='SW_Cosim_Rescaling';
                            param1.int8ToSingleExp=param_prevLayer.OutputExpData;
                            deployableLayerParams{end+1}=param1;
                            deployableLayerParams{end+1}=param;
                        end
                        finalRescalingDone=1;
                        state=0;
                    otherwise
                        deployableLayerParams{end+1}=param;
                        state=0;
                    end
                otherwise
                    assert(false,'Unexpected state "%d"',state);
                end
            end
        end

    end
end

