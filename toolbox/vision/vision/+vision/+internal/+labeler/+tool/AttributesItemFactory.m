
classdef AttributesItemFactory<vision.internal.labeler.tool.ListItemFactory
    methods(Static)
        function item=create(parent,idx,data)
            item=vision.internal.labeler.tool.AttributesItem(parent,idx,data);
        end
    end
end