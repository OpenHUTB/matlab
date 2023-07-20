











function success=removeRangeId(srcName,id)

    success=false;

    [~,artifact,txtId]=rmiml.resolveTextNode(srcName);

    r=slreq.data.ReqData.getInstance();
    linkSet=r.getLinkSet(artifact);
    if isempty(linkSet)
        rmiut.warnNoBacktrace('Slvnv:slreq:NoLinkSetFor',srcName);
        return;
    end

    textItem=linkSet.getTextItem(txtId);
    if isempty(textItem)
        if isempty(txtId)
            rmiut.warnNoBacktrace('Slvnv:slreq:NoTextItemFor',artifact);
        else
            rmiut.warnNoBacktrace('Slvnv:slreq:NoTextItemFor',txtId);
        end
        return;
    end

    success=textItem.removeTextRange(id);
end

