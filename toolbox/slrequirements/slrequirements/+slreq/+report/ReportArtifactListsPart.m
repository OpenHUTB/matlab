classdef ReportArtifactListsPart<slreq.report.ReportPart


    properties
        ArtifactLists;
    end

    methods

        function part=ReportArtifactListsPart(p1,artifactLists)
            part=part@slreq.report.ReportPart(p1,'SLReqArtifactListsPart');
            part.ArtifactLists=artifactLists;
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'artifactlisttitle'
                    filltitle(this);
                case 'artifactlists'
                    filllists(this);
                end
                moveToNextHole(this);
            end
        end


        function filltitle(this)
            artiBookMark=mlreportgen.dom.LinkTarget(slreq.report.Report.ARTIFACT_LIST_TARGET);
            artiTitle=mlreportgen.dom.Heading(2,artiBookMark);
            artiStr=getString(message('Slvnv:slreq:ReportContentArtifactLists'));
            artiTitle.append(artiStr);

            artiTitle.StyleName='SLReqArtifactListsName';
            artiTitle.Style={mlreportgen.dom.CounterInc('subsection'),...
            mlreportgen.dom.WhiteSpace('preserve'),...
            mlreportgen.dom.OuterMargin('0in','0pt','0pt','0pt'),...
            mlreportgen.dom.LineSpacing(1)};
            append(this,artiTitle);
        end


        function filllists(this)
            allDomains=slreq.report.ReportArtifactData.ARTIFACT_DOMAIN_LIST;
            for index=1:length(allDomains)
                domainType=allDomains{index};
                if isKey(this.ArtifactLists,domainType)
                    listpart=slreq.report.ReportArtifactListPart(this,domainType,this.ArtifactLists(domainType));
                    listpart.fill();
                    append(this,listpart);
                end
            end
        end
    end
end