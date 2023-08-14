classdef isOutputUpdate


%#codegen
    methods(Static)
        function flag=do(className)
            coder.allowpcode('plain');
            coder.extrinsic('matlab.system.coder.isOutputUpdate.impl');
            flag=coder.const(matlab.system.coder.isOutputUpdate.impl(className));
        end

        function flag=impl(className)
            metaClass=meta.class.fromName(className);
            flag=metaClass.IsOutputUpdate;
        end
    end
end
