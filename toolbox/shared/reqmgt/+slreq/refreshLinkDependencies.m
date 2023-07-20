



function refreshLinkDependencies()
    if slreq.internal.isSharedSlreqInstalled()
        lsm=slreq.linkmgr.LinkSetManager.getInstance;
        lsm.reIndexMetadata();
    end
end

