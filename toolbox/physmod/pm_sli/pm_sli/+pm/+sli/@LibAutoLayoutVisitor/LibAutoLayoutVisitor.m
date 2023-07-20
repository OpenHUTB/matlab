classdef LibAutoLayoutVisitor<pm.util.Visitor


















    properties
SLHandle
LayoutFunction
    end
    methods
        function vis=LibAutoLayoutVisitor(slHCont,loFunc)
            vis=vis@pm.util.Visitor;
            switch(nargin)
            case 0
                vis.LayoutFunction=which('pm.sli.libautolayout');
            case 1
                vis.SLHandle=slHCont;
                vis.LayoutFunction=which('pm.sli.libautolayout');
            case 2
                vis.SLHandle=slHCont;
                vis.LayoutFunction=loFunc;
            end
        end

        function set.SLHandle(thisVis,slHCont)
            if isa(slHCont,'containers.Map')||isa(slHCont,'function_handle')
                thisVis.SLHandle=slHCont;
            elseif ischar(slHCont)
                thisVis.SLHandle=pm.util.function_handle(slHCont);
            else
                pm_error('physmod:pm_sli:sli:sllibautolayoutvisitor:InvalidMapOrFunction');
            end
        end

        function set.LayoutFunction(thisVis,loFunc)
            if isa(loFunc,'function_handle')
                thisVis.LayoutFunction=loFunc;
            elseif ischar(loFunc)
                thisVis.LayoutFunction=pm.util.function_handle(loFunc);
            else
                pm_error('physmod:pm_sli:sli:sllibautolayoutvisitor:InvalidLayoutFunction');
            end
        end
    end
    methods(Access=protected)
        function visit_simplenode_implementation(thisVisitor,aVisitableNode)

        end

        function visit_compoundnode_implementation(thisVisitor,aVisitableNode)
            libHandle=thisVisitor.SLHandle(aVisitableNode.NodeID);
            if ishandle(libHandle)
                thisVisitor.LayoutFunction(libHandle);
            else
                pm_error('physmod:pm_sli:sli:sllibautolayoutvisitor:InvalidHandleReturned');
            end
        end
    end
end