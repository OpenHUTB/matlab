classdef TopLevelTestElements<alm.internal.sltest.ISLTestVisitor




    properties
        Depth=0;
        testObjs={};
    end

    methods
        function preOrderVisit(h,testObj)
            h.Depth=h.Depth+1;
            h.testObjs{end+1}=testObj;
        end

        function postOrderVisit(h,testObj)
            h.Depth=h.Depth-1;
        end

        function results=getResults(h)
            results=h.testObjs;
        end

        function b=stop(h,testObj)
            b=(h.Depth>1);
        end
    end
end
