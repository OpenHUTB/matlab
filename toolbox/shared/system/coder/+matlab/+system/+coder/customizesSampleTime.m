classdef customizesSampleTime


%#codegen
    methods(Static)
        function flag=do(className)
            coder.allowpcode('plain');
            coder.extrinsic('matlab.system.coder.customizesSampleTime.impl');

            flag=coder.const(matlab.system.coder.customizesSampleTime.impl(className));
        end

        function flag=impl(className)
            metaClass=meta.class.fromName(className);
            flag=metaClass.CustomizesSampleTime;
        end
    end
end
