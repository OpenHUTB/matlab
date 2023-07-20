classdef ReqCommentPart<slreq.report.ReportPart

    properties
        CommentInfo;
        Comment;
    end

    methods

        function part=ReqCommentPart(p1,commentInfo,comment)
            part=part@slreq.report.ReportPart(p1,'SLReqReqCommentPart');
            part.CommentInfo=commentInfo;
            part.Comment=comment;
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                comment=this.Comment;
                switch lower(this.CurrentHoleId)
                case 'commentinfo'
                    text=mlreportgen.dom.Text(this.CommentInfo,'SLReqReqCommentName');
                case 'commentcontent'
                    if isempty(comment)
                        text=' ';
                    else
                        text=mlreportgen.dom.Text(comment,'SLReqReqCommentValue');
                    end
                end
                if~isempty(text)
                    append(this,text);
                end
                moveToNextHole(this);
            end
        end
    end
end




