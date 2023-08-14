classdef LabelSetDisplay<vision.internal.labeler.tool.LabelSetDisplay




    methods(Access=protected)
        function itemType=findItemType(this,index)
            if isa(this.LabelSetPanel.Items{index},'vision.internal.labeler.tool.GroupItem')
                itemType=vision.internal.labeler.tool.ItemType.Group;
            elseif(isa(this.LabelSetPanel.Items{index}.Data,'lidar.internal.labeler.ROILabel')||...
                isa(this.LabelSetPanel.Items{index}.Data,'vision.internal.labeler.FrameLabel'))
                itemType=vision.internal.labeler.tool.ItemType.Label;
            else
                itemType=vision.internal.labeler.tool.ItemType.Label;
            end
        end
    end
end
