classdef ReqKeywordsPart<slreq.report.ReportPart

    properties
        ReqInfo;
    end

    methods

        function part=ReqKeywordsPart(p1)
            if strcmpi(p1.Type,'docx')&&isempty(p1.ReqInfo.keywords)
                partName='SLReqReqKeywordEmptyPart';
            else
                partName='SLReqReqKeywordPart';
            end

            part=part@slreq.report.ReportPart(p1,partName);
            part.ReqInfo=p1.ReqInfo;
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                switch lower(this.CurrentHoleId)
                case 'keywordname'
                    str=getString(message('Slvnv:slreq:Keywords'));
                    text=mlreportgen.dom.Text(str,'SLReqReqKeywordName');
                case 'keywordvalue'
                    keyWords=this.ReqInfo.keywords;
                    if isempty(this.ReqInfo.keywords)
                        text=' ';
                    else
                        text=mlreportgen.dom.Text(strjoin(keyWords,';'),'SLReqReqKeywordValue');
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




