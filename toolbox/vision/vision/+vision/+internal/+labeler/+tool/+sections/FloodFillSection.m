classdef FloodFillSection<vision.internal.uitools.NewToolStripSection




    properties
FloodFillButton
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('images'),'icons');
    end

    methods
        function this=FloodFillSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)
            floodFillSectionTitle=getString(message('vision:labeler:FloodFill'));
            floodFillSectionTag='sectionFloodFill';

            this.Section=matlab.ui.internal.toolstrip.Section(floodFillSectionTitle);
            this.Section.Tag=floodFillSectionTag;
        end

        function layoutSection(this)
            this.addFloodFillButton();

            colAddSession=this.addColumn();
            colAddSession.add(this.FloodFillButton);
        end

        function addFloodFillButton(this)
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;


            addFloodFillTitleId='vision:labeler:FloodFill';
            addFloodFillIcon=fullfile(this.IconPath,'FloodFill_Colored_24.png');
            addFloodFillTag='btnFloodFill';
            this.FloodFillButton=this.createToggleButton(addFloodFillIcon,...
            addFloodFillTitleId,addFloodFillTag);
            toolTipID='vision:labeler:FloodFillTooltip';
            this.setToolTipText(this.FloodFillButton,toolTipID);
        end
    end
end