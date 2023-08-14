classdef FreehandSection<vision.internal.uitools.NewToolStripSection




    properties
AssistedFreehandButton
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=FreehandSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)
            freehandSectionTitle=getString(message('vision:labeler:Freehand'));
            freehandSectionTag='sectionFreehand';

            this.Section=matlab.ui.internal.toolstrip.Section(freehandSectionTitle);
            this.Section.Tag=freehandSectionTag;
        end

        function layoutSection(this)

            this.addAssistedFreehandButton();

            colAddSession=this.addColumn();
            colAddSession.add(this.AssistedFreehandButton);

        end

        function addAssistedFreehandButton(this)
            import matlab.ui.internal.toolstrip.*;


            addAssistedFreehandTitleId='vision:labeler:AddAssistedFreehand';
            addAssistedFreehandIcon=fullfile(this.IconPath,'assisted_freehand_24.png');
            addAssistedFreehandTag='btnAddAssistedFreehand';
            this.AssistedFreehandButton=this.createToggleButton(addAssistedFreehandIcon,...
            addAssistedFreehandTitleId,addAssistedFreehandTag);
            toolTipID='vision:labeler:AddAssistedFreehandTooltip';
            this.setToolTipText(this.AssistedFreehandButton,toolTipID);
        end
    end
end