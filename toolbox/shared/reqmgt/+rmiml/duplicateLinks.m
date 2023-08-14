function success=duplicateLinks(origSrcArtifact,rangeId,destArtifact,destinatinRange)
    try
        reqs=rmiml.getReqs(origSrcArtifact,rangeId);


        newId=createIdForRange(destArtifact,destinatinRange);
        if isempty(newId)

            success=false;
        else
            rmiml.setReqs(reqs,destArtifact,newId);
            success=true;
        end
    catch mex
        disp(mex.message);
        success=false;
    end
end

function id=createIdForRange(srcName,range)





    [domain,artifact,txtId]=rmiml.resolveTextNode(srcName);

    r=slreq.data.ReqData.getInstance();
    linkSet=r.getLinkSet(artifact);
    if isempty(linkSet)
        linkSet=r.createLinkSet(artifact,domain);
    end

    textItem=linkSet.getTextItem(txtId);
    if isempty(textItem)
        content=rmiut.escapeForXml(rmiml.getText(srcName));
        textItem=linkSet.addTextItem(txtId,content);
    end

    srcStruct.id=textItem.getNextId();
    srcStruct.parent=txtId;
    betterRange=rmiut.RangeUtils.completeToLines(srcName,range);
    if isempty(betterRange)



        srcStruct.range=range;
    else
        srcStruct.range=betterRange;
    end
    textRange=r.addLinkableRange(linkSet,srcStruct);

    if~isempty(textRange)&&strcmp(textRange.id,srcStruct.id)
        id=textRange.id;
    else
        id='';
    end
end
