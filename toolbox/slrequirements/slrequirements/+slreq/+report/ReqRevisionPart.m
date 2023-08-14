classdef ReqRevisionPart<slreq.report.ReportPart

    properties
        ReqInfo;
    end

    methods

        function part=ReqRevisionPart(p1)
            if p1.ReqInfo.external
                quickPart='SLReqReqRevisionExPart';
            else
                quickPart='SLReqReqRevisionInPart';
            end
            part=part@slreq.report.ReportPart(p1,quickPart);
            part.ReqInfo=p1.ReqInfo;
        end


        function fill(this)
            reqInfo=this.ReqInfo;
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                switch lower(this.CurrentHoleId)
                case 'revisioninfoname'
                    str=getString(message('Slvnv:slreq:ReportContentRevisionInfo'));
                    text=mlreportgen.dom.Text(str,'SLReqReqRevisionInfoName');
                case 'sidname'
                    str=getString(message('Slvnv:slreq:SID'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSIDName');
                case 'sidvalue'
                    text=mlreportgen.dom.Text(reqInfo.sid,'SLReqReqSIDValue');
                case 'revisionname'
                    str=getString(message('Slvnv:slreq:Revision'));
                    text=mlreportgen.dom.Text(str,'SLReqReqRevisionName');
                case 'revisionvalue'
                    text=mlreportgen.dom.Text(reqInfo.revision,'SLReqReqRevisionValue');
                case 'createdbyname'
                    str=getString(message('Slvnv:slreq:CreatedBy'));
                    text=mlreportgen.dom.Text(str,'SLReqReqCreatedByName');
                case 'createdbyvalue'
                    text=mlreportgen.dom.Text(reqInfo.createdBy,'SLReqReqCreatedByValue');
                case 'createdonname'
                    str=getString(message('Slvnv:slreq:CreatedOn'));
                    text=mlreportgen.dom.Text(str,'SLReqReqCreatedOnName');
                case 'createdonvalue'
                    text=mlreportgen.dom.Text(datestr(reqInfo.createdOn),'SLReqReqCreatedOnValue');
                case 'modifiedbyname'
                    str=getString(message('Slvnv:slreq:ModifiedBy'));
                    text=mlreportgen.dom.Text(str,'SLReqReqModifiedByName');
                case 'modifiedbyvalue'
                    text=mlreportgen.dom.Text(reqInfo.modifiedBy,'SLReqReqModifiedByValue');
                case 'modifiedonname'
                    str=getString(message('Slvnv:slreq:ModifiedOn'));
                    text=mlreportgen.dom.Text(str,'SLReqReqModifiedOnName');
                case 'modifiedonvalue'
                    text=mlreportgen.dom.Text(datestr(reqInfo.modifiedOn),'SLReqReqModifiedOnValue');
                case 'refreshedonname'
                    str=getString(message('Slvnv:slreq:RefreshedOn'));
                    text=mlreportgen.dom.Text(str,'SLReqReqRefreshedOnName');
                case 'refreshedonvalue'
                    text=mlreportgen.dom.Text(datestr(reqInfo.synchronizedOn),'SLReqReqRefreshedOnValue');
                end
                if~isempty(text)
                    append(this,text);
                end
                moveToNextHole(this);
            end
        end
    end
end




