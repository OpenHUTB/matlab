classdef ElementNode<slreq.internal.tracediagram.data.Node

    properties(Access=private)
        LinkableId char
    end

    methods
        function this=ElementNode(itemInfo)








            [this.Id,this.ArtifactUri,this.ArtifactId]=this.getNodeKey(itemInfo);
            if isa(itemInfo,'slreq.data.Requirement')&&~itemInfo.isDirectLink
                this.Domain='linktype_rmi_slreq';
            else
                this.Domain=itemInfo.domain;
            end

            adapterManager=slreq.adapters.AdapterManager.getInstance;
            adapter=adapterManager.getAdapterByDomain(this.Domain);

            if isstruct(itemInfo)
                summary=adapter.getSummary(this.ArtifactUri,this.ArtifactId);
                tooltip=adapter.getTooltip(this.ArtifactUri,this.ArtifactId);
            else
                if isa(itemInfo,'slreq.data.SourceItem')
                    [~,summary,tooltip]=adapter.getIconSummaryTooltipFromSourceItem(itemInfo,this.ArtifactUri,this.ArtifactId);
                else
                    [~,summary,tooltip]=adapter.getIconSummaryTooltipFromReq(itemInfo,this.ArtifactUri,this.ArtifactId);
                end
            end

            if adapter.isResolved(this.ArtifactUri,this.ArtifactId)
                this.IconClass=this.getLinkTargetClass();
            else
                this.IconClass='unresolved-item';
            end

            this.NavigateId=this.ArtifactId;

            this.IsResolved=adapter.isResolved(this.ArtifactUri,this.ArtifactId);

            this.Summary=summary;
            this.Tooltip=tooltip;

            this.LinkableId=this.Id;
        end

        function[inLinks,outLinks]=getLinks(this)
            dataStruct.domain=this.Domain;
            dataStruct.id=this.ArtifactId;
            dataStruct.artifact=this.ArtifactUri;
            reqData=slreq.data.ReqData.getInstance;
            inLinks=slreq.data.Link.empty;
            outLinks=slreq.data.Link.empty;
            if strcmpi(dataStruct.domain,'linktype_rmi_slreq')
                dataReq=slreq.utils.getReqObjFromFullID(this.LinkableId);
                if~isempty(dataReq)
                    [inLinks,outLinks]=dataReq.getLinks;
                end
            else
                [inLinks,outLinks]=reqData.getLinksForNonReqItem(dataStruct);




                if strcmpi(dataStruct.domain,'linktype_rmi_matlab')
                    matlabDataStruct=dataStruct;
                    matlabDataStruct.id=['@',dataStruct.id];
                    [matlabInLinks,matlabOutLinks]=reqData.getLinksForNonReqItem(matlabDataStruct);
                    inLinks=[inLinks,matlabInLinks];
                    outLinks=[outLinks,matlabOutLinks];
                end
            end
        end

        function linkTargetClass=getLinkTargetClass(this)
            linkTargetClass=getLinkTargetClass@slreq.internal.tracediagram.data.Node(this);

            domain=this.Domain;
            artifact=this.ArtifactUri;
            id=this.ArtifactId;
            if strcmpi(domain,'linktype_rmi_simulink')
                linkTargetClass=slreq.utils.getSLType(artifact,id);
            elseif strcmpi(domain,'linktype_rmi_slreq')
                reqObj=slreq.utils.getReqObjFromFullID(this.Id);
                if~isempty(reqObj)
                    if reqObj.external
                        linkTargetClass='slreq-ex';
                    elseif reqObj.isJustification
                        linkTargetClass='slreq-justification';
                    else
                        linkTargetClass='linktype-rmi-slreq';
                    end
                else
                    linkTargetClass='unresolved-item';
                end
            end
        end

    end
end


