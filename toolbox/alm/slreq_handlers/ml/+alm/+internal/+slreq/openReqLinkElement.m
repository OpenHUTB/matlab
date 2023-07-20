function openReqLinkElement(absoluteFileAddress,absoluteElementAddress)




    slreq.editor;
    slreq.load(fullfile(absoluteFileAddress));
    ls=slreq.utils.getLinkSet(fullfile(absoluteFileAddress));
    links=ls.getAllLinks();

    if isempty(links)
        throwError(absoluteFileAddress,absoluteElementAddress);
    end

    idx=find([links.sid]==str2double(absoluteElementAddress),1,"first");
    if idx>0
        slreq.app.CallbackHandler.selectObjectByUuid(links(idx).getUuid(),'standalone');
    else
        throwError(absoluteFileAddress,absoluteElementAddress);
    end


end

function throwError(fileAddress,elementAddress)
    error(message('alm:slreq_handlers:LinkNotFound',...
    fileAddress,fullfile(elementAddress)));
end
