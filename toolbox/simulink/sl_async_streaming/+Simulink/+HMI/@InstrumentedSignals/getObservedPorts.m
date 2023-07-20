function[ids,hBlks,ports,deci,maxPts,bufStreaming,isFrame,visType,hideInSDI,domains]=...
    getObservedPorts(this,mdlDispName,mdlTrueName,checkDups,rebindIfNeeded)



















    import Simulink.SimulationData.BlockPath;
    blkSettings=[];
    sigIDs={};
    sigVisType={};
    sigDomains={};
    len=this.Count;
    isMultiInstanceNormal=~strcmp(mdlDispName,mdlTrueName);
    if nargin<5
        rebindIfNeeded=false;
    end
    for idx=1:len
        sig=get(this,idx,true);


        if rebindIfNeeded&&~sig.CachedBlockHandle_
            try
                sigObj=Simulink.HMI.SignalSpecification(sig);
                sigObj=sigObj.applyRebindingRules();
                sig.CachedBlockHandle_=sigObj.CachedBlockHandle_;
                sig.CachedPortIdx_=sigObj.CachedPortIdx_;
            catch me %#ok<NASGU>
                continue
            end
        end


        if isempty(sig.CachedBlockHandle_)||...
            ~sig.CachedBlockHandle_||...
            ~isempty(sig.SubPath_)
            continue;
        end


        if~sig.HideInSDI_&&~isempty(sig.DomainType_)
            continue;
        end



        if isMultiInstanceNormal
            blk=get_param(sig.CachedBlockHandle_,'Object');
            bpath=blk.getFullName();
            bpath=BlockPath.replaceModelName(bpath,mdlDispName,mdlTrueName);
            hBlock=get_param(bpath,'handle');
        else
            hBlock=sig.CachedBlockHandle_;
        end


        if isempty(blkSettings)
            blkSettings=[hBlock,0,0,0,0,0,0];
        else
            blkSettings(end+1,1)=hBlock;%#ok<AGROW>
        end
        blkSettings(end,2)=sig.CachedPortIdx_;
        blkSettings(end,3)=1;
        blkSettings(end,4)=0;
        blkSettings(end,5)=double(sig.TargetBufferedStreaming_);
        blkSettings(end,6)=double(sig.IsFrameBased_);
        blkSettings(end,7)=double(sig.HideInSDI_);
        sigIDs{end+1}=sig.UUID;%#ok<AGROW>
        sigVisType{end+1}=sig.VisualType_;%#ok<AGROW>
        sigDomains{end+1}=sig.DomainType_;%#ok<AGROW>
    end


    if nargin>3&&checkDups
        [blkSettings,indices]=unique(blkSettings,'rows');
        ids=sigIDs(indices);
        visType=sigVisType(indices);
        domains=sigDomains(indices);
    else
        ids=sigIDs;
        visType=sigVisType;
        domains=sigDomains;
    end


    if isempty(blkSettings)
        hBlks=[];
        ports=[];
        deci=[];
        maxPts=[];
        bufStreaming=[];
        isFrame=[];
        hideInSDI=[];
    else
        hBlks=blkSettings(:,1);
        ports=blkSettings(:,2);
        deci=blkSettings(:,3);
        maxPts=blkSettings(:,4);
        bufStreaming=blkSettings(:,5);
        isFrame=blkSettings(:,6);
        hideInSDI=blkSettings(:,7);
    end
end
