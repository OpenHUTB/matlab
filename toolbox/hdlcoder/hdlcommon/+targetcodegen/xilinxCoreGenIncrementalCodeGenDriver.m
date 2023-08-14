


classdef xilinxCoreGenIncrementalCodeGenDriver<targetcodegen.miniIncrementalCodeGenDriver

    methods
        function this=xilinxCoreGenIncrementalCodeGenDriver(varargin)
            this=this@targetcodegen.miniIncrementalCodeGenDriver(varargin{:});
        end
    end

    methods(Static)
        function optFileName=retrieveOptFileName(cmd)
            optFileName=regexp(cmd,'-b\s+"([^"]*)"','tokens','once');
            optFileName=optFileName{:};
        end

        function signature=filterSignature(signatureIn)
            signature=regexprep(signatureIn,'-b\s+"([^"]*)"','-b "XXX.xco"');
            signature=regexprep(signature,'NEWPROJECT\s+"([^"]*)"','NEWPROJECT "YYY.cgp"');
        end
    end
end


