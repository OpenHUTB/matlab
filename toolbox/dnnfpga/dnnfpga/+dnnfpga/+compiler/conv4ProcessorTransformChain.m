classdef conv4ProcessorTransformChain<dnnfpga.compiler.abstractDNNCompilerStage



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=conv4ProcessorTransformChain()
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end

    methods(Access=public)
        function output=doit(~,input,processor,varargin)
            cc=processor.getCC();
            dataType=dnnfpga.compiler.processorKernelType(processor);
            if(strcmpi(dataType.dataTypeConv,'int8')||strcmpi(dataType.dataTypeFC,'int8'))
                deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.InsertBFPScalingModule(input,dataType);
            else
                deployableLayerParams=input;
            end
            deployableLayerParams=dnnfpga.compiler.conv4ProcessorTransformChain.removeSNLayers(deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.conv4ProcessorTransformChain.resolvePaddingForSplit(deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.conv4ProcessorTransformChain.scheduleInsideDeployableLayers(deployableLayerParams,processor,varargin{:});
            deployableLayerParams=dnnfpga.compiler.conv4ProcessorTransformChain.activateZAdapter(deployableLayerParams,processor);
            output=deployableLayerParams;
        end
    end

    methods(Access=public,Static=true)
        function deployableLayerParams=scheduleInsideDeployableLayers(deployableLayerParams,convp,varargin)
            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.scheduleLayers(deployableLayerParams,convp);








            convInputBufferOffset=hex2dec('1D000000');
            convOutputBufferOffset=convInputBufferOffset+hex2dec('00D00000');

            DDRAddrA=convInputBufferOffset;
            DDRAddrB=convOutputBufferOffset;


            if(isfield(convp.getBCC().conv,'ConvDDRInputAddr'))
                DDRAddrA=convp.getBCC().conv.ConvDDRInputAddr;
            end
            if(isfield(convp.getBCC().conv,'ConvDDROutputAddr'))
                DDRAddrB=convp.getBCC().conv.ConvDDROutputAddr;
            end
            for i=1:length(deployableLayerParams)
                if true

                    deployableLayerParams{i}.DDRAddrA=DDRAddrA;
                    deployableLayerParams{i}.DDRAddrB=DDRAddrB;
                    tmpDDRAddr=DDRAddrA;
                    DDRAddrA=DDRAddrB;
                    DDRAddrB=tmpDDRAddr;
                end
            end
        end

        function deployableLayerParams=activateZAdapter(deployableLayerParams,processor)
            for j=1:length(deployableLayerParams)
                deployableLayerParams{j}.inputMemZAdapterActive=processor.inputMemZAdapterActivePred(deployableLayerParams{j});
            end
        end

        function deployableLayerParams=resolvePaddingForSplit(deployableLayerParams,processor)
            deployableLayerParams=dnnfpga.compiler.compilerUtils.resolvePaddingForSplitForConv(deployableLayerParams,processor);
        end

        function deployableLayerParams=removeSNLayers(inputLayerParams,~)
            deployableLayerParams={};
            state=0;
            for i=1:length(inputLayerParams)
                param=inputLayerParams{i};
                layerType=param.type;

                switch state
                case 0
                    switch layerType
                    case{'FPGA_Conv2D','FPGA_Maxpool2D','FPGA_Avgpool2D','FPGA_Lrn2D','FPGA_FC','FPGA_GAP2D','FPGA_ConvND',...
                        'FPGA_Softmax','FPGA_Sigmoid','FPGA_Exponential'}
                        deployableLayerParams{end+1}=param;
                        state=0;
                    case 'SW_SeriesNetwork'
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
end


