function latencyInfo=baseGetLatencyInfo(this,hC)













    latencyInfo.inputDelay=0;

    if isa(hC,'hdlcoder.sysobj_comp')


        latencyInfo.samplingChange=1;
        latencyInfo.outputDelay=0;
    else

        hF=this.getHDLFilterObj(hC);
        s=this.applyFilterImplParams(hF,hC);
        hF.setimplementation;
        [~,~,slLatency]=hF.latency;
        this.unApplyParams(s.pcache);
        latencyInfo.outputDelay=slLatency;



        if isa(hF,'hdlfilter.cicdecim')||isa(hF,'hdlfilter.firdecim')||isa(hF,'hdlfilter.firtdecim')
            latencyInfo.samplingChange=-1*hF.DecimationFactor;
        elseif isa(hF,'hdlfilter.cicinterp')||isa(hF,'hdlfilter.firinterp')
            latencyInfo.samplingChange=1*hF.InterpolationFactor;
        else
            latencyInfo.samplingChange=1;
        end
    end


