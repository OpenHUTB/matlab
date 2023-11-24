function openReqLinkFile(absoluteFileAddress)

    slreq.editor;
    slreq.load(fullfile(absoluteFileAddress));
    ls=slreq.utils.getLinkSet(fullfile(absoluteFileAddress));
    slreq.app.CallbackHandler.selectObjectByUuid(ls.getUuid(),'standalone');
end
