





classdef ResourcesSection<vision.internal.uitools.NewToolStripSection
    properties
ViewShortcutsButton
    end

    methods

        function this=ResourcesSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)

        function createSection(this)
            resourcesSectionTitle=getString(message('vision:labeler:ResourcesSection'));
            resourcesSectionTag='sectionresources';

            this.Section=matlab.ui.internal.toolstrip.Section(resourcesSectionTitle);
            this.Section.Tag=resourcesSectionTag;
        end


        function layoutSection(this)
            this.addViewShortcutsButton();

            col=this.addColumn();
            col.add(this.ViewShortcutsButton);
        end


        function addViewShortcutsButton(this)
            icon=fullfile(toolboxdir('vision'),'vision','+vision','+internal',...
            '+labeler','+tool','+icons','ViewShortcuts_24.png');
            titleID='vision:labeler:ViewShortcuts';
            tag='btnViewShortcuts';
            this.ViewShortcutsButton=this.createButton(icon,titleID,tag);
            this.ViewShortcutsButton.Enabled=true;

            toolTipID='vision:labeler:ViewShortcutsButtonToolTip';
            this.setToolTipText(this.ViewShortcutsButton,toolTipID);
        end
    end
end
