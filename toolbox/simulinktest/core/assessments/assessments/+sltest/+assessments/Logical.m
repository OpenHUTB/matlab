


classdef Logical<int8
    enumeration
        Untested(-1)
        False(0)
        True(1)
    end

    methods(Hidden)
        function res=slTestResult(self)
            res=repmat(slTestResult.Untested,size(self));
            res(self=='True')=slTestResult.Pass;
            res(self=='False')=slTestResult.Fail;
        end
    end
end
