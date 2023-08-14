

classdef DeleteCommandDialog
    properties(Access=private)
Manager
Command
    end

    properties(Constant)
        Tag='DeleteCommandDialog';
    end

    methods
        function this=DeleteCommandDialog(manager,command)
            this.Manager=manager;
            this.Command=command;
        end

        function dlg=getDialogSchema(this,~)
            icon.Tag='icon';
            icon.Type='image';
            icon.FilePath=[matlabroot,'/toolbox/simulink/ui/studio/config/icons/question_48.png'];
            icon.RowSpan=[1,1];
            icon.ColSpan=[1,1];

            text.Tag='text';
            text.Type='text';
            text.Name=DAStudio.message('simulink_ui:studio:resources:simulinkDeleteFavoriteCommandDialogLabel',this.Command.label);
            text.RowSpan=[1,1];
            text.ColSpan=[2,2];
            text.FontPointSize=12;
            text.WordWrap=true;
            text.PreferredSize=[320,240];

            dlg.DialogTag=dig.FavoriteCommands.DeleteCommandDialog.Tag;
            dlg.DialogTitle=DAStudio.message('simulink_ui:studio:resources:simulinkDeleteFavoriteCommandDialogTitle');
            dlg.Items={icon,text};
            dlg.StandaloneButtonSet={'Ok','Cancel'};
            dlg.IsScrollable=false;
            dlg.LayoutGrid=[1,2];
            dlg.ContentsMargins=[10,10,10,10];
            dlg.Spacing=10;
            dlg.Sticky=true;

            dlg.CloseCallback='dig.FavoriteCommands.DeleteCommandDialog.onClose';
            dlg.CloseArgs={'%closeaction',this.Manager,this.Command.tag};
        end
    end

    methods(Static)
        function onClose(closeAction,manager,tag)
            if(strcmp(closeAction,'ok'))
                manager.deleteCommand(tag);
            end
        end
    end
end