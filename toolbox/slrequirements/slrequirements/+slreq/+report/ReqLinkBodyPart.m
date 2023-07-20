classdef ReqLinkBodyPart<slreq.report.ReportPart


    properties


        DomainInfo;

        LinkString;

        HyperLink;
        TestStatus;
        Artifact;
        OutIcon=fullfile(matlabroot,'toolbox','shared','dastudio',...
        'resources','informer','forward_on_disabled.png');
        InIcon=fullfile(matlabroot,'toolbox','shared','dastudio',...
        'resources','informer','back_on_disabled.png');
        LinkPropagation;
        LinkInfo;
    end

    methods

        function part=ReqLinkBodyPart(p1,linkTarget,testStatus,linkPropagation,linkInfo)
            part=part@slreq.report.ReportPart(p1,'SLReqReqLinkBodyPart');
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
            part.LinkPropagation=linkPropagation;
            [~,artifactName,artifactExt]=fileparts(artifactUri);
            part.Artifact=[artifactName,artifactExt];
            part.LinkInfo=linkInfo;
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'type'
                    filltype(this);
                case 'item'
                    fillitem(this);
                case 'linkdirection'
                    filldirection(this);
                case 'linktype'
                    filllinktype(this);
                end
                moveToNextHole(this);
            end
        end


        function filldirection(this)
            if strcmp(this.LinkPropagation,'incoming')

                imageIcon=mlreportgen.dom.Image(this.InIcon);
            elseif strcmp(this.LinkPropagation,'outgoing')

                imageIcon=mlreportgen.dom.Image(this.OutIcon);
            end
            imageIcon.StyleName='SLREQSpecialStrings';
            append(this,imageIcon);
        end


        function filllinktype(this)
            typeString=slreq.report.utils.getLinkTypeStr(this.LinkInfo.type,this.LinkPropagation);
            linkType=mlreportgen.dom.Text(typeString,'SLReqReqLinkGroupArtifactLinkTypeValue');
            append(this,linkType);
        end


        function filltype(reqlink)
            if isa(reqlink.DomainInfo,'mlreportgen.dom.Image')
                linkStr=reqlink.DomainInfo;
                linkStr.StyleName='SLReqReqLinkGroupArtifactTypeValue';
            else

                linkStr=mlreportgen.dom.Text(reqlink.DomainInfo);
                linkStr.StyleName='SLReqReqLinkGroupArtifactTypeValue';
            end
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
    end
end
