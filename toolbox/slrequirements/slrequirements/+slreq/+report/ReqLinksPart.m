classdef ReqLinksPart<slreq.report.ReportPart





    properties

ReqInfo
LinkInfo
    end

    methods

        function part=ReqLinksPart(p1,linkInfo)

            if isempty(linkInfo.totallinks)
                partName='SLReqReqLinksEmtpyPart';
            else
                partName='SLReqReqLinksPart';
            end
            part=part@slreq.report.ReportPart(p1,partName);
            part.ReqInfo=p1.ReqInfo;
            part.LinkInfo=linkInfo;
        end


        function fill(this)
            outMap=this.LinkInfo.outMap;
            grouplist=this.LinkInfo.grouplist;
            totallinks=this.LinkInfo.totallinks;
            groupByArtifact=this.LinkInfo.groupByArtifact;

            inType='#?<-?#';
            outType='#?->?#';
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))

                switch lower(this.CurrentHoleId)
                case 'linksname'
                    if sum(totallinks)~=0||this.ReportOptions.includes.emptySections
                        str=getString(message('Slvnv:slreq:Links'));
                        text=mlreportgen.dom.Text(str,'SLReqReqLinksName');
                        append(this,text);
                    end
                case 'linklist'

                    if sum(totallinks)~=0
                        for index=1:length(grouplist)
                            cGroup=grouplist{index};
                            inKey=[cGroup,inType];
                            outKey=[cGroup,outType];
                            inLinks='';
                            outLinks='';
                            if isKey(outMap,inKey)
                                inLinks=outMap(inKey);
                            end

                            if isKey(outMap,outKey)
                                outLinks=outMap(outKey);
                            end

                            if groupByArtifact

                                if~isempty(inLinks)||~isempty(outLinks)
                                    cpart=...
                                    slreq.report.ReqLinksByArtifactPart(...
                                    this,cGroup,inLinks,outLinks);
                                    cpart.fill();
                                    append(this,cpart);
                                end
                            else

                                if~isempty(inLinks)
                                    cinpart=slreq.report.ReqLinksByTypePart(...
                                    this,cGroup,inLinks,'incoming');
                                    cinpart.fill();
                                    append(this,cinpart);
                                end

                                if~isempty(outLinks)
                                    coutpart=slreq.report.ReqLinksByTypePart(...
                                    this,cGroup,outLinks,'outgoing');
                                    coutpart.fill();
                                    append(this,coutpart);
                                end
                            end
                        end
                    end
                end
                moveToNextHole(this);
            end
        end
    end
end
