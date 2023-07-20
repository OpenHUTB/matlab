classdef customizesPropagation


%#codegen
    methods(Static)
        function flag=do(className)
            coder.allowpcode('plain');
            coder.extrinsic('matlab.system.coder.customizesPropagation.impl');

            flag=coder.const(matlab.system.coder.customizesPropagation.impl(className));
        end

        function flag=customizesPropagationImpl(className)
            metaClass=meta.class.fromName(className);
            flag=metaClass.CustomizesPropagation;
        end
    end
end
