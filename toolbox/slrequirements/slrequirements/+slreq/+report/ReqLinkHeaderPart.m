classdef ReqLinkHeaderPart<slreq.report.ReportPart


    properties

    end

    methods

        function part=ReqLinkHeaderPart(p1)
            part=part@slreq.report.ReportPart(p1,'SLReqReqLinkHeaderPart');
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'linkeditem'
                    fillitem(this);
                case 'linkedtype'
                    filltype(this);
                end
                moveToNextHole(this);
            end
        end


        function fillitem(header)
            content=mlreportgen.dom.Text(getString(message('Slvnv:slreq:ReportContentLinkedItem')));
            content.StyleName='SLReqReqLinkGroupArtifactLinkedItemName';
            append(header,content);
        end


        function filltype(header)
            content=mlreportgen.dom.Text(getString(message('Slvnv:slreq:ReportContentLinkType')));
            content.StyleName='SLReqReqLinkGroupArtifactLinkedTypeName';
            append(header,content);
        end
    end

end
