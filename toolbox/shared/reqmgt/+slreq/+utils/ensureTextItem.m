function textItem=ensureTextItem(src,content)



    if isstruct(src)
        domain=src.domain;
        artifact=src.artifact;
        txtId=src.id;
    else
        [domain,artifact,txtId]=rmiml.resolveTextNode(src);
    end

    r=slreq.data.ReqData.getInstance();

    linkSet=r.getLinkSet(artifact);
    if isempty(linkSet)
        linkSet=r.createLinkSet(artifact,domain);
        textItem=linkSet.addTextItem(txtId,content);
    else
        textItem=linkSet.getTextItem(txtId);
        if isempty(textItem)
            textItem=linkSet.addTextItem(txtId,content);
        end
    end
end

