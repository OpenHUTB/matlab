

















function[id,isNew]=getRangeId(srcName,range,shouldCreate)

    id='';
    isNew=false;

    [domain,artifact,txtId]=rmiml.resolveTextNode(srcName);

    r=slreq.data.ReqData.getInstance();
    linkSet=r.getLinkSet(artifact);
    if isempty(linkSet)
        if shouldCreate
            linkSet=r.createLinkSet(artifact,domain);
            try
                linkSet.initialChangeNotify();
            catch ex
                linkSet.discard();
                rethrow(ex);
            end
            isNew=true;
        else
            return;
        end
    end

    textItem=linkSet.getTextItem(txtId);
    if isempty(textItem)
        if shouldCreate
            content=rmiut.escapeForXml(rmiml.getText(srcName));
            textItem=linkSet.addTextItem(txtId,content);
            isNew=true;
        else
            return;
        end
    end

    textRange=textItem.getRange(range);
    if isempty(textRange)
        if shouldCreate
            srcStruct.id=textItem.getNextId();
            srcStruct.parent=txtId;
            if length(range)==1
                range(2)=range(1);
            end
            betterRange=rmiut.RangeUtils.completeToLines(srcName,range);
            srcStruct.range=betterRange;
            textRange=r.addLinkableRange(linkSet,srcStruct);
            isNew=true;
        else
            return;
        end
    end


    id=textRange.id;
end

