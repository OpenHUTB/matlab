classdef FimTab<autosar.ui.bsw.Tab




    properties(Constant)
        tag='fimTag';
    end

    methods(Static)
        function text=getTab(h)
            tagPrefix=autosar.ui.bsw.FimTab.tag;


            configRow=0;


            configRow=configRow+1;
            widget=[];
            widget.Name=DAStudio.message('autosarstandard:ui:uiRTEDesc');
            widget.ToolTip=DAStudio.message('autosarstandard:ui:uiRTEDescTip');
            widget.Type='text';
            widget.WordWrap=true;
            widget.Tag=[tagPrefix,'descriptionText'];
            widget.ColSpan=[1,1];
            widget.RowSpan=[1,1];
            descriptionText=widget;

            configRow=configRow+1;
            filterWidget.Type='spreadsheetfilter';
            filterWidget.Tag=[tagPrefix,'spreadsheetfilterWidget'];
            filterWidget.PlaceholderText=DAStudio.message('autosarstandard:ui:uiRTEFilterText');
            filterWidget.Clearable=true;
            filterWidget.TargetSpreadsheet=[tagPrefix,'matrixSpreadsheet'];
            filterWidget.RowSpan=[2,2];
            filterWidget.ColSpan=[1,1];


            configRow=configRow+1;
            widget=[];
            widget.Type='spreadsheet';
            widget.Columns={
            autosar.ui.bsw.FiMMatrixSpreadsheetInnerRow.IdColumn...
            ,autosar.ui.bsw.FiMMatrixSpreadsheetInnerRow.EventIdColumn...
            ,autosar.ui.bsw.FiMMatrixSpreadsheetInnerRow.MaskColumn...
            };
            widget.SortColumn=autosar.ui.bsw.FiMMatrixSpreadsheetRow.FIDColumn;
            widget.SortOrder=true;
            widget.ColSpan=[1,19];
            widget.RowSpan=[1,20];
            widget.Enabled=true;
            widget.Source=autosar.ui.bsw.FiMMatrixSpreadsheet(h);
            widget.Tag=[tagPrefix,'matrixSpreadsheet'];
            widget.Visible=true;
            widget.Hierarchical=true;
            matrixSpreadsheet=widget;

            addButton.Type='pushbutton';
            addButton.Tag=[tagPrefix,'AddButton'];
            addButton.ColSpan=[20,20];
            addButton.RowSpan=[2,3];
            addButton.MatlabArgs={'%dialog'};
            addButton.ArgDataTypes={'handle'};
            addButton.MatlabMethod='autosar.ui.bsw.FiMMatrixSpreadsheet.addInhibitionCondition';
            addButton.ToolTip=DAStudio.message('autosarstandard:ui:uiRTEFiMAddConditionTooltip');
            addButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','add_row.gif');
            addButton.Enabled=autosar.ui.bsw.FiMMatrixSpreadsheet.isAddButtonEnabled(h);

            removeButton.Type='pushbutton';
            removeButton.Tag=[tagPrefix,'RemoveButton'];
            removeButton.ColSpan=[20,20];
            removeButton.RowSpan=[4,5];
            removeButton.MatlabArgs={'%dialog'};
            removeButton.ArgDataTypes={'handle'};
            removeButton.MatlabMethod='autosar.ui.bsw.FiMMatrixSpreadsheet.removeInhibitionCondition';
            removeButton.ToolTip=DAStudio.message('autosarstandard:ui:uiRTEFiMDeleteConditionTooltip');
            removeButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','TTE_delete.gif');
            removeButton.Enabled=autosar.ui.bsw.FiMMatrixSpreadsheet.isRemoveButtonEnabled(h);

            topContainer.Type='panel';
            topContainer.Tag=[tagPrefix,'topContainer'];
            topContainer.LayoutGrid=[configRow,2];
            topContainer.ColSpan=[1,1];
            topContainer.RowSpan=[1,1];
            topContainer.Items={
descriptionText...
            ,filterWidget...
            };

            spreadsheetContainer.Type='panel';
            spreadsheetContainer.Tag=[tagPrefix,'matrixContainer'];
            spreadsheetContainer.LayoutGrid=[20,20];
            spreadsheetContainer.ColSpan=[1,1];
            spreadsheetContainer.RowSpan=[2,20];
            spreadsheetContainer.Items={
matrixSpreadsheet...
            ,addButton...
            ,removeButton...
            };


            matrixContainer.Type='panel';
            matrixContainer.Tag=[tagPrefix,'matrixContainer'];
            matrixContainer.LayoutGrid=[1,20];
            matrixContainer.ColSpan=[1,1];
            matrixContainer.RowSpan=[1,1];
            matrixContainer.Items={
topContainer...
            ,spreadsheetContainer...
            };


            text=[];
            text.Name=DAStudio.message('autosarstandard:ui:uiFiMTab');
            text.Tag=[tagPrefix,'fimtabtext'];

            text.Items={
matrixContainer
            };
        end
    end
end


