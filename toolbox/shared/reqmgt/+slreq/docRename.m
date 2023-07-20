



































function[objCount,updateCount,linkCount]=docRename(srcArtifact,oldDest,newDest)

    objCount=0;
    updateCount=0;
    linkCount=0;

    if~ischar(srcArtifact)

        try
            srcArtifact=get_param(srcArtifact,'FileName');
        catch me %#ok<NASGU>
            error('Invalid first argument of type %s in a call to slreq.docRename()',class(srcArtifact));
        end
    end

    linkSet=slreq.data.ReqData.getInstance.getLinkSet(srcArtifact);
    if isempty(linkSet)
        if slreq.utils.loadLinkSet(srcArtifact)
            linkSet=slreq.data.ReqData.getInstance.getLinkSet(srcArtifact);
        end
    end

    if isempty(linkSet)
        rmiut.warnNoBacktrace('Slvnv:slreq:HasNoLinks',srcArtifact);
    else
        oldDest=convertStringsToChars(oldDest);
        newDest=convertStringsToChars(newDest);
        [updateCount,linkCount,objCount]=linkSet.updateDocUri(oldDest,newDest);
    end

end