
classdef DeleteCategoryDialog
    properties(Access=private)
Manager
Category
    end

    properties(Constant)
        Tag='DeleteCategoryDialog';
    end

    methods
        function this=DeleteCategoryDialog(manager,category)
            this.Manager=manager;
            this.Category=category;
        end

        function dlg=getDialogSchema(this,~)
            icon.Tag='icon';
            icon.Type='image';
            icon.FilePath=[matlabroot,'/toolbox/simulink/ui/studio/config/icons/question_48.png'];
            icon.RowSpan=[1,1];
            icon.ColSpan=[1,1];

            label=this.Manager.elideString(this.Category.label,50);

            text.Tag='text';
            text.Type='text';
            text.Name=DAStudio.message('simulink_ui:studio:resources:simulinkDeleteFavoriteCategoryDialogLabel',label);
            text.RowSpan=[1,1];
            text.ColSpan=[2,2];
            text.FontPointSize=12;
            text.WordWrap=true;
            text.MaximumSize=[480,320];
            text.PreferredSize=[480,320];

            dlg.DialogTag=dig.FavoriteCommands.DeleteCategoryDialog.Tag;
            dlg.DialogTitle=DAStudio.message('simulink_ui:studio:resources:simulinkDeleteFavoriteCategoryDialogTitle');
            dlg.Items={icon,text};
            dlg.StandaloneButtonSet={'Ok','Cancel'};
            dlg.IsScrollable=false;
            dlg.LayoutGrid=[1,2];
            dlg.ContentsMargins=[10,10,10,10];
            dlg.Spacing=10;
            dlg.Sticky=true;

            dlg.CloseCallback='dig.FavoriteCommands.DeleteCategoryDialog.onClose';
            dlg.CloseArgs={'%closeaction',this.Manager,this.Category.tag};
        end
    end

    methods(Static)
        function onClose(closeAction,manager,tag)
            if(strcmp(closeAction,'ok'))
                manager.deleteCategory(tag);
            end
        end
    end
end