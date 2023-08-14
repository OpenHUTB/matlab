classdef ReqLinkPart<slreq.report.ReportPart




    properties


        DomainInfo;

        LinkString;

        HyperLink;
        TestStatus;
        Artifact;
    end

    methods

        function part=ReqLinkPart(p1,linkTarget,testStatus,linkPropagation,linkInfo)
            part=part@slreq.report.ReportPart(p1,'SLReqReqLinkPart');


            reqAnchor=slreq.report.utils.getAnchorString(p1.ReqInfo);
            [part.DomainInfo,part.LinkString,part.HyperLink]=...
            slreq.report.utils.getLinkInfo(linkTarget,linkPropagation,linkInfo,reqAnchor);
            if nargin<3
                testStatus='NA';
            end
            part.TestStatus=testStatus;
            artifactUri=slreq.report.utils.getLinkArtifact(linkTarget);

            if isempty(artifactUri)


                artifactUri=linkInfo.destUri;
            end
            [~,artifactName,artifactExt]=fileparts(artifactUri);
            part.Artifact=[artifactName,artifactExt];
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'type'
                    filltype(this);
                case 'item'
                    fillitem(this);
                case 'artifactname'
                    fillartifact(this)
                end
                moveToNextHole(this);
            end
        end


        function filltype(reqlink)
            if isa(reqlink.DomainInfo,'mlreportgen.dom.Image')
                linkStr=reqlink.DomainInfo;
            else

                linkStr=mlreportgen.dom.Text(reqlink.DomainInfo);
            end
            linkStr.StyleName='SLReqReqLinkGroupTypeTypeValue';
            append(reqlink,linkStr);
            append(reqlink,' ');
        end


        function fillitem(reqlink)
            if~isempty(reqlink.HyperLink)
                append(reqlink,reqlink.HyperLink);
            end
            if isa(reqlink.TestStatus,'mlreportgen.dom.Image')
                append(reqlink,reqlink.TestStatus);
            end
        end


        function fillartifact(reqlink)
            targetName=slreq.report.utils.getLinkTargetString(slreq.report.Report.ARTIFACT_LIST_TARGET);
            linkStr=mlreportgen.dom.InternalLink(targetName,reqlink.Artifact,'SLReqReqLinkGroupTypeArtifactValue');

            append(reqlink,linkStr);
            append(reqlink,' ');
        end
    end

end
