classdef nilFrontend<dnnfpga.compiler.abstractDNNCompilerStage



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=nilFrontend()
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end

    methods(Access=public)
        function output=doit(~,input,~)
            output=input;
        end
    end
end

