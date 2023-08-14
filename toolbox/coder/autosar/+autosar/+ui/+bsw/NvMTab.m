classdef NvMTab<autosar.ui.bsw.Tab




    properties(Constant)
        tag='nvmInitValTag';
    end

    methods(Static)
        function text=getTab(h)
            tagPrefix=autosar.ui.bsw.NvMTab.tag;


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
            filterWidget.PlaceholderText='Filter contents';
            filterWidget.Clearable=true;
            filterWidget.TargetSpreadsheet=[tagPrefix,'matrixSpreadsheet'];
            filterWidget.RowSpan=[2,2];
            filterWidget.ColSpan=[1,1];


            configRow=configRow+1;
            widget=[];
            widget.Type='spreadsheet';
            widget.Columns={
            autosar.ui.bsw.NvMInitValSpreadsheetRow.IdColumn...
            ,autosar.ui.bsw.NvMInitValSpreadsheetRow.NvBlockPortsColumn...
            ,autosar.ui.bsw.NvMInitValSpreadsheetRow.InitValColumn...
            };
            widget.SortColumn=autosar.ui.bsw.NvMInitValSpreadsheetRow.IdColumn;
            widget.SortOrder=true;
            widget.ColSpan=[1,19];
            widget.RowSpan=[1,20];
            widget.Enabled=true;
            widget.Source=autosar.ui.bsw.NvMInitValSpreadsheet(h);
            widget.Tag=[tagPrefix,'matrixSpreadsheet'];
            widget.Visible=true;
            widget.Hierarchical=true;
            matrixSpreadsheet=widget;

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
            spreadsheetContainer.LayoutGrid=[1,1];
            spreadsheetContainer.ColSpan=[1,1];
            spreadsheetContainer.RowSpan=[1,1];
            spreadsheetContainer.Items={matrixSpreadsheet};


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
            text.Name=DAStudio.message('autosarstandard:ui:uiNvMInitValueTab');
            text.Tag=[tagPrefix,'Tab'];

            text.Items={
matrixContainer
            };

        end
    end
end


