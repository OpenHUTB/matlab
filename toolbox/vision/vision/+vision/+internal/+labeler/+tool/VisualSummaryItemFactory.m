

classdef VisualSummaryItemFactory<vision.internal.labeler.tool.ListItemFactory
    methods(Static)
        function item=create(parent,idx,data)
            item=vision.internal.labeler.tool.VisualSummaryItem(parent,idx,data);
        end
    end
end