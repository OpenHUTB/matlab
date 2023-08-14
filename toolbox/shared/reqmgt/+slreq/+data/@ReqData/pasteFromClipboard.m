function pasteFromClipboard(this,destObj)






    clipboard=this.getClipboardReqSet();
    dst=this.getModelObj(destObj);
    if isa(dst,'slreq.datamodel.RequirementSet')
        dstReqSet=dst;
    else
        dstReqSet=dst.requirementSet;
    end








    action.type='paste';

    if strcmp(clipboard.getProperty('lastAction'),'cut')
        isFirstPasteFromCut=true;

        action.KeepRevisionInfo=true;



        clipboard.setProperty('lastAction','cutPaste');
    else

        isFirstPasteFromCut=false;
        action.KeepRevisionInfo=false;
    end

    isInSameReqSet=strcmp(clipboard.getProperty('sourceReqSet'),dstReqSet.filepath);
    action.CopyAttributes=true;
    if isInSameReqSet

        action.KeepSID=isFirstPasteFromCut;
    else
        action.KeepSID=false;
    end

    linksStored=this.cutReqLinkMap.values;
    ch=clipboard.rootItems.toArray;
    if isa(ch,'slreq.datamodel.Justification')
        if~isa(dst,'slreq.datamodel.Justification')
            error(message('Slvnv:slreq:JustificationPasteError'))
        end
    end

    if isa(dst,'slreq.datamodel.Justification')
        if~isa(ch,'slreq.datamodel.Justification')
            error(message('Slvnv:slreq:RequirementPasteError'))
        end
    end

    for n=1:length(ch)
        recCopyChildren(this,ch(n),dst,action);
    end




    for n=1:length(linksStored)
        links=linksStored{n};
        for m=1:length(links)
            mfLink=links(m);
            artifactPath=mfLink.linkSet.artifactUri;
            this.resolveReference(mfLink.dest,artifactPath);
        end
    end

    if isInSameReqSet
        this.cutReqLinkMap.remove(this.cutReqLinkMap.keys);
    else


    end

    this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Pasted',destObj));
end
