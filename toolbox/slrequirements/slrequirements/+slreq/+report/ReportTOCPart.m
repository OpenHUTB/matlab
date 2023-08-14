classdef ReportTOCPart<slreq.report.ReportPart


    methods
        function part=ReportTOCPart(p1)
            part=part@slreq.report.ReportPart(p1,'SLReqTOCPart');
        end

        function fill(this)
            par=mlreportgen.dom.Paragraph(' ');
            par.Style={mlreportgen.dom.PageBreakBefore(true)};
            append(this,par);
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'toctitle'
                    str=getString(message('Slvnv:slreq:ReportContentTOC'));
                    tocHead=mlreportgen.dom.Text(str,'SLReqReportTOCHead');
                    append(this,tocHead);
                end
                moveToNextHole(this);
            end
        end
    end
end
