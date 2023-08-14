
classdef EditCategoryDialog
    properties(Access=private)
Manager
Category
    end

    properties(Constant)
        Tag='EditCategoryDialog';
    end

    methods
        function this=EditCategoryDialog(manager,category)
            this.Manager=manager;
            this.Category=category;
        end

        function dlg=getDialogSchema(this,~)
            edit.Tag='label';
            edit.Type='edit';
            edit.Name=DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCategoryDialogEditName');
            edit.ToolTip=DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCategoryDialogEditToolTip');
            edit.Value=this.Category.label;
            edit.ObjectMethod='onEditChanged';
            edit.MethodArgs={'%dialog','%value'};
            edit.ArgDataTypes={'handle','mxArray'};
            edit.RespondsToTextChanged=true;

            okButton.Type='pushbutton';
            okButton.Name=DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandDialogOK');
            okButton.RowSpan=[1,1];
            okButton.ColSpan=[2,2];
            okButton.Tag='okButton';
            okButton.Enabled=true;
            okButton.ObjectMethod='onOK';
            okButton.MethodArgs={'%dialog'};
            okButton.ArgDataTypes={'handle'};



            cancelButton.Type='pushbutton';
            cancelButton.Name=DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandDialogCancel');
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[3,3];
            cancelButton.Tag='cancelButton';
            cancelButton.ObjectMethod='onCancel';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};

            buttonContainer.Name='buttonContainer';
            buttonContainer.Tag='buttonContainer';
            buttonContainer.Type='panel';
            buttonContainer.LayoutGrid=[1,3];
            buttonContainer.ColStretch=[1,0,0];
            buttonContainer.Items={okButton,cancelButton};

            dlg.DialogTag=dig.FavoriteCommands.EditCategoryDialog.Tag;
            dlg.DialogTitle=DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCategoryDialogTitle');
            dlg.Items={edit};
            dlg.StandaloneButtonSet=buttonContainer;
            dlg.Sticky=true;

            dlg.OpenCallback=@dig.FavoriteCommands.EditCategoryDialog.onOpen;
        end

        function onEditChanged(~,dlg,value)
            dlg.setEnabled('okButton',~isempty(strtrim(value)));
        end

        function onOK(this,dlg)
            label=dlg.getWidgetValue('label');
            this.Manager.editCategory(this.Category.tag,label);
            dlg.delete;
        end

        function onCancel(~,dlg)
            dlg.delete;
        end
    end

    methods(Static)
        function onOpen(dlg)
            dlg.setFocus('label');
            dlg.enableApplyButton(false);
        end
    end
end