classdef SampleTime<handle







%#codegen
    methods(Static,Access=private)
        function SysObjAllowPcode
            coder.allowpcode('plain');
        end
    end
end
