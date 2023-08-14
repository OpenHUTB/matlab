classdef Node<handle






    properties
NodeID
Info
Parent
    end
    methods
        function set.NodeID(thisNode,nodeid)
            if ischar(nodeid)
                thisNode.NodeID=nodeid;
            else
                pm_error('physmod:common:foundation:mli:util:node:InvalidNodeID');
            end
        end

        function set.Parent(thisNode,parentNode)
            if isa(parentNode,'pm.util.CompoundNode')
                thisNode.Parent=parentNode;
            else
                pm_error('physmod:common:foundation:mli:util:node:InvalidNodeParent');
            end
        end



    end
    methods(Sealed=true)
        function accept(thisNode,aVisitor)




            if(nargin==2)&&isa(aVisitor,'pm.util.Visitor')
                thisNode.accept_implementation(aVisitor);
            else
                pm_error('physmod:common:foundation:mli:util:node:InvalidVisitor');
            end
        end
    end

    methods(Abstract=true,Access=protected)


        accept_implementation(thisNode,aVisitor)
    end
end