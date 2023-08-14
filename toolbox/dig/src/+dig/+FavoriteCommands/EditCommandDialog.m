
classdef(Hidden=true)EditCommandDialog<dig.FavoriteCommands.BaseCommandDialog
    properties(Access=public,Hidden=true)
Command
    end

    properties(Constant,Hidden=true)
        Tag='EditCommandDialog';
    end

    methods(Hidden=true)
        function this=EditCommandDialog(manager,command)
            this@dig.FavoriteCommands.BaseCommandDialog(manager);
            this.Command=command;

            if(isfield(this.Command,'icon')&&this.Manager.hasIcon('Tag',this.Command.icon))
                this.SelectedIcon=this.Command.icon;
            else
                icons=this.Manager.getIcons();
                this.SelectedIcon=icons{1}.getTag();
            end
        end

        function[label,input]=getEditWidget(this)
            [label,input]=getEditWidget@dig.FavoriteCommands.BaseCommandDialog(this);
            input.Value=this.Command.label;
        end

        function[label,input]=getTypeWidget(this)
            [label,input]=getTypeWidget@dig.FavoriteCommands.BaseCommandDialog(this);
            input.Value=dig.FavoriteCommands.Manager.getCommandTypeIndex(this.Command)-1;
        end

        function[label,input]=getCodeWidget(this)
            [label,input]=getCodeWidget@dig.FavoriteCommands.BaseCommandDialog(this);
            input.Value=this.Command.code;
        end

        function[label,input]=getCategoryWidget(this)
            [label,input]=getCategoryWidget@dig.FavoriteCommands.BaseCommandDialog(this);
            [~,index]=this.Manager.findCategoryByTag(this.Command.category);
            input.Value=index-1;
        end

        function[label,input]=getIconWidget(this)
            [label,input]=getIconWidget@dig.FavoriteCommands.BaseCommandDialog(this);

            if(isfield(this.Command,'icon')&&this.Manager.hasIcon('Tag',this.Command.icon))
                this.SelectedIcon=this.Command.icon;
            else
                icons=this.Manager.getIcons();
                this.SelectedIcon=icons{1}.getTag();
            end

            input.DefaultAction=this.SelectedIcon;
        end

        function qabAdd=getQABAddWidget(this)
            qabAdd=getQABAddWidget@dig.FavoriteCommands.BaseCommandDialog(this);

            if(isfield(this.Command,'addToQAB')&&~isempty(this.Command.addToQAB))
                qabAdd.Value=this.Command.addToQAB;
            end
        end

        function qabShowLabel=getQABShowLabelWidget(this)
            qabShowLabel=getQABShowLabelWidget@dig.FavoriteCommands.BaseCommandDialog(this);

            if(isfield(this.Command,'showQABLabel')&&~isempty(this.Command.showQABLabel))
                qabShowLabel.Value=this.Command.showQABLabel;
            end

            if isfield(this.Command,'addToQAB')&&~isempty(this.Command.addToQAB)
                qabShowLabel.Enabled=this.Command.addToQAB;
            end
        end

        function dlg=getDialogWidget(this)
            dlg=getDialogWidget@dig.FavoriteCommands.BaseCommandDialog(this);

            dlg.DialogTag=dig.FavoriteCommands.EditCommandDialog.Tag;
            dlg.CloseCallback='dig.FavoriteCommands.EditCommandDialog.onClose';
            dlg.CloseArgs={'%dialog','%closeaction',this.Manager,this.Command.tag};
        end
    end

    methods(Static,Hidden=true)
        function onClose(dlg,closeAction,manager,tag)
            dig.FavoriteCommands.BaseCommandDialog.onClose(dlg,closeAction,manager);

            if(strcmp(closeAction,'ok'))
                data=dig.FavoriteCommands.BaseCommandDialog.getValues(dlg);

                manager.editCommand(...
                tag,...
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