classdef LinkData<handle
    properties
        FullID='';

        Desc='';

        Type='';

        SubType='';

        LinkSet='';

        IsSourceResolved;

        IsDestinationResolved;

        SrcID='';

        DstID='';


        SrcTextLines={};
        DstTextLines={};

        SrcLinkID={};
        DstLinkID={};

        HasChangedSource;

        HasChangedDestination;

        LinkSetID;

        SrcArtifact='';
        DstArtifact='';

        Change="WithoutChangeIssue"

        Domain='link';

ArtifactID

UUID

        SrcDomain='';

        DstDomain='';
    end

    methods
        function this=LinkData(id)
            this.FullID=id;
        end

        function out=exportData(this)

        end
    end


    methods(Static)
        function linkData=createLinkDataFromLink(dataLink)
            id=dataLink.getFullID;
            linkSet=dataLink.getLinkSet;
            linkData=slreq.report.rtmx.utils.LinkData(id);

            linkData.Desc=dataLink.getDisplayLabel();

            linkData.LinkSetID=linkSet.filepath;
            linkData.ArtifactID=linkSet.filepath;
            linkData.UUID=dataLink.getUuid;

            ctvisitor=slreq.analysis.ChangeTrackingRefreshVisitor();
            ctvisitor.visitLink(dataLink);
            linkData.HasChangedDestination=dataLink.destinationChangeStatus.isFail;
            linkData.HasChangedSource=dataLink.sourceChangeStatus.isFail;
            if linkData.HasChangedDestination||linkData.HasChangedSource
                linkData.Change='WithChangeIssue';
            end

            isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(linkSet,dataLink.type);
            if isStereotype
                linkData.SubType=dataLink.type;
                baseBehavior=slreq.internal.ProfileTypeBase.getMetaAttrValue(dataLink,'BaseBehavior');
                if isempty(baseBehavior)
                    linkData.Type=dataLink.type;
                else
                    linkData.Type=baseBehavior;
                end
            else
                mfLinkType=slreq.data.ReqData.getInstance.getLinkType(dataLink.type);
                if mfLinkType.isBuiltin
                    linkData.Type=dataLink.type;
                    linkData.SubType='#Other#';
                else
                    linkData.SubType=dataLink.type;
                    linkData.Type=mfLinkType.superType.typeName;
                end
            end
        end
    end
end

