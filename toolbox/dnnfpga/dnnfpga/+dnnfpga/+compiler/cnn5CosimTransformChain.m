classdef cnn5CosimTransformChain<dnnfpga.compiler.abstractDNNCompilerStage



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=cnn5CosimTransformChain()
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end

    methods(Access=public)
        function output=doit(~,input,processor,varargin)
        end
    end

end

