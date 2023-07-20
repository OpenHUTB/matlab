classdef EvolutionTreeIterator<handle




    properties(Access=private)
VisitedNodes
        NodeStack(1,:)
    end

    methods
        function obj=EvolutionTreeIterator(rootEi)
            obj.VisitedNodes=containers.Map;
            obj.NodeStack=evolutions.internal.datautils.Stack(class(rootEi));
            obj.traverseSpine(rootEi);
        end
    end

    methods(Access=public)

        tf=hasCurrent(obj)

        ei=current(obj)

        next(obj)

    end

    methods(Access=private)

        child=getUnvisitedChild(obj,ei)

        traverseSpine(obj,ei)

    end

end
