classdef CommonSetupVisitor<pm.util.Visitor
























    properties
SLHandle
BlockSetupFunction
LibrarySetupFunction
    end
    methods
        function vis=CommonSetupVisitor(slHCont)
            vis=vis@pm.util.Visitor;
            if nargin==1
                vis.SLHandle=slHCont;
            end
        end

        function set.SLHandle(thisVis,slHCont)
            if isa(slHCont,'containers.Map')||isa(slHCont,'function_handle')
                thisVis.SLHandle=slHCont;
            elseif ischar(slHCont)
                thisVis.SLHandle=pm.util.function_handle(slHCont);
            else
                pm_error('sm:sli:commonsetupvisitor:InvalidMapOrFunction');
            end
        end

        function set.BlockSetupFunction(thisVis,bsuFunc)
            if isa(bsuFunc,'function_handle')
                thisVis.BlockSetupFunction=bsuFunc;
            elseif ischar(bsuFunc)
                thisVis.BlockSetupFunction=pm.util.function_handle(bsuFunc);
            else
                pm_error('sm:sli:commonsetupvisitor:InvalidBlkSetupFunction');
            end
        end

        function set.LibrarySetupFunction(thisVis,lsuFunc)
            if isa(lsuFunc,'function_handle')
                thisVis.LibrarySetupFunction=lsuFunc;
            elseif ischar(lsuFunc)
                thisVis.LibrarySetupFunction=pm.util.function_handle(lsuFunc);
            else
                pm_error('sm:sli:commonsetupvisitor:InvalidLibSetupFunction');
            end
        end

    end
    methods(Access=protected)
        function visit_simplenode_implementation(thisVisitor,aVisitableNode)
            blkHandle=thisVisitor.getHandle(aVisitableNode);
            if~isempty(thisVisitor.BlockSetupFunction)
                thisVisitor.BlockSetupFunction(blkHandle);
            end
        end

        function visit_compoundnode_implementation(thisVisitor,aVisitableNode)
            libHandle=thisVisitor.getHandle(aVisitableNode);
            if~isempty(thisVisitor.LibrarySetupFunction)
                thisVisitor.LibrarySetupFunction(libHandle);
            end
        end

        function slHandle=getHandle(thisVisitor,aVisitableNode)
            slHandle=thisVisitor.SLHandle(aVisitableNode.NodeID);
            if~ishandle(slHandle)
                pm_error('sm:sli:commonsetupvisitor:InvalidHandleReturned');
            end
        end
    end
end


