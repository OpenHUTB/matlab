classdef Comment<slreq.das.BaseObject



    properties(Dependent)
Date
CommentedBy
Text
CommentedRevision
    end

    methods
        function this=Comment(comment)
            this@slreq.das.BaseObject(comment);
        end

        function val=get.Date(this)
            val=this.dataModelObj.Date;
        end

        function val=get.CommentedBy(this)
            val=this.dataModelObj.CommentedBy;
        end

        function val=get.Text(this)
            val=this.dataModelObj.Text;
        end

        function val=get.CommentedRevision(this)
            val=this.dataModelObj.CommentedRevision;
        end

        function set.Date(this,val)
            this.dataModelObj.Date=val;
        end

        function set.CommentedBy(this,val)
            this.dataModelObj.CommentedBy=val;
        end

        function set.Text(this,val)
            this.dataModelObj.Text=val;
        end

        function val=sourceObject(this)
            val=this.dataModelObj.sourceObject;
        end
    end

    methods
        function dialog=getDialogSchema(this)
            dialog=struct('Type','group','LayoutGrid',[1,1]);
            dialog.Items={};
            dialog.Name=getString(message('Slvnv:slreq:WhoCommentedAtWhenRev',this.CommentedBy,datestr(this.Date,'local'),this.CommentedRevision));
            textBody=struct('Type','textbrowser','Text',this.Text,'BackgroundColor',[255,255,255],...
            'Tag','Text','WidgetId','text_widget','RowSpan',[1,1],'ColSpan',[1,1]);
            linecount=sum(this.Text==newline);
            if linecount<12
                sizeToFit=(linecount+1)*5;
                textBody.PreferredSize=[-1,sizeToFit];
            end
            dialog.Items{end+1}=textBody;
        end
    end
end
