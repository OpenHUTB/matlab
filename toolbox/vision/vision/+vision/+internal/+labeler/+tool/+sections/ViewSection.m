





classdef ViewSection<vision.internal.uitools.NewToolStripSection

    properties
ShowLabelsDropDown
ROIColorDropDown
ROIColorText
ShowLabelsText
    end

    methods
        function this=ViewSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=protected)
        function createSection(this)

            viewSectionTitle=getString(message('vision:labeler:ViewSection'));
            viewSectionTag='sectionView';

            this.Section=matlab.ui.internal.toolstrip.Section(viewSectionTitle);
            this.Section.Tag=viewSectionTag;
        end

        function layoutSection(this)

            this.addShowLabelsDropdown();
            this.addROIColorDropdown();
            createLayout(this);
        end

        function createLayout(this)
            col=this.addColumn('HorizontalAlignment','center');
            col.add(this.ShowLabelsText);
            col.add(this.ShowLabelsDropDown);

            col2=this.addColumn('HorizontalAlignment','center');
            col2.add(this.ROIColorText);
            col2.add(this.ROIColorDropDown);
        end

        function addShowLabelsDropdown(this)
            import matlab.ui.internal.toolstrip.*;


            labelId='vision:labeler:ShowROILabels';
            this.ShowLabelsText=this.createLabel(labelId);
            toolTipID=this.getToolTipMessageForShowLabels();
            this.setToolTipText(this.ShowLabelsText,toolTipID);

            tag='btnShowCuboidLabels';
            list={getString(message('vision:labeler:ROILabelsOnHover'));...
            getString(message('vision:labeler:ROILabelsAlways'));...
            getString(message('vision:labeler:ROILabelsNever'))};
            this.ShowLabelsDropDown=this.createDropDown(list,tag,toolTipID);

            this.ShowLabelsDropDown.SelectedIndex=find(strcmp(list,getString(message('vision:labeler:ROILabelsOnHover'))));
        end

        function addROIColorDropdown(this)
            import matlab.ui.internal.toolstrip.*;


            labelId='vision:labeler:ROIColor';
            this.ROIColorText=this.createLabel(labelId);
            toolTipID='vision:labeler:ROIColorToolTip';
            this.setToolTipText(this.ROIColorText,toolTipID);

            tag='btnROIColor';
            list={getString(message('vision:labeler:ColorByLabel'));...
            getString(message('vision:labeler:ColorByInstance'))};
            this.ROIColorDropDown=this.createDropDown(list,tag,toolTipID);

            this.ROIColorDropDown.SelectedIndex=find(strcmp(list,getString(message('vision:labeler:ColorByLabel'))));
        end
    end

    methods(Access=protected,Static)
        function toolTip=getToolTipMessageForShowLabels()
            toolTip='vision:labeler:ShowROILabelsToolTip';
        end
    end
end

