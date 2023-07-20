function tf=isUsingEmbeddedLinkSet(modelH)


    linkSet=slreq.data.ReqData.getInstance.getLinkSet(get_param(modelH,'Name'));
    if isempty(linkSet)
        tf=~rmipref('StoreDataExternally');
    else
        tf=slreq.utils.isEmbeddedLinkSet(linkSet.filepath);
    end
end
