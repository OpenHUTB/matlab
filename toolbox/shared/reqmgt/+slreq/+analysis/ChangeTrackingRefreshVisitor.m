classdef ChangeTrackingRefreshVisitor<slreq.analysis.ChangeTrackingVisitor










    methods

        function this=ChangeTrackingRefreshVisitor()

        end


        function visitRequirementSet(this,dataReqSet)
            allReqs=dataReqSet.getAllItems;
            for cReq=allReqs
                this.visitRequirement(cReq);
            end
        end


        function visitRequirement(this,dataReq)

            this.resetChangedLinkMap(dataReq);


            [inDataLinks,outDataLinks]=dataReq.getLinks;



            reqAdapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
            [~,reqInfo]=reqAdapter.getRevisionInfo(dataReq);




            this.visitLinksGivenDestination(inDataLinks,reqInfo,slreq.analysis.ChangeStatus.Undecided);
            this.visitLinksGivenSource(outDataLinks,reqInfo,slreq.analysis.ChangeStatus.Undecided);


            this.refreshMapForReqAsDst(dataReq,inDataLinks);
            this.refreshMapForReqAsSrc(dataReq,outDataLinks);
        end



        function visitRequirementToBeDeleted(this,dataReq)

            this.resetChangedLinkMap(dataReq);


            [inDataLinks,outDataLinks]=dataReq.getLinks;



            reqInfo=slreq.utils.DefaultValues.getRevisionInfo();




            this.visitLinksGivenDestination(inDataLinks,reqInfo,slreq.analysis.ChangeStatus.InvalidLink);
            this.visitLinksGivenSource(outDataLinks,reqInfo,slreq.analysis.ChangeStatus.InvalidLink);


            this.refreshMapForReqAsDst(dataReq,inDataLinks);
            this.refreshMapForReqAsSrc(dataReq,outDataLinks);
        end


        function visitLinkSet(this,dataLinkSet)


















            dataLinkSet.resetChangeInfo();

            allSources=dataLinkSet.getLinkedItems;
            for sIndex=1:length(allSources)
                cSrc=allSources(sIndex);
                [status,srcInfo]=getSrcRevision(cSrc);
                allLinks=cSrc.getLinks;
                this.visitLinksGivenSource(allLinks,srcInfo,status);
            end
            dataLinkSet.changeStatus=slreq.analysis.ChangeStatus.UpToDate;
        end


        function visitLink(this,dataLink)

            [srcStatus,srcInfo]=getSrcRevision(dataLink);
            [dstStatus,dstInfo]=getDstRevision(dataLink);
            knownInfo.knownSource=true;
            knownInfo.knownDestination=true;
            knownInfo.srcInfo.revision=srcInfo.revision;
            knownInfo.srcInfo.uuid=srcInfo.uuid;
            knownInfo.srcInfo.timestamp=srcInfo.timestamp;
            knownInfo.dstInfo.revision=dstInfo.revision;
            knownInfo.dstInfo.timestamp=dstInfo.timestamp;
            knownInfo.dstInfo.uuid=dstInfo.uuid;
            knownInfo.srcStatus=srcStatus;
            knownInfo.dstStatus=dstStatus;

            this.visitLinkWithGivenInfo(dataLink,knownInfo);
        end
    end

    methods(Access=private)


        function visitLinkWithGivenInfo(this,dataLink,knownInfo)







            if isempty(dataLink)
                return;
            end




            srcInfo=knownInfo.srcInfo;
            srcStatus=knownInfo.srcStatus;
            dstInfo=knownInfo.dstInfo;
            dstStatus=knownInfo.dstStatus;

            this.updateSrc(dataLink,srcStatus,srcInfo);
            this.updateDst(dataLink,dstStatus,dstInfo);
































            this.updateMap(dataLink,srcInfo,dstInfo);




            linkSet=dataLink.getLinkSet;
            linkSet.updateChangedLink(dataLink);
        end


        function visitLinksGivenSource(this,dataLinks,srcInfo,srcStatus)


            if~isempty(dataLinks)
                knownInfo.knownSource=true;
                knownInfo.srcInfo=srcInfo;
                knownInfo.srcStatus=srcStatus;

                for index=1:length(dataLinks)
                    cDataLink=dataLinks(index);
                    [dstStatus,dstInfo]=getDstRevision(cDataLink);
                    knownInfo.dstInfo=dstInfo;
                    knownInfo.dstStatus=dstStatus;

                    this.visitLinkWithGivenInfo(cDataLink,knownInfo);

                end
            end
        end


        function visitLinksGivenDestination(this,dataLinks,dstInfo,dstStatus)


            if~isempty(dataLinks)
                knownInfo.knownDestination=true;
                knownInfo.dstInfo=dstInfo;
                knownInfo.dstStatus=dstStatus;
                for index=1:length(dataLinks)
                    cDataLink=dataLinks(index);
                    [srcStatus,srcInfo]=getSrcRevision(cDataLink);
                    knownInfo.srcInfo=srcInfo;
                    knownInfo.srcStatus=srcStatus;


                    this.visitLinkWithGivenInfo(cDataLink,knownInfo);
                end
            end
        end






        function updateDst(this,dataLink,dstStatus,dstInfo)
            dataLink.currentDestinationRevision=dstInfo.revision;
            dataLink.currentDestinationTimeStamp=dstInfo.timestamp;

            if dstStatus.isUndecided
                linkUuid=dataLink.getUuid;
                if dstInfo.timestamp==dataLink.linkedDestinationTimeStamp&&...
                    strcmp(dstInfo.revision,dataLink.linkedDestinationRevision)
                    dataLink.destinationChangeStatus=slreq.analysis.ChangeStatus.Pass;
                    this.removeChangedLinkAsDst(dstInfo.uuid,linkUuid);
                else
                    dataLink.destinationChangeStatus=slreq.analysis.ChangeStatus.Fail;
                    this.addChangedLinkAsDst(dstInfo.uuid,linkUuid);
                end
            else
                dataLink.destinationChangeStatus=dstStatus;
            end
        end


        function updateSrc(this,dataLink,srcStatus,srcInfo)
            dataLink.currentSourceRevision=srcInfo.revision;
            dataLink.currentSourceTimeStamp=srcInfo.timestamp;
            if srcStatus.isUndecided
                linkUuid=dataLink.getUuid;
                srcUuid=srcInfo.uuid;
                if srcInfo.timestamp==dataLink.linkedSourceTimeStamp&&...
                    strcmp(srcInfo.revision,dataLink.linkedSourceRevision)
                    dataLink.sourceChangeStatus=slreq.analysis.ChangeStatus.Pass;
                    this.removeChangedLinkAsSrc(srcUuid,linkUuid);
                else
                    dataLink.sourceChangeStatus=slreq.analysis.ChangeStatus.Fail;
                    this.addChangedLinkAsSrc(srcInfo.uuid,linkUuid);
                end
            else
                dataLink.sourceChangeStatus=srcStatus;
            end
        end
    end
end




function[status,info]=getDstRevision(dataLink)
    if slreq.utils.hasValidDest(dataLink)
        dst=dataLink.dest;
        if isa(dst,'slreq.data.Requirement')


            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
        else
            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(dst.domain);
        end
        [status,info]=adapter.getRevisionInfo(dst);
    else
        status=slreq.analysis.ChangeStatus.InvalidLink;
        info=slreq.utils.DefaultValues.getRevisionInfo();
    end
end


function[status,info]=getSrcRevision(dataLinkOrDataSource)
    if isa(dataLinkOrDataSource,'slreq.data.Link')
        dataSource=dataLinkOrDataSource.source;
    elseif isa(dataLinkOrDataSource,'slreq.data.SourceItem')
        dataSource=dataLinkOrDataSource;
    end

    if dataSource.isValid
        adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(dataSource.domain);
        [status,info]=adapter.getRevisionInfo(dataSource);
    else
        status=slreq.analysis.ChangeStatus.InvalidLink;
        info=slreq.utils.DefaultValues.getRevisionInfo();
    end
end

