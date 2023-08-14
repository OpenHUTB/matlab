classdef GlobalNonGroundNode<rf.internal.circuit.GlobalNode

    properties
PreviousGlobalNode
    end

    methods
        function obj=GlobalNonGroundNode(prevnode)
            obj@rf.internal.circuit.GlobalNode;
            obj.GlobalNodeNumber=1+prevnode.GlobalNodeNumber;
            obj.PreviousGlobalNode=prevnode;
            prevnode.NextGlobalNode=obj;
        end
    end

end