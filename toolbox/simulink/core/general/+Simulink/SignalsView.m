classdef SignalsView<handle
    properties
        ViewTitle;
    end
    methods
        function this=SignalsView()
            this.ViewTitle='Signals';
        end
        function dlgStruct=getDialogSchema(obj,~)

            spacerWidget.Type='panel';
            spacerWidget.RowSpan=[1,1];
            spacerWidget.ColSpan=[2,2];

            dialogTitle.Type='text';
            dialogTitle.Tag='spreadsheet_title_text';
            dialogTitle.Name=obj.ViewTitle;
            dialogTitle.RowSpan=[1,1];
            dialogTitle.ColSpan=[1,1];

            scopeButton.Type='togglebutton';
            scopeButton.Tag='spreadsheet_scope_button';
            scopeButton.ToolTip='Change Scope';
            scopeButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','currentsystem.png');
            scopeButton.RowSpan=[1,1];
            scopeButton.ColSpan=[3,3];
            scopeButton.ObjectMethod='handleScopeOption';
            scopeButton.MethodArgs={'%dialog'};
            scopeButton.ArgDataTypes={'handle'};
            scopeButton.Graphical=1;

            filterButton.Type='pushbutton';
            filterButton.Tag='spreadsheet_filter_button';
            filterButton.ToolTip='Filter Contents';
            filterButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','find.png');
            filterButton.RowSpan=[1,1];
            filterButton.ColSpan=[4,4];
            filterButton.ObjectMethod='handleFilterOption';
            filterButton.MethodArgs={'%dialog'};
            filterButton.ArgDataTypes={'handle'};

            titlePanel.Type='panel';
            titlePanel.Items={dialogTitle,spacerWidget,scopeButton,...
            filterButton};
            titlePanel.LayoutGrid=[1,4];
            titlePanel.ColStretch=[0,1,0,0];
            titlePanel.RowSpan=[1,1];
            titlePanel.ColSpan=[1,1];


            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={titlePanel};
            dlgStruct.DialogTag='spreadsheet_signals_view_dlg';
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end

        function handleFilterOption(~,dlg)
            dlg.sendParentMessage('togglefilter');
        end

        function handleScopeOption(~,dlg)
            dlg.sendParentMessage('togglescope');
        end
    end
end
