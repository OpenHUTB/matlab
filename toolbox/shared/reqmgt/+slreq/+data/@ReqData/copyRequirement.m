function copyRequirement(this,srcDataReq,location,dstDataReq)






    this.copyReqToClipboard(srcDataReq);
    mfClipboard=this.getClipboardReqSet();


    copiedDataReq=slreq.data.ReqData.getWrappedObj(mfClipboard.rootItems(1));

    if ismember(location,{'before','after'})
        copiedDataReq.moveTo(location,dstDataReq);
        dataReqSet=dstDataReq.getReqSet();

        this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Pasted',dataReqSet));
    else
        this.pasteFromClipboard(dstDataReq);
    end


    this.clearClipboard();
end