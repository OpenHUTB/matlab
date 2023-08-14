classdef fixedPointTransformChain<dnnfpga.compiler.abstractDNNCompilerStage




    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=fixedPointTransformChain()
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end

    methods(Access=public)
        function output=doit(~,input,processor,varargin)
            deployableLayerParams=input;

            if(~isempty(processor.getConvProcessor()))
                deployableLayerParams=dnnfpga.compiler.compilerUtils.resolvePaddingForSplitForConv(deployableLayerParams,processor.getConvProcessor());
                deployableLayerParams=dnnfpga.compiler.cosimTransformChain.consolidateConvLayers(deployableLayerParams,processor);
            end
            dataType=dnnfpga.compiler.processorKernelType(processor);

            validQuantDataTypes={'int4','int8'};
            if(any(strcmpi(dataType.dataTypeConv,validQuantDataTypes))||any(strcmpi(dataType.dataTypeFC,validQuantDataTypes)))
                deployableLayerParams=dnnfpga.compiler.fixedPointTransformChain.InsertBFPScalingModule(deployableLayerParams,dataType);
            end
            deployableLayerParams=dnnfpga.compiler.fixedPointTransformChain.scheduleDeployableLayers(deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.cosimTransformChain.insertFPGA2SNLayer(deployableLayerParams);

            output=deployableLayerParams;
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
                    case{'FPGA_Conv2D','FPGA_Maxpool2D','FPGA_Avgpool2D','FPGA_FC','FPGA_GAP2D','FPGA_Lrn2D','FPGA_ConvND','FPGA_TransposedConv'}
                        deployableLayerParams{end+1}=dnnfpga.compiler.fixedPointTransformChain.getDepolyablelayerParams(['SW_Emulation_',layerType],{param});
                        state=0;
                    case 'SW_SeriesNetwork'
                        deployableLayerParams{end+1}=dnnfpga.compiler.fixedPointTransformChain.getDepolyablelayerParams('SW_SeriesNetwork',{param});
                        state=0;
                    case 'SW_Emulation_Scaling'
                        deployableLayerParams{end+1}=dnnfpga.compiler.fixedPointTransformChain.getDepolyablelayerParams('SW_Emulation_Scaling',{param});
                        state=0;
                    case 'SW_Emulation_Rescaling'
                        deployableLayerParams{end+1}=dnnfpga.compiler.fixedPointTransformChain.getDepolyablelayerParams('SW_Emulation_Rescaling',{param});
                        state=0;
                    case 'SW_Emulation_BFPScaling'
                        deployableLayerParams{end+1}=dnnfpga.compiler.fixedPointTransformChain.getDepolyablelayerParams('SW_Emulation_BFPScaling',{param});
                        state=0;
                    otherwise
                        assert(false,'Unexpected layers "%s"',layerType);
                    end
                otherwise
                    assert(false,'Unexpected state "%d"',state);
                end
            end
        end


        function dlp=getDepolyablelayerParams(type,params)
            dlp.type=type;
            dlp.params=params;
        end




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

                        param1=param;
                        param1.type='SW_Emulation_BFPScaling';
                        deployableLayerParams{end+1}=param;
                        deployableLayerParams{end+1}=param1;
                        state=0;

                    case{'FPGA_FC','FPGA_GAP2D'}
                        param1=param;
                        param1.type='SW_Emulation_BFPScaling';
                        deployableLayerParams{end+1}=param;
                        deployableLayerParams{end+1}=param1;
                        state=0;
                    case{'FPGA_Lrn2D'}
                        param1=param;
                        param1.type='SW_Emulation_Rescaling';
                        param1.quantToSingleExp=param1.ExpData;

                        param2=param;
                        param2.type='SW_Emulation_Scaling';
                        param2.singleToQuantExp=param.OutputExpData;

                        deployableLayerParams{end+1}=param1;
                        deployableLayerParams{end+1}=param;
                        deployableLayerParams{end+1}=param2;
                        state=0;
                    case{'SW_SeriesNetwork'}

                        if(strcmpi(param.internal_type,'SW_SeriesNetwork_Input'))
                            if(param.hasTrueInputLayer)
                                param1=param;
                                param1.type='SW_Emulation_Scaling';
                                param1.singleToQuantExp=param.OutputExpData;
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
                            param1.type='SW_Emulation_Rescaling';
                            param1.quantToSingleExp=param_prevLayer.OutputExpData;
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

