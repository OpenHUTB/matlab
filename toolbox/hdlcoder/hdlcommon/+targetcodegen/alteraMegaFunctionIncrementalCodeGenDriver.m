


classdef alteraMegaFunctionIncrementalCodeGenDriver<targetcodegen.miniIncrementalCodeGenDriver

    methods
        function this=alteraMegaFunctionIncrementalCodeGenDriver(varargin)
            this=this@targetcodegen.miniIncrementalCodeGenDriver(varargin{:});
        end
    end

    methods(Static)
        function optFileName=retrieveOptFileName(cmd)
            optFileName=regexp(cmd,'-f:"([^"]*)"','tokens','once');
            optFileName=optFileName{:};
        end

        function signature=filterSignature(signatureIn)
            signature=regexprep(signatureIn,'-f:"([^"]*)"','-f:"XXX.txt"');
        end
    end
end


