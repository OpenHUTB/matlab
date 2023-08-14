classdef ReqLinksByArtifactPart<slreq.report.ReportPart


    properties

        ReqInfo;
        ArtifactPath;
        InLinks;
        OutLinks;
    end

    methods

        function part=ReqLinksByArtifactPart(p1,artifactName,inLinks,outLinks)
            part=part@slreq.report.ReportPart(p1,'SLReqReqLinksByArtifactPart');
            part.ReqInfo=p1.ReqInfo;
            part.ArtifactPath=artifactName;
            part.InLinks=inLinks;
            part.OutLinks=outLinks;
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'artifactname'
                    fillname(this);
                case 'artifactvalue'
                    fillvalue(this);
                case 'artifactlinklist'
                    filllinklist(this)
                end
                moveToNextHole(this);
            end
        end


        function fillname(this)
            artiStr=mlreportgen.dom.Text(getString(message('Slvnv:slreq:Artifact')),'SLReqReqLinkGroupArtifactArtifactName');
            append(this,artiStr);
        end


        function fillvalue(this)
            fileH=slreq.uri.FilePathHelper(this.ArtifactPath);
            targetName=slreq.report.utils.getLinkTargetString(slreq.report.Report.ARTIFACT_LIST_TARGET);
            artiStr=mlreportgen.dom.InternalLink(targetName,fileH.getShortName,'SLReqReqLinkGroupArtifactArtifactValue');
            append(this,artiStr);
        end


        function filllinklist(this)

            headerPart=slreq.report.ReqLinkHeaderPart(this);
            headerPart.fill;
            append(this,headerPart);

            allInLinks=this.InLinks;
            this.filllinks(allInLinks,'incoming');
            allOutLinks=this.OutLinks;
            this.filllinks(allOutLinks,'outgoing');
        end


        function filllinks(this,allLinks,type)
            for lindex=1:length(allLinks)
                cLink=allLinks(lindex);
                if strcmpi(type,'incoming')
                    linkTarget=cLink.source;
                else
                    linkTarget=cLink.dest;
                end
                [~,linkTypeObj]=slreq.report.utils.getLinkTypeStr(cLink.type,type);
                if strcmp(linkTypeObj.rollupType,'verification')
                    statusIcon=slreq.report.utils.getLinkTestStatus(cLink);
                    testStatus=mlreportgen.dom.Image(statusIcon);
                else
                    testStatus='NA';
                end

                bodyPart=slreq.report.ReqLinkBodyPart(this,linkTarget,testStatus,type,cLink);
                bodyPart.fill;
                append(this,bodyPart);
            end
        end

    end
end
