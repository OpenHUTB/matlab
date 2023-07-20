classdef ReqSetAttributesPart<slreq.report.ReportPart

    properties
        ReqSetInfo;
        ReqSetImplementationRefreshed=false;
        ReqSetVerificationRefreshed=false;
    end

    methods

        function part=ReqSetAttributesPart(p1)
            part=part@slreq.report.ReportPart(p1,'SLReqReqSetAttributesPart');
            part.ReqSetInfo=p1.SetInfo;
        end


        function fill(this)
            reqSetInfo=this.ReqSetInfo;
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                switch lower(this.CurrentHoleId)
                case 'attributesname'
                    str=getString(message('Slvnv:slreq:Attributes'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetAttributesName');
                case 'filepathname'
                    str=getString(message('Slvnv:slreq:Filepath'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetFilePathName');
                case 'filepathvalue'
                    text=mlreportgen.dom.Text(reqSetInfo.filepath,'SLReqReqSetFilePathValue');
                case 'revisionname'
                    str=getString(message('Slvnv:slreq:Revision'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetRevisionName');
                case 'revisionvalue'
                    text=mlreportgen.dom.Text(reqSetInfo.revision,'SLReqReqSetRevisionValue');
                case 'createdbyname'
                    str=getString(message('Slvnv:slreq:CreatedBy'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetCreatedByName');
                case 'createdbyvalue'
                    text=mlreportgen.dom.Text(reqSetInfo.createdBy,'SLReqReqSetCreatedByValue');
                case 'createdonname'
                    str=getString(message('Slvnv:slreq:CreatedOn'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetCreatedOnName');
                case 'createdonvalue'
                    text=mlreportgen.dom.Text(datestr(reqSetInfo.createdOn),'SLReqReqSetCreatedOnValue');
                case 'modifiedbyname'
                    str=getString(message('Slvnv:slreq:ModifiedBy'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetModifiedByName');
                case 'modifiedbyvalue'
                    text=mlreportgen.dom.Text(reqSetInfo.modifiedBy,'SLReqReqSetModifiedByValue');
                case 'modifiedonname'
                    str=getString(message('Slvnv:slreq:ModifiedOn'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetModifiedOnName');
                case 'modifiedonvalue'
                    text=mlreportgen.dom.Text(datestr(reqSetInfo.modifiedOn),'SLReqReqSetModifiedOnValue');
                end
                if~isempty(text)
                    append(this,text);
                end
                moveToNextHole(this);
            end
        end

    end
end