function enableDisablePCTTimer(this)





    bTimerIsRunning=~isempty(this.PCTProcessTimer);
    bTimerIsNeeded=...
    isPCTSupportEnabled(this)&&...
    Simulink.sdi.Instance.isSDIRunning()&&...
    ~isempty(Simulink.sdi.internal.getCurrentParallelPool());


    if~bTimerIsRunning&&bTimerIsNeeded
        locEnableTimer(this);
    elseif bTimerIsRunning&&~bTimerIsNeeded
        locDisableTimer(this);
    end
end


function locDisableTimer(this)
    stop(this.PCTProcessTimer);
    delete(this.PCTProcessTimer);
    this.PCTProcessTimer=[];
end


function locEnableTimer(this)

    this.PCTProcessTimer=timer(...
    'Name','SDIPCTProcTimer',...
    'ExecutionMode','fixedRate',...
    'Period',0.5,...
    'ObjectVisibility','off',...
    'TimerFcn',@(x,y)onPCTProcTimer(this));
    start(this.PCTProcessTimer);
end
