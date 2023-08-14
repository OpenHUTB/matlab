classdef ITraverser<handle&matlab.mixin.Heterogeneous




    properties(Access=protected)
        Visitor alm.internal.sltest.ISLTestVisitor;
    end

    methods(Abstract,Hidden)
        traverseImpl(obj);
    end

    methods
        function h=ITraverser(visitor)
            h.Visitor=visitor;
        end

        function results=run(h,testObj)
            h.traverse(testObj);
            results=h.getResults();
        end

        function traverse(h,testObj)

            if h.Visitor.stop(testObj)
                return;
            end

            h.traverseImpl(testObj);

        end

        function results=getResults(h)
            results=h.Visitor.getResults();
        end
    end
end
