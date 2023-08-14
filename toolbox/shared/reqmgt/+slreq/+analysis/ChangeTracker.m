classdef ChangeTracker<handle







    properties(SetAccess=?slreq.analysis.ChangeTrackingVisitor,GetAccess=public)





FailedSrcReq2LinkMap


FailedDstReq2LinkMap











Req2FailedSrcLinkMap






InvalidOutgoingLinkMap



InvalidIncomingLinkMap

    end


    methods

        function this=ChangeTracker()

            this.reset();
        end


        function reset(this)
            this.FailedSrcReq2LinkMap=containers.Map('keyType','char','valueType','any');
            this.FailedDstReq2LinkMap=containers.Map('keyType','char','valueType','any');
            this.Req2FailedSrcLinkMap=containers.Map('keyType','char','valueType','any');
            this.InvalidOutgoingLinkMap=containers.Map('keyType','char','valueType','any');
            this.InvalidIncomingLinkMap=containers.Map('keyType','char','valueType','any');
        end


        function delete(this)
            this.reset();
        end
    end


    methods





        function refreshDataObj(this,dataObj)

            visitor=this.getRefreshVisitor();
            dataObj.accept(visitor);
        end


        function refreshReqSets(this,dataReqSets)
            for index=1:length(dataReqSets)
                this.refreshReqSet(dataReqSets(index));
            end
        end


        function refreshReqSet(this,dataReqSet)
            this.refrshDataObj(dataReqSet);
        end


        function refreshReqs(this,dataReqs)
            for index=1:length(dataReqs)
                this.refreshReq(dataReqs(index));
            end
        end


        function refreshReq(this,dataReq)
            this.refreshDataObj(dataReq);
        end


        function refreshReqToBeDeleted(this,dataReq)


            rVisitor=this.getRefreshVisitor();
            rVisitor.visitRequirementToBeDeleted(dataReq);
        end


        function refreshLink(this,dataLink)
            this.refreshDataObj(dataLink);
        end


        function refreshLinkSet(this,dataLinkSet)
            this.refreshDataObj(dataLinkSet);
        end





        function clearAllChangeIssues(this,dataLinkSet,commentInfo)


            rVisitor=this.getRefreshVisitor();
            dataLinkSet.accept(rVisitor);

            cVisitor=this.getClearVisitor();
            cVisitor.setComment(commentInfo);
            cVisitor.setClearTarget('All');
            dataLinkSet.accept(cVisitor);
        end


        function clearLinkedSourceIssues(this,dataLink,commentInfo)
            cVisitor=this.getClearVisitor();
            cVisitor.setClearTarget('Source');
            cVisitor.setComment(commentInfo)
            dataLink.accept(cVisitor);
        end


        function clearLinkedDestinationIssues(this,dataLink,commentInfo)
            cVisitor=this.getClearVisitor();
            cVisitor.setClearTarget('Destination');
            cVisitor.setComment(commentInfo)
            dataLink.accept(cVisitor);
        end


        function tf=hasLinksWithChangeIssue(this,reqUuid)
            tf=isKey(this.FailedSrcReq2LinkMap,reqUuid)||...
            isKey(this.FailedDstReq2LinkMap,reqUuid);
        end


        function tf=hasLinksWithSourceChangeIssue(this,reqUuid)
            tf=isKey(this.Req2FailedSrcLinkMap,reqUuid);
        end


        function tf=hasInvalidLinks(this,reqUuid)
            tf=isKey(this.InvalidOutgoingLinkMap,reqUuid)||...
            isKey(this.InvalidIncomingLinkMap,reqUuid);
        end
    end

    methods(Access=private)




        function ctvisitor=getClearVisitor(this)
            ctvisitor=slreq.analysis.ChangeTrackingClearVisitor();
            this.setMaps(ctvisitor);
        end


        function ctvisitor=getRefreshVisitor(this)
            ctvisitor=slreq.analysis.ChangeTrackingRefreshVisitor();
            this.setMaps(ctvisitor);
        end


        function setMaps(this,ctvisitor)

            ctvisitor.setFailedReq2LinkMap(this.FailedSrcReq2LinkMap,this.FailedDstReq2LinkMap)
            ctvisitor.setInvalidLinkMap(this.InvalidOutgoingLinkMap,this.InvalidIncomingLinkMap)
            ctvisitor.setReq2FailedSrcLinkMap(this.Req2FailedSrcLinkMap);
        end


        function linkUuids=getAllLinksWithChangeIssue(this,reqUuid)
            linkUuids={};
            if isKey(this.FailedSrcReq2LinkMap,reqUuid)
                linkUuids=[linkUuids,this.FailedSrcReq2LinkMap(reqUuid)];
            end

            if isKey(this.FailedDstReq2LinkMap,reqUuid)
                linkUuids=[linkUuids,this.FailedDstReq2LinkMap(reqUuid)];
            end
        end


        function linkUuids=getAllLinksWithSourceChangeIssue(this,reqUuid)


            linkUuids={};
            if isKey(this.Req2FailedSrcLinkMap,reqUuid)
                linkUuids=[linkUuids,this.Req2FailedSrcLinkMap(reqUuid)];
            end
        end


        function linkUuids=getAllInvalidLinks(this,reqUuid)
            linkUuids={};
            if isKey(this.InvalidOutgoingLinkMap,reqUuid)
                linkUuids=[linkUuids,this.InvalidOutgoingLinkMap(reqUuid)];
            end

            if isKey(this.InvalidIncomingLinkMap,reqUuid)
                linkUuids=[linkUuids,this.InvalidIncomingLinkMap(reqUuid)];
            end
        end
    end

    methods(Static)

        function ct=getInstance()
            persistent instance

            if isempty(instance)
                instance=slreq.analysis.ChangeTracker;
            end
            ct=instance;
        end


        function clearCache()
            instance=slreq.analysis.ChangeTracker.getInstance;
            instance.reset();
        end

    end
end
