
classdef(Hidden=true)NewCommandDialog<dig.FavoriteCommands.BaseCommandDialog
    properties(Constant,Hidden=true)
        Tag='NewCommandDialog';
    end

    methods(Hidden=true)
        function this=NewCommandDialog(manager)
            this@dig.FavoriteCommands.BaseCommandDialog(manager);

            icons=this.Manager.getIcons();
            this.SelectedIcon=icons{1}.getTag();
        end

        function dlg=getDialogWidget(this)
            dlg=getDialogWidget@dig.FavoriteCommands.BaseCommandDialog(this);

            dlg.DialogTag=dig.FavoriteCommands.NewCommandDialog.Tag;
            dlg.CloseCallback='dig.FavoriteCommands.NewCommandDialog.onClose';
            dlg.CloseArgs={'%dialog','%closeaction',this.Manager};
        end
    end

    methods(Static,Hidden=true)
        function onClose(dlg,closeAction,manager)
            dig.FavoriteCommands.BaseCommandDialog.onClose(dlg,closeAction,manager);

            if(strcmp(closeAction,'ok'))
                data=dig.FavoriteCommands.BaseCommandDialog.getValues(dlg);

                manager.addCommand(...
                data.label,...
                data.code,...
                data.category,...
                data.type,...
                data.icon,...
                data.addToQAB,...
                data.showQABLabel...
                );
            end
        end
    end
end
