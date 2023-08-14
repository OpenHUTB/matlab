
classdef FrameLabelItemFactory<vision.internal.labeler.tool.ListItemFactory
    methods(Static)
        function item=create(parent,idx,data)
            if isa(data,'vision.internal.labeler.FrameLabel')
                item=vision.internal.labeler.tool.FrameLabelItem(parent,idx,data);
            else
                item=vision.internal.labeler.tool.GroupItem(parent,idx,data);
            end
        end
    end
end