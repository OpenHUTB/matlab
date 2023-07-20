function copyReqToClipboard(this,dataReqs)






    this.clearClipboard();
    this.cutReqLinkMap.remove(this.cutReqLinkMap.keys);
    clipboard=this.getClipboardReqSet();
    dataReqSet=dataReqs(1).getReqSet();
    for n=1:length(dataReqs)
        mfReq=this.getModelObj(dataReqs(n));
        action=struct('type','copy','KeepSID',false,'CopyAttributes',true);
        this.recCopyChildren(mfReq,clipboard,action);
    end
    clipboard.setProperty('lastAction','copy');
    clipboard.setProperty('sourceReqSet',dataReqSet.filepath);
end
