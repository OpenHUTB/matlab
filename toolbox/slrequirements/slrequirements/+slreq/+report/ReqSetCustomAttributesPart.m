classdef ReqSetCustomAttributesPart<slreq.report.ReportPart

    properties
        ReqSetInfo;
        AllCustomAttributes;
    end

    methods

        function part=ReqSetCustomAttributesPart(p1)
            part=part@slreq.report.ReportPart(p1,'SLReqReqSetCustomAttributesPart');
            part.ReqSetInfo=p1.SetInfo;
            part.AllCustomAttributes=p1.AllCustomAttributes;
        end


        function fill(this)

            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'customattributeregistry'
                    str=getString(message('Slvnv:slreq:CustomAttributeRegistries'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetCustomAttributesName');
                    append(this,text);
                case 'customattlist'
                    fillcustomattlist(this);
                end
                moveToNextHole(this);
            end
        end


        function fillcustomattlist(this)
            allAttributes=this.AllCustomAttributes;
            for index=1:length(allAttributes)
                cAttr=allAttributes(index);
                part=slreq.report.ReqSetCustomAttributePart(this,cAttr);
                part.fill
                append(this,part);
            end
        end

    end
end