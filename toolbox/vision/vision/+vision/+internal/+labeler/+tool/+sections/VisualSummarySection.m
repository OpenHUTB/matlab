





classdef VisualSummarySection<vision.internal.uitools.NewToolStripSection
    properties
VisualSummaryButton
    end

    methods
        function this=VisualSummarySection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)

            visualSummarySectionTitle=getString(message('vision:labeler:VisualSummarySection'));
            visualSummarySectionTag='sectionVisualSummary';

            this.Section=matlab.ui.internal.toolstrip.Section(visualSummarySectionTitle);
            this.Section.Tag=visualSummarySectionTag;
        end

        function layoutSection(this)

            this.addVisualSummaryButton();

            col=this.addColumn();
            col.add(this.VisualSummaryButton);
        end

        function addVisualSummaryButton(this)

            icon=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','VisualSummary.png');
            titleID='vision:labeler:VisualSummary';
            tag='btnVisualSummary';
            this.VisualSummaryButton=this.createButton(icon,titleID,tag);
            this.VisualSummaryButton.Enabled=true;
            toolTipID='vision:labeler:VisualSummaryButtonToolTip';
            this.setToolTipText(this.VisualSummaryButton,toolTipID);
        end
    end
end
