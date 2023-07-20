
classdef DashboardReport<dashboard.internal.report.DashboardReportBase

    methods
        function outPath=generate(this,artifactScope,launchReport,debug)
            ProjectName=this.Project.Name;

            import mlreportgen.dom.*;
            import mlreportgen.report.*;

            if(debug)
                this.Report.Debug=true;
                assignin("base","rpt",this.Report);
            end

            tp=TitlePage;
            tp.Title=message("dashboard:report:Report",this.DashboardLayout.Name).getString();
            tp.Author='';
            tp.PubDate='';

            p=Paragraph;
            p.append(Text(sprintf('%s\n',message("dashboard:report:Date",date).getString())));
            p.append(Text(sprintf('%s\n',message("dashboard:report:Project",ProjectName).getString())));
            p.append(Text(sprintf('%s\n',message("dashboard:report:MLVersion",version).getString())));

            tp.Subtitle=p;
            tp.Subtitle.Style={
            HAlign('center'),...
            WhiteSpace('preserve'),...
            OuterMargin('0in','0in','1in','1in')
            };

            this.Report.append(tp);
            this.Report.append(TableOfContents);

            scopeArtifacts=this.getScopeArtifacts(artifactScope);

            if isempty(scopeArtifacts)
                error(message("dashboard:report:NoArtifactsToGenerateReportFor",this.DashboardLayout.Name));
            end

            for i=1:length(scopeArtifacts)
                section=Section;
                section.Title=scopeArtifacts(i).Label;
                artifactSummary=dashboard.internal.report.ArtifactSummary(this,[]);
                artifactSummary.addToReport(section,scopeArtifacts(i));

                this.generateAndAdd(section,this.DashboardLayout.Widgets,scopeArtifacts(i));
                this.Report.append(section);
            end

            this.Report.close();
            outPath=this.Report.OutputPath;

            if(launchReport)
                this.Report.rptview();
            end
        end
    end
end

