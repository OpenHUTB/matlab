classdef SLTestResultTraverser<alm.internal.sltest.ITraverser





    methods

        function h=SLTestResultTraverser(visitor)
            h@alm.internal.sltest.ITraverser(visitor);
        end

        function traverseImpl(h,t)

            h.Visitor.preOrderVisit(t);

            className=class(t);

            if strcmp(className,'sltest.testmanager.ResultSet')%#ok<STISA> do not use isa because inheritance

                tfrs=t.getTestFileResults();
                for i=1:numel(tfrs)
                    h.traverse(tfrs(i));
                end
            end

            if strcmp(className,'sltest.testmanager.ResultSet')||...
                strcmp(className,'sltest.testmanager.TestFileResult')||...
                strcmp(className,'sltest.testmanager.TestSuiteResult')%#ok<STISA> do not use isa because inheritance

                tsrs=t.getTestSuiteResults();
                for i=1:numel(tsrs)
                    h.traverse(tsrs(i));
                end

                tcrs=t.getTestCaseResults();
                for i=1:numel(tcrs)
                    h.traverse(tcrs(i));
                end

            end

            h.Visitor.postOrderVisit(t);

        end

    end
end
