classdef Comment<slreq.data.DataModelObj



    properties(Dependent)
Date
CommentedBy
Text
Type
CommentedRevision
    end

    methods(Access=?slreq.data.ReqData)



        function this=Comment(modelObject)
            this.modelObject=modelObject;
        end
    end

    methods

        function val=get.Date(this)
            val=slreq.utils.getDateTime(this.modelObject.date,'Read');
        end

        function val=get.CommentedBy(this)
            val=this.modelObject.commentedBy;
        end

        function val=get.Text(this)
            val=this.modelObject.text;
        end

        function val=get.CommentedRevision(this)
            val=this.modelObject.commentedRevision;
        end

        function set.Date(this,val)
            this.modelObject.date=val;
        end

        function set.CommentedBy(this,val)
            this.modelObject.commentedBy=val;
        end

        function set.Text(this,val)
            this.modelObject.text=val;
        end

        function val=sourceObject(this)

            val=slreq.data.ReqLinkBase.empty();
            if~isempty(this.modelObject.requirement)
                val=slreq.data.ReqData.getWrappedObj(this.modelObject.requirement);
            elseif~isempty(this.modelObject.link)
                val=slreq.data.ReqData.getWrappedObj(this.modelObject.link);
            end
        end
    end
end
