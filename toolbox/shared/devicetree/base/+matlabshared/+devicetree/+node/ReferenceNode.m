classdef ReferenceNode<matlabshared.devicetree.node.NonTerminalNode


    properties(Dependent,Access=protected)



HasLabelReference
    end

    methods
        function obj=ReferenceNode(name)
            matlabshared.devicetree.util.validateReferenceName(name);
            obj=obj@matlabshared.devicetree.node.NonTerminalNode(name);

            if startsWith(name,"&{")&&endsWith(name,"}")

            else


                obj.Label=extractAfter(name,1);
            end
        end
    end

    methods
        function hasLabelRef=get.HasLabelReference(obj)


            hasLabelRef=~isempty(obj.Label);
        end
    end

    methods(Hidden)
        function refName=getReferenceName(obj)


            refName=obj.Name;
        end

        function nodePath=getNodePath(obj)




            if obj.HasLabelReference
                error(message('devicetree:base:NoPathForLabel',obj.Name));
            end



            nodePath=extractBetween(obj.Name,"&{","}");
        end
    end


    methods(Access=protected)
        function hTargetNode=getOverlayTargetNode(obj)



            hTargetNode=obj;
        end

        function labelPrefix=getSourceLabelPrefix(~)



            labelPrefix="";






        end
    end
end