classdef PortConfigTab<autosar.ui.bsw.Tab




    properties(Constant)
        tag='tag_';
    end

    methods(Static)
        function text=getTab(h)
            tagPrefix=autosar.ui.bsw.PortConfigTab.tag;

            configurationRow=0;


            configurationRow=configurationRow+1;
            widget=[];
            widget.Name=DAStudio.message('autosarstandard:ui:uiRTEDesc');
            widget.ToolTip=DAStudio.message('autosarstandard:ui:uiRTEDescTip');
            widget.Type='text';
            widget.WordWrap=true;
            widget.Tag=[tagPrefix,'MappingDescriptionLabel'];
            widget.ColSpan=[1,1];
            widget.RowSpan=[configurationRow,configurationRow];
            MappingDescriptionLabel=widget;


            configurationRow=configurationRow+1;
            widget=[];
            widget.Type='spreadsheetfilter';
            widget.RowSpan=[configurationRow,configurationRow];
            widget.Tag=[tagPrefix,'MappingSpreadsheetFilter'];
            widget.TargetSpreadsheet=[tagPrefix,'MappingSpreadsheet'];
            widget.PlaceholderText=DAStudio.message('autosarstandard:ui:uiRTEFilterText');
            widget.Visible=true;
            widget.Clearable=true;
            MappingSpreadsheetFilter=widget;


            configurationRow=configurationRow+1;
            widget=[];
            widget.Type='spreadsheet';
            if autosar.ui.bsw.Tab.isDem(h)
                widget.Columns={
                autosar.ui.bsw.ServiceComponentSpreadsheetRow.ClientPortColumn...
                ,autosar.ui.bsw.ServiceComponentSpreadsheetRow.IdColumn...
                ,autosar.ui.bsw.ServiceComponentSpreadsheetRow.IdTypeColumn
                };
            else
                widget.Columns={
                autosar.ui.bsw.ServiceComponentSpreadsheetRow.ClientPortColumn...
                ,autosar.ui.bsw.ServiceComponentSpreadsheetRow.BlockIdColumn...
                };
            end
            widget.SortColumn=autosar.ui.bsw.ServiceComponentSpreadsheetRow.ClientPortColumn;
            widget.SortOrder=true;
            widget.RowSpan=[configurationRow,configurationRow];
            widget.Enabled=true;
            widget.Source=autosar.ui.bsw.ServiceComponentSpreadsheet(h);
            widget.Tag=[tagPrefix,'MappingSpreadsheet'];
            widget.Visible=true;
            MappingSpreadsheet=widget;


            mappingcontainer.Type='panel';
            mappingcontainer.Tag=[tagPrefix,'mappingcontainer'];
            mappingcontainer.LayoutGrid=[configurationRow,2];

            mappingcontainer.ColSpan=[1,1];
            mappingcontainer.RowSpan=[1,1];
            mappingcontainer.Items={
MappingDescriptionLabel...
            ,MappingSpreadsheetFilter...
            ,MappingSpreadsheet};


            text=[];
            text.Name=DAStudio.message('autosarstandard:ui:uiRTETab');
            text.Tag=[tagPrefix,'portconfigurationtab'];
            text.LayoutGrid=[configurationRow,2];
            text.Items={mappingcontainer};

        end
    end
end


