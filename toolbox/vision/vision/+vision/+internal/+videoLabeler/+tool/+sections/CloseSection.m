






classdef CloseSection<vision.internal.uitools.NewToolStripSection

    properties
AcceptButton
CancelButton
    end

    methods
        function this=CloseSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)

            closeSectionTitle=vision.getMessage('vision:labeler:Close');
            closeSectionTag='sectionClose';

            this.Section=matlab.ui.internal.toolstrip.Section(closeSectionTitle);
            this.Section.Tag=closeSectionTag;
        end

        function layoutSection(this)

            this.addAcceptButton();
            this.addCancelButton();

            acceptCol=this.addColumn();
            acceptCol.add(this.AcceptButton);

            cancelCol=this.addColumn();
            cancelCol.add(this.CancelButton);
        end

        function addAcceptButton(this)

            icon=matlab.ui.internal.toolstrip.Icon.CONFIRM_24;
            titleID='vision:labeler:Accept';
            tag='btnAccept';
            this.AcceptButton=this.createButton(icon,titleID,tag);
            toolTipID='vision:labeler:SelectAcceptButtonTooltip';
            this.setToolTipText(this.AcceptButton,toolTipID);
        end

        function addCancelButton(this)

            icon=matlab.ui.internal.toolstrip.Icon.CLOSE_24;
            titleID='vision:labeler:Cancel';
            tag='btnCancel';
            this.CancelButton=this.createButton(icon,titleID,tag);
            toolTipID='vision:labeler:SelectCancelButtonTooltip';
            this.setToolTipText(this.CancelButton,toolTipID);
        end
    end
end