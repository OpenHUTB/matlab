classdef ReqCustomAttributesPart<slreq.report.ReportPart

    properties
        ReqInfo;
        AllCustomAttributes;
    end

    methods

        function part=ReqCustomAttributesPart(p1)
            part=part@slreq.report.ReportPart(p1,'SLReqReqCustomAttributesPart');
            part.ReqInfo=p1.ReqInfo;
            part.AllCustomAttributes=p1.AllCustomAttributes;
        end



        function fill(this)

            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'customattname'
                    str=getString(message('Slvnv:slreq:CustomAttributes'));
                    text=mlreportgen.dom.Text(str,'SLReqReqCustomAttTitleName');
                    append(this,text);
                case 'customattlist'
                    fillcustomattlist(this);
                end
                moveToNextHole(this);
            end
        end


        function fillcustomattlist(this)
            if~isempty(this.AllCustomAttributes)
                allAttributes={this.AllCustomAttributes.name};
                reqInfo=this.ReqInfo;
                for index=1:length(allAttributes)
                    cAttr=allAttributes{index};
                    cAttValue=reqInfo.getAttribute(cAttr,true);
                    part=slreq.report.ReqCustomAttributePart(this,cAttr,cAttValue);
                    part.fill
                    append(this,part);
                end
            end
        end
    end
end