classdef CommentEditDialog<handle



    properties
        ObjectToComment;
    end
    properties
        Comment='';
    end

    methods
        function this=CommentEditDialog(obj2Comment)
            this.ObjectToComment=obj2Comment;
        end
    end

    methods
        function dlgstruct=getDialogSchema(this,dlg)%#ok<INUSD>

            panel=struct('Type','panel','LayoutGrid',[1,2]);

            commentName=struct('Type','text','Name',getString(message('Slvnv:slreq:CommentColon')),...
            'RowSpan',[1,1],'ColSpan',[1,1]);

            commentValue=struct('Type','editarea',...
            'RowSpan',[2,2],'ColSpan',[1,1],'PreferredSize',[640,480],...
            'Tag','CommentText','WidgetId','CommentText');

            panel.Items={commentName,commentValue};

            dlgstruct.DialogTitle=getString(message('Slvnv:slreq:CommentEditor'));
            dlgstruct.StandaloneButtonSet={'OK','Cancel'};
            dlgstruct.Items={panel};

            dlgstruct.CloseMethod='dlgCloseMethod';
            dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgstruct.CloseMethodArgsDT={'handle','string'};

            dlgstruct.Sticky=true;
        end

        function dlgCloseMethod(this,dlg,actionStr)
            if strcmp(actionStr,'ok')
                comment=this.ObjectToComment.addComment;
                comment.Text=dlg.getWidgetValue('CommentText');

                this.ObjectToComment.Comments(end)=comment;
                this.ObjectToComment.view.update;
            end
        end

        function yesno=isEditablePropertyInInspector(this,propName)%#ok<INUSD>
            yesno=true;
        end

        function name=getDisplayName(this,propName)%#ok<INUSL>
            name=propName;
        end

        function type=getPropertyWidgetType(this,propName)%#ok<INUSL>
            if strcmp(propName,'Comment')
                type='editarea';
            else
                type='edit';
            end
        end
    end
end
