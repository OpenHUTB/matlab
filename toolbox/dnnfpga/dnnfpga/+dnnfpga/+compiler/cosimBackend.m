classdef cosimBackend<dnnfpga.compiler.abstractDNNCompilerStage



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=cosimBackend()
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end

    methods(Access=public)
        function output=doit(~,input,processor)
            deployableNW=dnnfpga.compiler.cosimBackend.constructDeployableNetwork(input,processor);
            output=deployableNW;
        end
    end

    methods(Access=private,Static=true)



















        function deployableNW=constructDeployableNetwork(deployableLayerParams,cnnp)
            layers={};
            state=0;





            for i=1:length(deployableLayerParams)
                dlp=deployableLayerParams{i};
                layerType=dlp.type;

                switch state
                case 0
                    switch layerType
                    case{'SW_Cosim_FPGA_Conv2D','SW_Cosim_FPGA_Maxpool2D','SW_Cosim_FPGA_Avgpool2D','SW_Cosim_FPGA_Input','SW_Cosim_FPGA_Lrn2D','SW_Cosim_FPGA_ConvND','SW_Cosim_FPGA_TransposedConv'}
                        foo=@(input)(cnnp.getConvProcessor().cosim(dlp,input));
                        layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1},foo,dlp.params{1});
                        state=0;
                    case{'SW_Cosim_FPGA_FIFO'}
                        foo=@(input)(cnnp.getFIFO1Processor().cosim(dlp,input));
                        layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1},foo);
                        state=0;
                    case{'SW_Cosim_FPGA_FC','SW_Cosim_FPGA_GAP2D','SW_Cosim_FPGA_Output'}
                        foo=@(input)(cnnp.getFCProcessor().cosim(dlp,input));
                        layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1},foo,dlp.params{1});
                        state=0;
                    case{'SW_Cosim_BFPScaling','SW_Cosim_Rescaling','SW_Cosim_Scaling'}
                        foo=@(input)(dnnfpga.processorbase.processorUtils.cosim(dlp,input));
                        layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1},foo,dlp.params{1});
                        state=0;
                    case{'SW_Cosim_FPGA_InputP'}
                        foo=@(input)(cnnp.getInputProcessor().cosim(dlp,input));
                        layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1},foo);
                        state=0;
                    case{'SW_Cosim_FPGA_OutputP'}
                        foo=@(input)(cnnp.getOutputProcessor().cosim(dlp,input));
                        layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1},foo);
                        state=0;
                    case{'SW_FPGA2SeriesNetwork'}
                        foo=@(input)(reshape(input,[1,1,numel(input)]));
                        layers{end+1}=dnnfpga.deployablenetwork.swLayer('InputToFPGA',foo);
                        state=0;
                    case{'SW_SeriesNetwork'}
                        if(strcmpi(dlp.params{1}.internal_type,'SW_Sigmoid'))
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.processorbase.processorUtils.sigmoidLayerPredict(dlp.params{1}.snLayer,input)));
                        elseif(strcmpi(dlp.params{1}.internal_type,'SW_Exponential'))
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.processorbase.processorUtils.exponentialLayerPredict(dlp.params{1}.snLayer,input)));
                        else
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.compiler.compilerUtils.SNLayerPredict(dlp.params{1}.snLayer,input)));
                        end
                        state=0;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                otherwise
                    assert(false,'Unexpected state: %d',state);
                end
            end
            deployableNW=dnnfpga.deployablenetwork.deployableNetwork(layers);
        end
    end
end

