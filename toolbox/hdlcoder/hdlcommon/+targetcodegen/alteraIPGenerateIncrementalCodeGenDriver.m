


classdef alteraIPGenerateIncrementalCodeGenDriver<targetcodegen.miniIncrementalCodeGenDriver

    methods
        function this=alteraIPGenerateIncrementalCodeGenDriver(varargin)
            this=this@targetcodegen.miniIncrementalCodeGenDriver(varargin{:});
        end
    end

    methods(Static)
        function optFileName=retrieveOptFileName(~)
            optFileName='';
        end

        function signature=filterSignature(signatureIn)
            signature=signatureIn;
        end
    end
end


