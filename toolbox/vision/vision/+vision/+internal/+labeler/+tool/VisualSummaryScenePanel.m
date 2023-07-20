


classdef VisualSummaryScenePanel<vision.internal.labeler.tool.ScrollableList
    methods
        function this=VisualSummaryScenePanel(parent,position)
            itemFactory=vision.internal.labeler.tool.VisualSummaryItemFactory();

            this=this@vision.internal.labeler.tool.ScrollableList(...
            parent,position,itemFactory);
        end

        function setBorder(this)
            this.FixedPanel.BorderType='line';
            this.FixedPanel.HighlightColor='k';

            this.FixedPanel.Tag='SceneLabelPanel';
        end

        function deleteScenePanel(this)
            delete(this.MovingPanel);
            delete(this.FixedPanel);
            this.Figure.WindowScrollWheelFcn=[];
            this.Figure.WindowKeyPressFcn=[];
        end

        function setScrollPanelCallback(this)
            this.Figure.WindowScrollWheelFcn=@this.mouseScroll;
            this.Figure.WindowKeyPressFcn=@this.keyboardScroll;
        end

        function hidePanel(this)
            set(this.MovingPanel,'Visible','off');
            set(this.FixedPanel,'Visible','off');
        end
    end
end
