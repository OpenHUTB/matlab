classdef ReqLinkTypePart<slreq.report.ReportPart

    properties
        LinkType;
        LinkName;
    end

    methods

        function part=ReqLinkTypePart(p1,type,linkString)
            part=part@slreq.report.ReportPart(p1,'SLReqReqLinkTypePart');
            part.LinkType=type;
            part.LinkType.StyleName='SLReqReqLinkGroupTypeLinkTypeValueIcon';
            part.LinkName=mlreportgen.dom.Text(linkString,'SLReqReqLinkGroupTypeLinkTypeValueString');
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'type'
                    append(this,this.LinkType);
                case 'string'
                    append(this,this.LinkName);
                end
                moveToNextHole(this);
            end
        end
    end
end




