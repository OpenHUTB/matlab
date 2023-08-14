classdef CommentDetails<handle





    methods(Static)

        function panel=getDialogSchema(this)

            panel=struct('Type','togglepanel','Name',getString(message('Slvnv:slreq:Comments')),'LayoutGrid',[3,4],'Tag','Comments');
            panel.Expand=slreq.gui.togglePanelHandler('get',panel.Tag,false);
            panel.ExpandCallback=@slreq.gui.togglePanelHandler;
            panel.ColStretch=[0,0,1,0];
            panel.Items={};


            if isempty(this.Comments)

                panel.Items{end+1}=struct('Type','text','Name',getString(message('Slvnv:slreq:NoCommentHistory')),'RowSpan',[2,2],'ColSpan',[1,4]);
            else

                dasComments=this.Comments;
                nComments=length(dasComments);
                for n=1:nComments
                    thisComment=dasComments(nComments-n+1).getDialogSchema();
                    thisComment.RowSpan=[n+1,n+1];
                    thisComment.ColSpan=[1,4];
                    thisComment.Tag=['Comment_',int2str(n)];
                    panel.Items{end+1}=thisComment;
                end
            end


            buttonPanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[1,4],'Alignment',1);
            addCommentButton=struct('Type','pushbutton',...
            'Tag','addComment',...
            'Name',getString(message('Slvnv:slreq:AddComment')),...
            'RowSpan',[1,1],'ColSpan',[2,2],...
            'ToolTip',getString(message('Slvnv:slreq:AddComment')));
            addCommentButton.MatlabMethod='slreq.gui.CommentDetails.addComment';
            addCommentButton.MatlabArgs={'%dialog','%source'};
            buttonPanel.Items={addCommentButton};
            panel.Items{end+1}=buttonPanel;

        end

        function addComment(dlg,src)%#ok<INUSL>
            if isa(src,'DAStudio.DAObjectProxy')
                src=src.getMCOSObjectReference;
            end
            dlgObj=slreq.gui.CommentEditDialog(src);
            DAStudio.Dialog(dlgObj);
        end
    end
end
