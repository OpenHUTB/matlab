classdef LabelOpacitySection<vision.internal.uitools.NewToolStripSection




    properties
OpacityLabel
OpacitySlider
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=LabelOpacitySection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)
            labelOpacitySectionTitle=getString(message('vision:labeler:LabelOpacity'));
            labelOpacitySectionTag='sectionLabelOpacity';

            this.Section=matlab.ui.internal.toolstrip.Section(labelOpacitySectionTitle);
            this.Section.Tag=labelOpacitySectionTag;
        end

        function layoutSection(this)
            this.addOpacitySlider();

            colAddSession=this.addColumn('width',120,...
            'HorizontalAlignment','center');
            colAddSession.add(this.OpacityLabel);
            colAddSession.add(this.OpacitySlider);
        end

        function addOpacitySlider(this)
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;


            sliderTitleId='vision:labeler:LabelOpacity';
            this.OpacityLabel=this.createLabel(sliderTitleId);
            toolTipID='vision:labeler:LabelOpacityTooltip';
            this.setToolTipText(this.OpacityLabel,toolTipID);


            opacityLabelTag='btnLabelOpacity';
            range=[0,100];
            startVal=50;
            this.OpacitySlider=this.createSlider(range,startVal,opacityLabelTag,toolTipID);
            this.OpacitySlider.Ticks=0;

        end
    end
end