classdef ReportAppendixPart<slreq.report.ReportPart


    properties(Constant)
        ArtifactList=containers.Map('KeyType','char','ValueType','any');
        LinkList=containers.Map('KeyType','char','ValueType','any');
    end

    methods

        function part=ReportAppendixPart(doc)

            part=part@slreq.report.ReportPart(doc,'SLReqAppendixPart');
        end


        function fill(this)
            slreq.utils.updateProgress(this.ShowUI,...
            'update',...
            getString(message('Slvnv:slreq:ReportGenProgressBarFinishFill')));
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'appendixname'
                    this.fillAppendixTitle();
                case 'appendixvalue'
                    this.fillArtifactList();
                    if this.ReportOptions.includes.changeInformation
                        this.fillLinkList()
                    end
                end
                moveToNextHole(this);
            end
        end


        function fillAppendixTitle(this)
            p=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentAppendix')),...
            'SLReqReportChapter');
            append(this,p);
        end


        function fillArtifactList(this)
            if this.ArtifactList.Count~=0
                listspart=slreq.report.ReportArtifactListsPart(this,this.ArtifactList);
                listspart.fill();
                append(this,listspart);
            end

        end


        function fillLinkList(this)
            if this.LinkList.Count~=0
                listpart=slreq.report.ReportChangedLinkListPart(this,this.LinkList);
                listpart.fill();
                append(this,listpart);
            end
        end
    end
end
