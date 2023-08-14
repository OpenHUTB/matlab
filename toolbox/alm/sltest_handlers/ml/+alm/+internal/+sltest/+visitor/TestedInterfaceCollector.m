classdef TestedInterfaceCollector<alm.internal.sltest.ISLTestVisitor





    properties
        Interfaces containers.Map;
    end

    methods

        function h=TestedInterfaceCollector()
            h.Interfaces=containers.Map();
        end

        function preOrderVisit(h,t)
            if strcmp(class(t),'sltest.testmanager.TestCaseResult')
                if~isempty(t.getTestCase().getProperty('model'))
                    h.Interfaces(t.getTestCase().getProperty('model'))=0;
                end
            end
        end

        function postOrderVisit(h,testObj)

        end

        function results=getResults(h)
            results=h.Interfaces.keys();
        end

        function b=stop(h,testObj)
            b=false;
        end
    end
end
