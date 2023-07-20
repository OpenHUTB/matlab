function cutReqToClipboard(this,dataReqs)






    if isempty(dataReqs)

        return;
    end

    this.clearClipboard();
    this.cutReqLinkMap.remove(this.cutReqLinkMap.keys);
    clipboard=this.getClipboardReqSet();
    reqSetObj=dataReqs(1).getReqSet();
    for n=1:length(dataReqs)
        mfReq=this.getModelObj(dataReqs(n));
        action=struct('type','cut','KeepSID',false,'CopyAttributes',true);
        this.recCopyChildren(mfReq,clipboard,action);

        this.removeRequirement(dataReqs(n));
    end
    clipboard.setProperty('lastAction','cut');
    clipboard.setProperty('sourceReqSet',reqSetObj.filepath);
end
