classdef isWrappedSFunObject




%#codegen
    methods(Static)
        function out=do(className)
            coder.allowpcode('plain');
            coder.extrinsic('matlab.system.coder.isWrappedSFunObject.impl');
            out=coder.const(matlab.system.coder.isWrappedSFunObject.impl(className));
        end

        function out=impl(className)
            out=strncmp(className,'dspcodegen.',11)||...
            strncmp(className,'visioncodegen.',14)||...
            strncmp(className,'commcodegen.',12);

            if out&&exist(className)~=8 %#ok<EXIST>
                out=false;
            end
        end
    end
end
