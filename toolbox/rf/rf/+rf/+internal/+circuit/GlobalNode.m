classdef GlobalNode<handle

    properties
MyLocalNodes
NextGlobalNode
GlobalNodeNumber
    end

    methods
        function obj=GlobalNode
            obj.MyLocalNodes=rf.internal.circuit.LocalNode.empty;
            obj.NextGlobalNode=rf.internal.circuit.GlobalNonGroundNode.empty;
        end
    end

end