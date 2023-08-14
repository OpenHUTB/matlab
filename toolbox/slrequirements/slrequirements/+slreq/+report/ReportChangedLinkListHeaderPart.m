classdef ReportChangedLinkListHeaderPart<slreq.report.ReportPart


    properties
        NeedStyle=true;
    end

    methods

        function part=ReportChangedLinkListHeaderPart(p1)
            part=part@slreq.report.ReportPart(p1,'SLReqChangedLinkListHeaderPart');
            if strcmpi(p1.Type,'docx')||strcmpi(p1.Type,'pdf')
                part.NeedStyle=true;
            else
                part.NeedStyle=false;
            end
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'linknumname'
                    fillnum(this);
                case 'linknamename'
                    fillname(this);
                case 'changedtargetname'
                    fillchangedtarget(this);
                case 'storedinfoname'
                    fillstoredinfo(this);
                case 'actualinfoname'
                    fillactualinfo(this);
                end
                moveToNextHole(this);
            end
        end


        function fillnum(header)

            content=mlreportgen.dom.Text('#');
            if header.NeedStyle
                content.StyleName='SLReqChangedLinkListNumName';
            end
            append(header,content);
        end


        function fillname(header)
            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentChangedLinkListHeaderItem')));
            if header.NeedStyle
                content.StyleName='SLReqChangedLinkListItemName';
            end
            append(header,content);
        end


        function fillchangedtarget(header)
            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentChangedLinkListHeaderChangedTarget')));
            if header.NeedStyle
                content.StyleName='SLReqChangedLinkListChangedTargetName';
            end
            append(header,content);
        end


        function fillstoredinfo(header)
            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentChangedLinkListHeaderStoredInfo')));
            if header.NeedStyle
                content.StyleName='SLReqChangedLinkListStoredInfoName';
            end
            append(header,content);
        end


        function fillactualinfo(header)
            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentChangedLinkListHeaderActualInfo')));
            if header.NeedStyle
                content.StyleName='SLReqChangedLinkListActualInfoName';
            end
            append(header,content);
        end
    end
end
