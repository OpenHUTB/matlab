function[isParent]=isBlockInSS(subsystem,block)





    root=get_param(bdroot(block),'Handle');

    currentBlkHandle=get_param(block,'Handle');
    ssHandle=get_param(subsystem,'Handle');
    isParent=false;
    while((currentBlkHandle~=ssHandle)&&(currentBlkHandle~=root))
        currentBlkHandle=get_param(get_param(currentBlkHandle,'Parent'),'Handle');
    end
    if(ssHandle==currentBlkHandle)
        isParent=true;
    end
end