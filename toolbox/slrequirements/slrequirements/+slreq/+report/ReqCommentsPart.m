classdef ReqCommentsPart<slreq.report.ReportPart

    properties
        Comments;
    end

    methods

        function part=ReqCommentsPart(p1,comments)
            if isempty(comments)&&strcmpi(p1.Type,'docx')
                partName='SLReqReqCommentsEmptyPart';
            else
                partName='SLReqReqCommentsPart';
            end

            part=part@slreq.report.ReportPart(p1,partName);
            part.Comments=comments;
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                comments=this.Comments;
                switch lower(this.CurrentHoleId)
                case 'commentname'
                    str=getString(message('Slvnv:slreq:Comments'));
                    text=mlreportgen.dom.Text(str,'SLReqReqCommentTitleName');
                case 'commentlist'
                    if isempty(comments)
                        text=mlreportgen.dom.Text('');
                    else
                        for index=1:length(comments)
                            cComment=comments(index);
                            commentInfo=getString(message('Slvnv:slreq:WhoCommentedAtWhenRev',cComment.CommentedBy,datestr(cComment.Date,'local'),cComment.CommentedRevision));
                            comment=cComment.Text;
                            cpart=slreq.report.ReqCommentPart(this,commentInfo,comment);
                            cpart.fill
                            append(this,cpart);
                        end
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




