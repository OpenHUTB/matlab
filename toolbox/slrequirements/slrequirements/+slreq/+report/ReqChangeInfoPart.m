classdef ReqChangeInfoPart<slreq.report.ReportPart

    properties
        ChangeValueContext;
        StyleStruct;
        HasChangeIssue;
    end

    methods

        function part=ReqChangeInfoPart(p1,changeInfo,styleType)
            part=part@slreq.report.ReportPart(p1,'SLReqReqChangeInfoPart');
            if strcmpi(styleType,'set')
                part.StyleStruct.name='SLReqReqSetChangeInfoTitle';
                part.StyleStruct.value='SLReqReqSetChangeInfoValue';

                if changeInfo==0
                    part.ChangeValueContext=getString(message('Slvnv:slreq:ReportContentChangeInfoChangeIssueNotFound'));
                    part.HasChangeIssue=false;
                else
                    part.ChangeValueContext=getString(message('Slvnv:slreq:ReportContentChangeInfoChangeIssueFoundIn',changeInfo));
                    part.HasChangeIssue=true;
                end
            else

                if changeInfo

                    part.ChangeValueContext=getString(message('Slvnv:slreq:ReportContentChangeInfoChangeIssueFound'));
                    part.HasChangeIssue=true;
                else
                    part.ChangeValueContext=getString(message('Slvnv:slreq:ReportContentChangeInfoChangeIssueNotFound'));
                    part.HasChangeIssue=false;
                end
                part.StyleStruct.name='SLReqReqChangeInfoTitle';
                part.StyleStruct.value='SLReqReqChangeInfoValue';
            end
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                switch lower(this.CurrentHoleId)
                case 'changeinfoname'
                    str=getString(message('Slvnv:slreq:ChangeInformation'));
                    text=mlreportgen.dom.Text(str,this.StyleStruct.name);
                case 'changeinfovalue'
                    str=this.ChangeValueContext;
                    if this.HasChangeIssue
                        targetName=slreq.report.utils.getLinkTargetString(slreq.report.Report.CHANGED_LINK_LIST_TARGET);
                        text=mlreportgen.dom.InternalLink(targetName,str,this.StyleStruct.value);
                    else
                        text=mlreportgen.dom.Text(str,this.StyleStruct.value);
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