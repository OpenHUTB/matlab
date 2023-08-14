
classdef ROILabelItemFactory<vision.internal.labeler.tool.ListItemFactory




    methods(Static)
        function item=create(parent,idx,data)
            if isa(data,'lidar.internal.labeler.ROILabel')
                item=lidar.internal.labeler.tool.ROILabelItem(parent,idx,data);
            else
                item=vision.internal.labeler.tool.GroupItem(parent,idx,data);
            end
        end
    end
end
