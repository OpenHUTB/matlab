function tcinfo=getTimingControllerInfo(this,clkDomain)



    tcinfoMap=get(this,'TimingControllerInfo');
    if isempty(tcinfoMap)
        tcinfo=[];
    else
        tcinfo=tcinfoMap(clkDomain);
    end
