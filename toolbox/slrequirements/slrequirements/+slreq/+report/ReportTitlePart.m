classdef ReportTitlePart<slreq.report.ReportPart



    methods


        function out=setTitleText(docpart)
            out=mlreportgen.dom.Text(docpart.ReportOptions.titleText,'SLReqReportTitle');
        end


        function out=setAuthor(docpart)
            if~isempty(docpart.ReportOptions.authors)
                out=mlreportgen.dom.Text(docpart.ReportOptions.authors,'SLReqReportTitleAttribute');
            end
        end


        function out=setPublishedOn(docpart)%#ok<MANU>
            text=datestr(datetime('today'),'Local');
            out=mlreportgen.dom.Text(text,'SLReqReportTitleAttribute');
        end
    end


    methods
        function part=ReportTitlePart(rpt)
            part=part@slreq.report.ReportPart(rpt,'SLReqTitlePart');
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'title'
                    append(this,this.setTitleText);
                case 'authorname'
                    if~isempty(this.ReportOptions.authors)
                        str=getString(message('Slvnv:slreq:ReportContentAuthors'));
                        authorstr=mlreportgen.dom.Text(str,'SLReqReportTitleAttribute');
                        append(this,authorstr);
                    end
                case 'authorvalue'
                    if~isempty(this.ReportOptions.authors)
                        append(this,this.setAuthor);
                    end
                case 'publishdatename'
                    if this.ReportOptions.includes.publishedDate
                        text=getString(message('Slvnv:slreq:ReportContentPublishedOn'));
                        publishstr=mlreportgen.dom.Text(text,'SLReqReportTitleAttribute');
                        append(this,publishstr);
                    end
                case 'publishdatevalue'
                    if this.ReportOptions.includes.publishedDate
                        append(this,this.setPublishedOn);
                    end
                end
                moveToNextHole(this);
            end
        end
    end
end
