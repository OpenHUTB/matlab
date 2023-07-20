classdef PaintBrushSection<vision.internal.uitools.NewToolStripSection




    properties
PaintBrushButton
EraseButton
MarkerLabel
MarkerSlider
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=PaintBrushSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)
            paintBrushSectionTitle=getString(message('vision:labeler:PaintBrush'));
            paintBrushSectionTag='sectionPaintBrush';

            this.Section=matlab.ui.internal.toolstrip.Section(paintBrushSectionTitle);
            this.Section.Tag=paintBrushSectionTag;
        end

        function layoutSection(this)
            this.addPaintBrushButton();
            this.addEraseButton();
            this.addMarkerSlider();

            colAddSession=this.addColumn();
            colAddSession.add(this.PaintBrushButton);

            colAddSession=this.addColumn();
            colAddSession.add(this.EraseButton);

            colAddSession=this.addColumn('width',120,...
            'HorizontalAlignment','center');
            colAddSession.add(this.MarkerLabel);
            colAddSession.add(this.MarkerSlider);
        end

        function addPaintBrushButton(this)
            import matlab.ui.internal.toolstrip.*;


            addPaintBrushTitleId='vision:labeler:PaintBrush';
            addPaintBrushIcon=fullfile(this.IconPath,'brush_24.png');
            addPaintBrushTag='btnAddPaintBrush';
            this.PaintBrushButton=this.createToggleButton(addPaintBrushIcon,...
            addPaintBrushTitleId,addPaintBrushTag);
            toolTipID='vision:labeler:AddPaintBrushTooltip';
            this.setToolTipText(this.PaintBrushButton,toolTipID);
        end

        function addEraseButton(this)
            import matlab.ui.internal.toolstrip.*;


            addEraseTitleId='vision:labeler:Erase';
            addEraseIcon=fullfile(this.IconPath,'eraser_24.png');
            addEraseTag='btnErase';
            this.EraseButton=this.createToggleButton(addEraseIcon,...
            addEraseTitleId,addEraseTag);
            toolTipID='vision:labeler:EraseTooltip';
            this.setToolTipText(this.EraseButton,toolTipID);
        end

        function addMarkerSlider(this)
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;


            sliderTitleId='vision:labeler:MarkerSize';
            this.MarkerLabel=this.createLabel(sliderTitleId);
            toolTipID='vision:labeler:MarkerSizeTooltip';
            this.setToolTipText(this.MarkerLabel,toolTipID);


            sliderLabelTag='btnMarkerSlider';



            range=[0,100];
            startVal=50;
            this.MarkerSlider=this.createSlider(range,startVal,sliderLabelTag,toolTipID);
            this.MarkerSlider.Ticks=0;
        end
    end
end