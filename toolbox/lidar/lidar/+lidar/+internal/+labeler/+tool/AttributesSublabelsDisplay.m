classdef AttributesSublabelsDisplay<vision.internal.labeler.tool.AttributesSublabelsDisplay




    methods(Access=public)

        function this=AttributesSublabelsDisplay(hFig)
            this=this@vision.internal.labeler.tool.AttributesSublabelsDisplay(hFig);
            this.Title=vision.getMessage('lidar:labeler:Attributes');
            this.Fig.Name=vision.getMessage('lidar:labeler:Attributes');
        end


        function computeUIcontrolPositions(this)
            figPos=getFigurePosInPixel(this);
            figW=figPos(3);
            figH=figPos(4);
            offset=6;

            x=offset;
            y=figH-offset-this.OffsetFromTop;
            w=max(0,figW-2*offset);
            h=this.OffsetFromTop;
            this.PanelDetailPos.Pixels=[x,y,w,h];
            this.PanelDetailPos.Norm=[x/figW,y/figH,w/figW,h/figH];


            x=offset;
            y=offset;
            w=max(0,figW-2*offset);
            h=(figH-2*offset-this.OffsetFromTop)-offset;
            h=max(0,h);
            this.AttribScrollPanelPos.Pixels=[x,y,w,h];
            this.AttribScrollPanelPos.Norm=[x/figW,y/figH,w/figW,h/figH];
        end


        function createSublabelsPanel(~)

        end


        function doPanelPositionUpdate(this)
            computeUIcontrolPositions(this);
            this.updatePanelDetailPosition(this.PanelDetailPos);

            this.AttributesScrollPanel.updatePosition(this.AttribScrollPanelPos);
            this.AttributesScrollPanel.update();
        end

        function deleteAllItems(this)
            this.AttributesScrollPanel.deleteAllItems();
        end


        function updateSublblInAttributesSublabelsPanel(~,~,~,~,~,~)

        end
    end

end
