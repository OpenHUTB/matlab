classdef SLTestTraverser<alm.internal.sltest.ITraverser

    methods

        function h=SLTestTraverser(visitor)
            h@alm.internal.sltest.ITraverser(visitor);
        end

        function traverseImpl(h,t)

            h.Visitor.preOrderVisit(t);

            switch class(t)
            case 'sltest.testmanager.TestFile'
                tss=t.getTestSuites();
                for i=1:numel(tss)
                    h.traverse(tss(i));
                end
            case 'sltest.testmanager.TestSuite'
                tss=t.getTestSuites();
                for i=1:numel(tss)
                    h.traverse(tss(i));
                end
                tcs=t.getTestCases();
                for i=1:numel(tcs)
                    h.traverse(tcs(i));
                end
            case 'sltest.testmanager.TestCase'
                tis=t.getIterations();
                for i=1:numel(tis)
                    h.traverse(tis(i));
                end
            otherwise

            end

            h.Visitor.postOrderVisit(t);

        end
    end
end
