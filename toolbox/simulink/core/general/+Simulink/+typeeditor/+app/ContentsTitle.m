classdef ContentsTitle<handle




    properties(Constant,Hidden,Access=private)
        TitleDialogTag='BusEditorContentsTitle'
        TitleWidgetTag='textwidget'
    end

    methods(Static,Hidden,Access=?Simulink.typeeditor.app.Editor)
        function instance=getInstance
            persistent obj;
            if isempty(obj)||~isvalid(obj)
                obj=Simulink.typeeditor.app.ContentsTitle;
            end
            instance=obj;
        end

        function updateTitle
            dlgs=DAStudio.ToolRoot.getOpenDialogs;
            dlg=dlgs.find('DialogTag',Simulink.typeeditor.app.ContentsTitle.TitleDialogTag);
            if~isempty(dlg)&&ishandle(dlg)
                ed=Simulink.typeeditor.app.Editor.getInstance;
                node=ed.getCurrentTreeNode;
                if isempty(node)
                    node=ed.getBaseRoot;
                else
                    node=node{1};
                end

                dlg.setWidgetValue(Simulink.typeeditor.app.ContentsTitle.TitleWidgetTag,...
                DAStudio.message('Simulink:busEditor:ContentsTitle',node.getNodeName(false)));
            end
        end
    end

    methods(Hidden)
        function dlgStruct=getDialogSchema(~,~)
            ed=Simulink.typeeditor.app.Editor.getInstance;
            node=ed.getCurrentTreeNode;
            if isempty(node)
                node=ed.getBaseRoot;
            else
                node=node{1};
            end
            titleWidget.Type='text';
            titleWidget.Name=DAStudio.message('Simulink:busEditor:ContentsTitle',node.getNodeName(false));
            titleWidget.Tag=Simulink.typeeditor.app.ContentsTitle.TitleWidgetTag;
            titleWidget.RowSpan=[1,1];
            titleWidget.ColSpan=[1,1];

            spacer.Type='panel';

            filterWidget.Type='spreadsheetfilter';
            filterWidget.Tag='spreadsheetfilter';
            filterWidget.PlaceholderText=DAStudio.message('Simulink:studio:DataView_default_filter');
            filterWidget.ToolTip=DAStudio.message('Simulink:studio:DataView_default_filter');
            filterWidget.Clearable=true;
            filterWidget.RowSpan=[1,1];
            filterWidget.ColSpan=[3,3];

            dlgStruct.LayoutGrid=[1,3];
            dlgStruct.ColStretch=[0,1,0];
            dlgStruct.Items={titleWidget,spacer,filterWidget};
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
            dlgStruct.DialogTag=Simulink.typeeditor.app.ContentsTitle.TitleDialogTag;
        end
    end

    methods(Access=private)
        function this=ContentsTitle
        end
    end
end