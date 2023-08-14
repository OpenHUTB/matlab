classdef CompoundNode<pm.util.Node




    properties(SetAccess=protected,GetAccess=protected)
Children
    end

    methods

        function cnode=CompoundNode(nodeID)

            cnode.NodeID=nodeID;
            cnode.Children=containers.Map;
        end

        function addChild(thisNode,aChildNode)

            if isa(aChildNode,'pm.util.Node')



                thisNode.Children(aChildNode.NodeID)=aChildNode;
                aChildNode.Parent=thisNode;
            else
                pm_error('physmod:common:foundation:mli:util:compoundnode:InvalidChildNode');
            end
        end

        function chldrn=getChildren(thisNode)
            chldrn=thisNode.Children.values;
        end

        function child=getChild(thisNode,childID)
            if ischar(childID)
                if(thisNode.Children.isKey(childID))
                    child=thisNode.Children(childID);
                else
                    pm_warning('physmod:common:foundation:mli:util:compoundnode:ChildIDNotPresent',childID);
                    child=[];
                end
            else
                pm_error('physmod:common:foundation:mli:util:compoundnode:InvalidChildID');
            end
        end

        function removeChild(thisNode,childID)
            if ischar(childID)
                if(thisNode.Children.isKey(childID))
                    thisNode.Children.remove(childID);
                else
                    pm_warning('physmod:common:foundation:mli:util:compoundnode:ChildIDNotPresent',childID);
                end
            else
                pm_error('physmod:common:foundation:mli:util:compoundnode:InvalidChildID');
            end
        end
    end

    methods(Access=protected)

        function accept_implementation(thisNode,aVisitor)


            aVisitor.visit_compoundnode(thisNode);
        end

    end
end