classdef conv4ProcessorBackend<dnnfpga.compiler.abstractDNNCompilerStage



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=conv4ProcessorBackend()
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end

    methods(Access=public)
        function output=doit(this,input,processor,varargin)
            deployableNW=this.constructDeployableNetwork(input,processor,varargin{:});
            output=deployableNW;
        end
    end

    methods(Access=protected)
        function deployableNW=constructDeployableNetwork(this,deployableLayerParams,cnnp,varargin)
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'verbose',0,@(x)(isa(x,'logical')));
            parse(p,varargin{:});
            verbose=p.Results.verbose;
            conv4Data=cnnp.backend(deployableLayerParams,verbose);
            layers{1}=dnnfpga.compiler.conv4ProcessorBackend.createFPGALayer(cnnp,conv4Data,deployableLayerParams);
            deployableNW=dnnfpga.deployablenetwork.deployableNetwork(layers);
        end
    end

    methods(Access=private,Static=true)

        function fl=createFPGALayer(cnnp,convData,params)
            initData=convData;
            forwardArgs.params=params;
            fl=dnnfpga.deployablenetwork.fpgaLayer('FPGA_CNN',cnnp,initData,forwardArgs);
        end






    end
end

