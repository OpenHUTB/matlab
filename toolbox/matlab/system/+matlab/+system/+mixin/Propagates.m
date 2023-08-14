classdef Propagates<handle








%#codegen
%#ok<*EMCLS>

    methods(Static,Access=private)
        function SysObjAllowPcode
            coder.allowpcode('plain');
        end
    end
end
