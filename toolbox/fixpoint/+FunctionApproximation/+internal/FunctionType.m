classdef FunctionType




    enumeration
SpecialFunctionHandle
GenericFunctionHandle
MathBlock
LUTBlock
SubSystem
GenericBlock
    end

    methods
        function flag=isBlock(this)
            flag=any(this==["MathBlock","LUTBlock","GenericBlock","SubSystem"]);
        end
    end
end
