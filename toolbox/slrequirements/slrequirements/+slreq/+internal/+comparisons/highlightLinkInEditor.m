function highlightLinkInEditor(linkSetName,sid,linkSetPath,artifact)


    reqData=slreq.data.ReqData.getInstance;


    linkSet=reqData.getLinkSet(linkSetName);

    if isempty(linkSet)
        if exist(linkSetPath,'file')==2

            linkSet=reqData.loadLinkSet(artifact,linkSetPath);
        end
    end

    if~isempty(linkSet)

        if~isempty(sid)
            selectedLink=linkSet.getLinkFromID(sid);
            slreq.app.CallbackHandler.selectObjectByUuid(selectedLink.getUuid(),'standalone')
        else
            slreq.app.CallbackHandler.selectObjectByUuid(linkSet.getUuid(),'standalone')
        end
    end
end

