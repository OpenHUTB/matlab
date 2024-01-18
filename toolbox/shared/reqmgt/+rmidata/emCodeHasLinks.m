function result=emCodeHasLinks(chartObj)

    sid=Simulink.ID.getSID(chartObj);
    if rmisl.isComponentHarness(strtok(sid,':'))
        sid=rmiml.harnessToModelRemap(sid);
    end

    [mainMdlName,harnessBoundId]=strtok(sid,':');
    try
        artifactPath=get_param(mainMdlName,'FileName');
        result=slreqTextItemHasLinks(artifactPath,harnessBoundId);
    catch ex %#ok<NASGU>

        warning('Model %s is not loaded.',mainMdlName);
        result=false;
    end

end


function hasLinks=slreqTextItemHasLinks(artifactPath,textItemID)
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactPath);
    if isempty(linkSet)
        hasLinks=false;
        return;
    end
    textItem=linkSet.getTextItem(textItemID);
    if isempty(textItem)
        hasLinks=false;
    else
        hasLinks=textItem.hasOutgoingLinks();
    end
end
