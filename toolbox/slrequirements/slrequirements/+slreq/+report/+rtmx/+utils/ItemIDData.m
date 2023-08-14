classdef ItemIDData<handle
    properties
        FullID='';

        Desc='';

        LongDesc='';


        Domain='';

        Type='';

        SubType='';

        IsExcludeFromHISL_0070=false;

        UUID;

        ItemID='';

        LinkTargetsAsSrc;

        LinkTargetsAsDst;


        LinksAsSrc;

        LinksAsDst;


        ParentID='';


        RealParentID='';


        Level=0;


        ChildrenIDs={};


        IsResolved=true;

        IconType;

        IsRoot=false;

        ArtifactID;

        Link='HasNoLink';

        SubsysNoLinkedContent='Yes';
        ExpectedMissingLinks='NA';



        LinkedArtiToStatsMapAsDst;
        LinkedArtiToStatsMapAsSrc;

        LinkedArtiToStatsMapAsDstAsArti;
        LinkedArtiToStatsMapAsSrcAsArti;

        StatsAsSrc=slreq.report.rtmx.utils.Misc.getLinkStatsStruct;
        StatsAsDst=slreq.report.rtmx.utils.Misc.getLinkStatsStruct;

        StatsAsSrc_Verify=0;
        StatsAsSrc_Implement=0;
        StatsAsSrc_Relate=0;
        StatsAsSrc_Refine=0;
        StatsAsSrc_Derive=0;
        StatsAsSrc_Total=0;

        StatsAsDst_Verify=0;
        StatsAsDst_Implement=0;
        StatsAsDst_Relate=0;
        StatsAsDst_Refine=0;
        StatsAsDst_Derive=0;
        StatsAsDst_Total=0;



        ChildrenStatsAsSrc=slreq.report.rtmx.utils.Misc.getLinkStatsStruct;
        ChildrenStatsAsDst=slreq.report.rtmx.utils.Misc.getLinkStatsStruct;



        TotalStatsAsSrc=slreq.report.rtmx.utils.Misc.getLinkStatsStruct;
        TotalStatsAsDst=slreq.report.rtmx.utils.Misc.getLinkStatsStruct;

        HasChangeIssueLinksAsSrc;
        HasChangeIssueLinksAsDst;
        HasChangeIssue=false;
HasChangedLink
ChangedLinks
        Change='HasNoChangeIssue';
