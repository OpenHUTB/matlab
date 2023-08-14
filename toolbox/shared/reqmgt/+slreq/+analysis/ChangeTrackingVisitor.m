classdef ChangeTrackingVisitor<slreq.analysis.AbstractVisitor





    properties


        name='NA';
    end

    properties(Access=protected)







        FailedSrcReq2LinkMap=containers.Map('keyType','char','valueType','any');

        FailedDstReq2LinkMap=containers.Map('keyType','char','valueType','any');



        Req2FailedSrcLinkMap=containers.Map('keyType','char','valueType','any');

        InvalidOutgoingLinkMap=containers.Map('keyType','char','valueType','any');

        InvalidIncomingLinkMap=containers.Map('keyType','char','valueType','any');

    end

    methods
        function this=ChangeTrackingVisitor()


        end

        function setFailedReq2LinkMap(this,FailedSrcReq2LinkMap,FailedDstReq2LinkMap)
            this.FailedDstReq2LinkMap=FailedDstReq2LinkMap;
            this.FailedSrcReq2LinkMap=FailedSrcReq2LinkMap;
        end

        function setReq2FailedSrcLinkMap(this,Req2FailedSrcLinkMap)
            this.Req2FailedSrcLinkMap=Req2FailedSrcLinkMap;
        end

        function setInvalidLinkMap(this,InvalidOutgoingLinkMap,InvalidIncomingLinkMap)
            this.InvalidOutgoingLinkMap=InvalidOutgoingLinkMap;
            this.InvalidIncomingLinkMap=InvalidIncomingLinkMap;
        end


        function visitRequirementSet(this,dataReqSet)

        end


        function visitRequirement(this,dataReq)


        end


        function visitLinkSet(this,dataLinkSet)

        end


        function visitLink(this,dataLink)

        end

    end

    methods(Sealed=true,Access=protected)

        function resetChangedLinkMap(this,dataReq)
            reqUuid=dataReq.getUuid;
            removeKey(this.FailedSrcReq2LinkMap,reqUuid);
            removeKey(this.FailedDstReq2LinkMap,reqUuid);
            removeKey(this.InvalidOutgoingLinkMap,reqUuid);
            removeKey(this.InvalidIncomingLinkMap,reqUuid);
            removeKey(this.Req2FailedSrcLinkMap,reqUuid);
            removeKey(dataReq.changedLinkAsDst,dataReq.changedLinkAsDst.keys)
            removeKey(dataReq.changedLinkAsSrc,dataReq.changedLinkAsSrc.keys)
        end


        function addChangedLinkAsSrc(this,srcUuid,linkUuid)
            insertKeyValueMember(this.FailedSrcReq2LinkMap,srcUuid,linkUuid);
        end


        function addChangedLinkAsDst(this,dstUuid,linkUuid)
            insertKeyValueMember(this.FailedDstReq2LinkMap,dstUuid,linkUuid);
        end


        function addChangedSrcLinkWithReq(this,reqUuid,linkUuid)
            insertKeyValueMember(this.Req2FailedSrcLinkMap,reqUuid,linkUuid);
        end


        function removeChangedLinkAsSrc(this,srcUuid,linkUuid)
            removeKeyValueMember(this.FailedSrcReq2LinkMap,srcUuid,linkUuid);
        end


        function removeChangedLinkAsDst(this,dstUuid,linkUuid)
            removeKeyValueMember(this.FailedDstReq2LinkMap,dstUuid,linkUuid);
        end


        function removeChangedSrcLinkWithReq(this,reqUuid,linkUuid)
            removeKeyValueMember(this.Req2FailedSrcLinkMap,reqUuid,linkUuid);
        end


        function addInvalidOutgoingLink(this,reqUuid,linkUuid)
            insertKeyValueMember(this.InvalidOutgoingLinkMap,reqUuid,linkUuid);
        end


        function addInvalidIncomingLink(this,reqUuid,linkUuid)
            insertKeyValueMember(this.InvalidIncomingLinkMap,reqUuid,linkUuid);
        end


        function removeInvalidOutgoingLink(this,reqUuid,linkUuid)
            removeKeyValueMember(this.InvalidOutgoingLinkMap,reqUuid,linkUuid);
        end


        function removeInvalidIncomingLink(this,reqUuid,linkUuid)
            removeKeyValueMember(this.InvalidIncomingLinkMap,reqUuid,linkUuid);
        end


        function refreshMapForReqAsDst(this,dataReq,inDataLinks)

            reqUuid=dataReq.getUuid;
            for index=1:length(inDataLinks)
                cDataLink=inDataLinks(index);
                cLinkUuid=cDataLink.getUuid;
                if cDataLink.destinationChangeStatus.isFail
                    this.addChangedLinkAsDst(reqUuid,cLinkUuid);
                    dataReq.addChangedLinkAsDst(cLinkUuid);
                else
                    dataReq.removeChangedLinkAsDst(cLinkUuid);
                end

                if cDataLink.sourceChangeStatus.isFail
                    this.addChangedSrcLinkWithReq(reqUuid,cLinkUuid);
                else
                    this.removeChangedSrcLinkWithReq(reqUuid,cLinkUuid);
                end

                if cDataLink.sourceChangeStatus.isInvalidLink
                    this.addInvalidIncomingLink(reqUuid,cLinkUuid);
                end
            end
        end


        function refreshMapForReqAsSrc(this,dataReq,outDataLinks)
            reqUuid=dataReq.getUuid;
            for index=1:length(outDataLinks)
                cDataLink=outDataLinks(index);
                cLinkUuid=cDataLink.getUuid;
                if cDataLink.sourceChangeStatus.isFail
                    this.addChangedLinkAsSrc(reqUuid,cLinkUuid);
                    dataReq.addChangedLinkAsSrc(cLinkUuid);
                else
                    dataReq.removeChangedLinkAsSrc(cLinkUuid);
                end

                if cDataLink.destinationChangeStatus.isInvalidLink
                    this.addInvalidOutgoingLink(reqUuid,cLinkUuid);
                end
            end
        end


        function updateMap(this,dataLink,srcInfo,dstInfo)
            linkUuid=dataLink.getUuid;
            srcUuid=srcInfo.uuid;
            dstUuid=dstInfo.uuid;




            if dataLink.sourceChangeStatus.isFail
                this.addChangedLinkAsSrc(srcUuid,linkUuid);
                if strcmp(dataLink.destDomain,'linktype_rmi_slreq')



                    this.addChangedSrcLinkWithReq(dstUuid,linkUuid);
                end
            else

                this.removeChangedLinkAsSrc(srcUuid,linkUuid);
            end

            if dataLink.destinationChangeStatus.isFail
                this.addChangedLinkAsDst(dstUuid,linkUuid);
            else
                this.removeChangedLinkAsDst(dstUuid,linkUuid);
            end

            if dataLink.sourceChangeStatus.isInvalidLink
                this.addInvalidIncomingLink(dstUuid,linkUuid);
            else
                this.removeInvalidIncomingLink(dstUuid,linkUuid);
            end

            if dataLink.destinationChangeStatus.isInvalidLink
                this.addInvalidOutgoingLink(srcUuid,linkUuid);
            else
                this.removeInvalidOutgoingLink(srcUuid,linkUuid);
            end
        end
    end
end











function insertKeyValueMember(targetMap,key,valueMember)
    if~isempty(key)
        if isKey(targetMap,key)
            targetMap(key)=unique([targetMap(key),valueMember]);%#ok<NASGU>
        else
            targetMap(key)={valueMember};%#ok<NASGU>
        end
    end
end


function removeKeyValueMember(targetMap,key,valueMember)
    if~isempty(key)
        if isKey(targetMap,key)
            targetMap(key)=setdiff(targetMap(key),{valueMember});
            if isempty(targetMap(key))
                targetMap.remove(key);
            end
        end
    end
end


function removeKey(targetMap,key)
    if~isempty(key)
        if isKey(targetMap,key)
            targetMap.remove(key);
        end
    end
end
