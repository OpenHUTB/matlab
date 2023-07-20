classdef ISLTestVisitor<handle&matlab.mixin.Heterogeneous




    methods(Abstract)
        preOrderVisit(h,testObj);
        postOrderVisit(h,testObj);
        results=getResults(h);
        b=stop(h,testObj);
    end
end
