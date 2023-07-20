







classdef AutomationRegionSection<vision.internal.uitools.NewToolStripSection

    properties
CurrentRegionToggleButton
WholeImageToggleButton
CustomRegionToggleButton
    end

    methods
        function this=AutomationRegionSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)

            automationRegionSectionTitle=vision.getMessage('vision:imageLabeler:AutomationRegion');
            automationRegionSectionTag='sectionAutomationRegion';

            this.Section=matlab.ui.internal.toolstrip.Section(automationRegionSectionTitle);
            this.Section.Tag=automationRegionSectionTag;
        end

        function layoutSection(this)

            this.addCurrentRegionToggleButton();
            this.addWholeImageToggleButton();
            this.addCustomRegionToggleButton();

            col=this.addColumn();
            col.add(this.CurrentRegionToggleButton);
            col.add(this.WholeImageToggleButton);
            col.add(this.CustomRegionToggleButton);

        end

        function addCurrentRegionToggleButton(this)

            icon=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','CurrentRegion_16.png');
            titleID='vision:imageLabeler:CurrentRegion';
            tag='btnCurrentRegion';
            this.CurrentRegionToggleButton=this.createToggleButton(icon,titleID,tag);
            toolTipID='vision:imageLabeler:SelectCurrentRegionTooltip';
            this.setToolTipText(this.CurrentRegionToggleButton,toolTipID);
        end

        function addWholeImageToggleButton(this)

            icon=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','WholeImage_16.png');
            titleID='vision:imageLabeler:WholeImage';
            tag='btnWholeImage';
            this.WholeImageToggleButton=this.createToggleButton(icon,titleID,tag);
            toolTipID='vision:imageLabeler:SelectWholeImageTooltip';
            this.setToolTipText(this.WholeImageToggleButton,toolTipID);
        end

        function addCustomRegionToggleButton(this)

            icon=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','CustomRegion_16.png');
            titleID='vision:imageLabeler:CustomRegion';
            tag='btnCustomRegion';
            this.CustomRegionToggleButton=this.createToggleButton(icon,titleID,tag);
            toolTipID='vision:imageLabeler:SelectCustomRegionTooltip';
            this.setToolTipText(this.CustomRegionToggleButton,toolTipID);
        end
    end
end