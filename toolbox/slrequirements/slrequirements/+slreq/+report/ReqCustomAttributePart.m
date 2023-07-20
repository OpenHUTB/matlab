classdef ReqCustomAttributePart<slreq.report.ReportPart

    properties
        AttName;
        AttValue;
    end

    methods

        function part=ReqCustomAttributePart(p1,attName,attValue)
            part=part@slreq.report.ReportPart(p1,'SLReqReqCustomAttributePart');
            part.AttName=attName;
            part.AttValue=attValue;
        end


        function fill(this)
            cAttr=this.AttName;
            cAttValue=this.AttValue;
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                switch lower(this.CurrentHoleId)
                case 'attname'
                    text=mlreportgen.dom.Text(cAttr,'SLReqReqCustomAttName');
                case 'attvalue'
                    text=cAttValue;
                    if isempty(text)
                        text=' ';
                    else
                        text=mlreportgen.dom.Text(char(string(text)),'SLReqReqCustomAttValue');
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




