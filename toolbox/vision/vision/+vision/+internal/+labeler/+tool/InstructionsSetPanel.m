
classdef InstructionsSetPanel<vision.internal.labeler.tool.ScrollableList

    methods

        function this=InstructionsSetPanel(parent,position)
            itemFactory=vision.internal.labeler.tool.InstructionsItemFactory();

            this=this@vision.internal.labeler.tool.ScrollableList(...
            parent,position,itemFactory);

        end

    end
end
