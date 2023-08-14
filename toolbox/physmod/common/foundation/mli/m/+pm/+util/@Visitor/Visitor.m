classdef Visitor<handle




    properties
DiscriminateFcnHandle

    end
    methods
        function visit_compoundnode(thisVisitor,aVisitableNode)



            if~isa(aVisitableNode,'pm.util.CompoundNode')
                pm_error('physmod:common:foundation:mli:util:visitor:NodeNotCompound',class(aVisitableNode));
            end


            if thisVisitor.discriminate(aVisitableNode)


                thisVisitor.visit_compoundnode_implementation(aVisitableNode);
            end


            chlrn=aVisitableNode.getChildren;
            for idx=1:length(chlrn)
                chlrn{idx}.accept(thisVisitor);
            end
        end

        function visit_simplenode(thisVisitor,aVisitableNode)



            if isa(aVisitableNode,'pm.util.SimpleNode')
                if thisVisitor.discriminate(aVisitableNode)
                    thisVisitor.visit_simplenode_implementation(aVisitableNode);
                end
            else
                pm_error('physmod:common:foundation:mli:util:visitor:NodeNotSimple',class(aVisitableNode));
            end
        end

        function set.DiscriminateFcnHandle(thisVisitor,func)
            thisVisitor.DiscriminateFcnHandle=pm.util.function_handle(func);
        end
    end

    methods(Access=private)
        function doWork=discriminate(thisVisitor,aVisitableNode)


            doWork=true;
            if isa(thisVisitor.DiscriminateFcnHandle,'function_handle')
                doWork=thisVisitor.DiscriminateFcnHandle(aVisitableNode);
                if~islogical(doWork)
                    fcns=functions(thisVisitor.DiscriminateFcnHandle);
                    pm_error('physmod:common:foundation:mli:util:visitor:NonBooleanReturnType',fcns.file);
                end
            end
        end
    end

    methods(Abstract=true,Access=protected)
        visit_compoundnode_implementation(thisVisitor,aVisitableNode)
        visit_simplenode_implementation(thisVisitor,aVisitableNode)
    end
end