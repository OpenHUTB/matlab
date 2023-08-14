









function result=discardLinkSet(artifact,forceDiscardChanges)
    if nargin<2
        forceDiscardChanges=false;
    end

    if~slreq.data.ReqData.exists()
        result=false;
        return;
    end

    if~ischar(artifact)

        artifact=get_param(artifact,'FileName');
    elseif~any(artifact=='.')


        try
            artifact=get_param(artifact,'FileName');
        catch

        end
    end

    if isempty(artifact)
        return;
    end

    if forceDiscardChanges
        slreq.data.ReqData.getInstance.discardLinkSetChanges(artifact);
    end


    result=slreq.data.ReqData.getInstance.discardLinkSet(artifact);

    if slreq.internal.isSharedSlreqInstalled()




        slreq.linkmgr.LinkSetManager.getInstance.onArtifactClose(artifact);
    end
end
