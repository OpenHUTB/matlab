classdef abstractDNNCompilerStage



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=abstractDNNCompilerStage()
        end
    end

    methods(Access=public,Abstract=true)
        output=doit(this,input,processor)
    end
end

