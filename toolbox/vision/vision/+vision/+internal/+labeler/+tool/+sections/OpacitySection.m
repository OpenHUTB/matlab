





classdef OpacitySection<vision.internal.uitools.NewToolStripSection

    properties
PolygonOpacitySlider
PixelLabelOpacitySlider
PolygonSliderText
PixelLabelSliderText
OpacityLabel
    end

    methods
        function this=OpacitySection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=protected)
        function createSection(this)

            opacitySectionTitle=getString(message('vision:labeler:LabelOpacity'));
            opacitySectionTag='sectionOpacity';

            this.Section=matlab.ui.internal.toolstrip.Section(opacitySectionTitle);
            this.Section.Tag=opacitySectionTag;
        end

        function layoutSection(this)
            this.addPolygonOpacitySlider();
            this.addPixelLabelOpacitySlider();
            createLayout(this);
        end

        function createLayout(this)

            col=this.addColumn();
            col.add(this.createLabel('vision:labeler:Empty'));
            col.add(this.PolygonSliderText);
            col.add(this.PixelLabelSliderText);

            col2=this.addColumn('width',120,...
            'HorizontalAlignment','center');
            col2.add(this.OpacityLabel);
            col2.add(this.PolygonOpacitySlider);
            col2.add(this.PixelLabelOpacitySlider);

        end


        function addPolygonOpacitySlider(this)

            startVal=0;
            range=[0,100];
            tag='sliderOpacityPolygon';
            toolTipID='vision:labeler:PolygonOpacityToolTip';

            this.PolygonOpacitySlider=this.createSlider(range,startVal,tag,toolTipID);
            this.PolygonOpacitySlider.Ticks=0;

            polygonID='vision:labeler:Polygon';
            this.PolygonSliderText=this.createLabel(polygonID);

            sliderTitleId='vision:labeler:LabelOpacity';
            this.OpacityLabel=this.createLabel(sliderTitleId);

        end

        function addPixelLabelOpacitySlider(this)

            startVal=50;
            range=[0,100];
            tag='sliderOpacityPixel';
            toolTipID='vision:labeler:LabelOpacityTooltip';

            this.PixelLabelOpacitySlider=this.createSlider(range,startVal,tag,toolTipID);
            this.PixelLabelOpacitySlider.Ticks=0;

            pixelID='vision:labeler:Pixel';
            this.PixelLabelSliderText=this.createLabel(pixelID);

        end




    end
end

