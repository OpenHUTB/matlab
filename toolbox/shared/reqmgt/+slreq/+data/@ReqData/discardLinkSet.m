function result=discardLinkSet(this,linkSet,callerArtifact)






    result=false;


    sharedSlreqInstalled=slreq.internal.isSharedSlreqInstalled();


    if ischar(linkSet)
        linkSet=this.getLinkSet(linkSet);
    end
    if~isempty(linkSet)
        if nargin<3
            callerArtifact=linkSet.artifact;
        end

        if sharedSlreqInstalled

            currentReferenceCount=slreq.linkmgr.LinkSetManager.getInstance.removeReference(linkSet,callerArtifact);
            if currentReferenceCount~=0
                return;
            end

            slreq.linkmgr.LinkSetUpdateMgr.getInstance.removeFromQueue(linkSet);
        end

        modelLinkSet=linkSet.getModelObj();
        if~isempty(modelLinkSet)
            infoToBeDestroyed.artifact=linkSet.artifact;
            infoToBeDestroyed.filepath=linkSet.filepath;
            infoToBeDestroyed.name=linkSet.name;
            infoToBeDestroyed.domain=linkSet.domain;
            this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('Before Discarding LinkSet',linkSet));

            modelLinkSet.destroy();
            linkSet.clearModelObj();

            result=true;


            this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('LinkSet Discard Completed',infoToBeDestroyed));
            if sharedSlreqInstalled
                slreq.internal.Events.getInstance.notify('LinkSetDiscarded',slreq.internal.LinkSetEventData(infoToBeDestroyed));
            end
        end
    end
end
