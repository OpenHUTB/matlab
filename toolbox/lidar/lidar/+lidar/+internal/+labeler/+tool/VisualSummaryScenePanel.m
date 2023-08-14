classdef VisualSummaryScenePanel<vision.internal.labeler.tool.VisualSummaryScenePanel&vision.internal.labeler.tool.ScrollableList




    methods
        function this=VisualSummaryScenePanel(parent,position)
            itemFactory=lidar.internal.labeler.tool.VisualSummaryItemFactory();

            this=this@vision.internal.labeler.tool.ScrollableList(...
            parent,position,itemFactory);
        end
    end
end
