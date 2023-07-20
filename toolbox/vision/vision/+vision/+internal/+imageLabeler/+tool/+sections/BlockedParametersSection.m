







classdef BlockedParametersSection<vision.internal.uitools.NewToolStripSection

    properties
ResLevelDropDown
BlockSizeRowsField
BlockSizeColumnsField
UseParallelToggleButton
    end

    methods
        function this=BlockedParametersSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)

            blockedParamSectionTitle=vision.getMessage('vision:imageLabeler:BlockedParameters');
            blockedParamSectionTag='sectionBlockedParam';

            this.Section=matlab.ui.internal.toolstrip.Section(blockedParamSectionTitle);
            this.Section.Tag=blockedParamSectionTag;
        end

        function layoutSection(this)

            this.addResolutionLevelDropdown();
            this.addBlockSizeFields();

            resLevelCol=this.addColumn();
            resLevelCol.add(this.createLabel('vision:imageLabeler:ResLevelParameter'));
            resLevelCol.add(this.ResLevelDropDown);
            resLevelCol.add(matlab.ui.internal.toolstrip.EmptyControl);


            this.addColumn('Width',10);

            blockSizeLabelCol=this.addColumn();
            blockSizeLabelCol.add(this.createLabel('vision:imageLabeler:BlockSizeParameter'));
            blockSizeLabelCol.add(this.createLabel('vision:imageLabeler:BlockSizeRowParameter'));
            blockSizeLabelCol.add(this.createLabel('vision:imageLabeler:BlockSizeColumnParameter'));


            this.addColumn('Width',10);

            blockSizeEditCol=this.addColumn();
            blockSizeEditCol.add(matlab.ui.internal.toolstrip.EmptyControl);
            blockSizeEditCol.add(this.BlockSizeRowsField);
            blockSizeEditCol.add(this.BlockSizeColumnsField);

            if~isdeployed()

                this.addUseParallelToggleButton();


                this.addColumn('Width',10);

                useParallelCol=this.addColumn();
                useParallelCol.add(this.UseParallelToggleButton);
            end
        end

        function addResolutionLevelDropdown(this)

            tag='dropdownResLevel';
            listDefault={'1'};
            toolTipID='vision:imageLabeler:SelectResLevelTooltip';
            this.ResLevelDropDown=this.createDropDown(listDefault,tag,toolTipID);
            this.ResLevelDropDown.SelectedIndex=1;
        end

        function addBlockSizeFields(this)


            rowtag='rowedit';
            rowsDefault='1024';
            rowtoolTipID='vision:imageLabeler:SelectBlockSizeRowTooltip';
            this.BlockSizeRowsField=matlab.ui.internal.toolstrip.EditField(rowsDefault);
            this.BlockSizeRowsField.Tag=rowtag;
            this.setToolTipText(this.BlockSizeRowsField,rowtoolTipID);

            coltag='columnedit';
            columnDefault='1024';
            coltoolTipID='vision:imageLabeler:SelectBlockSizeColumnTooltip';
            this.BlockSizeColumnsField=matlab.ui.internal.toolstrip.EditField(columnDefault);
            this.BlockSizeColumnsField.Tag=coltag;
            this.setToolTipText(this.BlockSizeColumnsField,coltoolTipID);
        end

        function addUseParallelToggleButton(this)

            icon=matlab.ui.internal.toolstrip.Icon.PARALLEL_24;
            titleID='vision:imageLabeler:UseParallel';
            tag='btnUseParallel';
            this.UseParallelToggleButton=this.createToggleButton(icon,titleID,tag);
            toolTipID='vision:imageLabeler:SelectUseParallelTooltip';
            this.setToolTipText(this.UseParallelToggleButton,toolTipID);
        end
    end
end