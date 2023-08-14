function h=LogSignalObj(sigInfo)





    h=SigLogSelector.LogSignalObj;
    if nargin<1
        return;
    end



    me=SigLogSelector.getExplorer;
    mi=me.getRoot.getModelLoggingInfo;
    sigIdx=mi.findSignal(sigInfo.blockPath_,sigInfo.outputPortIndex_);
    if length(sigIdx)==1

        me.isSettingDataLoggingOveride=true;
        h.signalInfo=mi.updateSignalNameCache(sigIdx);
        me.isSettingDataLoggingOveride=false;
    else
        h.signalInfo=sigInfo;
    end


    h.Name=h.signalInfo.getSignalNameFromPort(...
    true,...
    true);


    len=sigInfo.blockPath_.getLength();
    bpath=sigInfo.blockPath_.getBlock(len);
    name=Simulink.SimulationData.BlockPath.manglePath(...
    get_param(bpath,'Name'));
    if~isempty(sigInfo.blockPath_.SubPath)
        h.SourcePath=name;
    else
        h.SourcePath=sprintf('%s:%d',name,sigInfo.outputPortIndex_);
    end


    if isempty(sigInfo.blockPath_.SubPath)
        ph=get_param(bpath,'PortHandles');
        h.daobject=get_param(ph.Outport(sigInfo.outputPortIndex_),'Object');
    end


    h.addListeners;

end
