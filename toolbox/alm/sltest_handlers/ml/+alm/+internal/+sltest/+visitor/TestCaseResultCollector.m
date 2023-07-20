classdef TestCaseResultCollector<alm.internal.sltest.ISLTestVisitor





    properties
        TestCaseResultObjs=[];
    end

    methods

        function h=TestCaseResultCollector()
            h.TestCaseResultObjs=[];
        end

        function preOrderVisit(h,testObj)
            if strcmp(class(testObj),'sltest.testmanager.TestCaseResult')
                h.TestCaseResultObjs=[h.TestCaseResultObjs;testObj];
            end
        end

        function postOrderVisit(h,testObj)

        end

        function results=getResults(h)
            results=h.TestCaseResultObjs;
        end

        function b=stop(h,testObj)
            b=false;
        end
    end
end
