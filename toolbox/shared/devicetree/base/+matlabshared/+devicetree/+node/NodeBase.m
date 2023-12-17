classdef(Abstract)NodeBase<matlabshared.devicetree.util.Commentable&matlab.mixin.Heterogeneous

    properties(SetAccess=protected)
        Name string
    end


    methods
        function obj=NodeBase(name)
            obj.Name=name;
        end
    end


    methods(Hidden)
        function isRoot=isRootNode(~)
            isRoot=false;
        end


        function isAddressable=isAddressableNode(~)
            isAddressable=false;
        end


        function isAllowed=allowsParentNode(~)
            isAllowed=false;
        end
    end
end