ChangedLinksAsSrc
ChangedLinksAsDst

        Keywords={};
        Attributes={};
    end

    methods
        function this=ItemIDData(id)
            if nargin==1
                this.FullID=id;
            end
            this.ChangedLinksAsSrc=containers.Map('KeyType','char','ValueType','any');
            this.ChangedLinksAsDst=containers.Map('KeyType','char','ValueType','any');
            this.ChangedLinks=containers.Map('KeyType','char','ValueType','any');
            this.LinkedArtiToStatsMapAsDst=containers.Map('KeyType','char','ValueType','any');
            this.LinkedArtiToStatsMapAsSrc=containers.Map('KeyType','char','ValueType','any');
            this.LinkedArtiToStatsMapAsDstAsArti=containers.Map('KeyType','char','ValueType','any');
            this.LinkedArtiToStatsMapAsSrcAsArti=containers.Map('KeyType','char','ValueType','any');

            this.LinkTargetsAsSrc=containers.Map('KeyType','char','ValueType','any');

            this.LinkTargetsAsDst=containers.Map('KeyType','char','ValueType','any');


            this.LinksAsSrc=containers.Map('KeyType','char','ValueType','any');

            this.LinksAsDst=containers.Map('KeyType','char','ValueType','any');

            this.LinkedArtiToStatsMapAsDst=containers.Map('KeyType','char','ValueType','any');
            this.LinkedArtiToStatsMapAsSrc=containers.Map('KeyType','char','ValueType','any');

            this.LinkedArtiToStatsMapAsDstAsArti=containers.Map('KeyType','char','ValueType','any');
            this.LinkedArtiToStatsMapAsSrcAsArti=containers.Map('KeyType','char','ValueType','any');

            this.HasChangeIssueLinksAsSrc=containers.Map('KeyType','char','ValueType','any');
            this.HasChangeIssueLinksAsDst=containers.Map('KeyType','char','ValueType','any');

            this.HasChangeIssue=false;
        end

        function out=exportData(this)
            allProperties=properties(this);
            out=containers.Map('KeyType','char','ValueType','any');
            for index=1:length(allProperties)
                cProp=allProperties{index};
                if strcmpi(cProp,'keywords')
                    for kIndex=1:length(this.Keywords)
                        cKeyword=this.Keywords{kIndex};
                        out(['keywords##',cKeyword])=true;
                    end
                elseif strcmpi(cProp,'attributes')
                    for aIndex=1:length(this.Attributes)
                        cAttribute=this.Attributes{aIndex};
                        out(['attributes##',cAttribute])=true;
                    end
                elseif strcmpi(cProp,'CustomAttributesInfo')
                    if~strcmpi(this.Type,'ReqSet')
                        for cIndex=1:length(this.CustomAttributesInfo)
                            cCustomAttribute=this.CustomAttributesInfo(cIndex);
                            if isfield(cCustomAttribute,'Value')
                                out(['customattribute##',cCustomAttribute.Name])=cCustomAttribute.Value;
                            else
                                out(['customattribute##',cCustomAttribute.Name])=cCustomAttribute.DefaultValue;
                            end

                        end
                    end
                else
                    out(cProp)=this.(cProp);
                end
            end
        end

        function addLinkItemAsSrc(this,linkItem)
            this.LinksAsSrc(linkItem.FullID)=true;
        end

        function addLinkItemAsDst(this,linkItem)
            this.LinksAsDst(linkItem.FullID)=true;
        end

        function updateLinkInfo(this,incomingLinks,outgoingLinks)


            dataExporter=slreq.report.rtmx.utils.RTMXReqDataExporter.getInstance();
            for index=1:length(incomingLinks)

                cLink=incomingLinks(index);
                linkData=dataExporter.getOrCreateLinkData(cLink);
                linkData.IsDestinationResolved=true;
                linkData.DstID=[this.ArtifactID,'#:#',this.ItemID];
                linkData.DstArtifact=this.ArtifactID;
                dataExporter.addLinkToDstArtifact(this.ArtifactID,cLink.getFullID)

                this.addLinkItemAsDst(linkData);

                linkType=cLink.type;
                isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(cLink.getLinkSet(),linkType);
                if isStereotype

                    linkType=slreq.internal.ProfileTypeBase.getMetaAttrValue(cLink,'BaseBehavior');
                    if isempty(linkType)

                        linkType=strrep(cLink.type,'.','_');
                    end
                end

                if~isfield(this.StatsAsDst,linkType)
                    this.StatsAsDst.(linkType)=0;
                end
                this.StatsAsDst.(linkType)=this.StatsAsDst.(linkType)+1;

                this.StatsAsDst_Total=this.StatsAsDst_Total+1;
                this.StatsAsDst.Total=this.StatsAsDst.Total+1;

            end

            for index=1:length(outgoingLinks)
                cLink=outgoingLinks(index);
                linkData=dataExporter.getOrCreateLinkData(cLink);
                linkData.IsSourceResolved=true;
                linkData.SrcID=[this.ArtifactID,'#:#',this.ItemID];
                linkData.SrcArtifact=this.ArtifactID;
                dataExporter.addLinkToSrcArtifact(this.ArtifactID,cLink.getFullID);
                this.addLinkItemAsSrc(linkData);

                linkType=cLink.type;
                isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(cLink.getLinkSet(),linkType);

                if isStereotype

                    linkType=slreq.internal.ProfileTypeBase.getMetaAttrValue(cLink,'BaseBehavior');
                    if isempty(linkType)

                        linkType=strrep(cLink.type,'.','_');
                    end
                end

                if~isfield(this.StatsAsSrc,linkType)
                    this.StatsAsSrc.(linkType)=0;
                end

                this.StatsAsSrc.(linkType)=this.StatsAsSrc.(linkType)+1;

                this.StatsAsSrc_Total=this.StatsAsSrc_Total+1;
                this.StatsAsSrc.Total=this.StatsAsSrc.Total+1;

            end

        end

    end
    methods(Static)

    end
end

