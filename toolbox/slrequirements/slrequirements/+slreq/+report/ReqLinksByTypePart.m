classdef ReqLinksByTypePart<slreq.report.ReportPart





    properties

ReqInfo
LinkTypeName
LinkTypeObj
LinkTypeString
Links
LinkPropagation
LinkIcon
LinkTargetType
    end

    methods

        function part=ReqLinksByTypePart(...
            p1,typename,links,linkPropagation)
            part=part@slreq.report.ReportPart(...
            p1,'SLReqReqLinksByTypePart');
            part.ReqInfo=p1.ReqInfo;
            part.LinkTypeName=typename;
            part.Links=links;
            part.LinkPropagation=linkPropagation;
            [part.LinkTypeString,part.LinkTypeObj]=...
            slreq.report.utils.getLinkTypeStr(...
            typename,linkPropagation);
            if strcmp(linkPropagation,'incoming')
                iconPath=fullfile(matlabroot,...
                'toolbox','shared','dastudio',...
                'resources','informer','back_on_disabled.png');

                part.LinkTargetType='source';
            else
                iconPath=fullfile(matlabroot,...
                'toolbox','shared','dastudio',...
                'resources','informer','forward_on_disabled.png');
                part.LinkTargetType='dest';
            end
            part.LinkIcon=mlreportgen.dom.Image(iconPath);
        end

        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'linktype'
                    filltype(this);
                case 'linklist'
                    filllist(this);
                end
                moveToNextHole(this);
            end
        end

        function filltype(this)
            part=slreq.report.ReqLinkTypePart(...
            this,this.LinkIcon,this.LinkTypeString);
            part.fill();
            append(this,part);
        end

        function filllist(this)
            allLinks=this.Links;
            for index=1:length(allLinks)
                cLink=allLinks(index);
                linkTarget=cLink.(this.LinkTargetType);

                if strcmp(this.LinkTypeObj.rollupType,'verification')
                    statusIcon=slreq.report.utils.getLinkTestStatus(cLink);
                    testStatus=mlreportgen.dom.Image(statusIcon);
                else
                    testStatus='NA';
                end

                linkPart=slreq.report.ReqLinkPart(...
                this,linkTarget,testStatus,...
                this.LinkPropagation,cLink);
                linkPart.fill;
                append(this,linkPart);
            end
        end
    end
end
