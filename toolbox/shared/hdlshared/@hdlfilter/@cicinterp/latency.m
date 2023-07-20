function[latency,initlatency,SLLatency]=latency(this)






    factor=this.InterpolationFactor;

    if this.getHDLParameter('RateChangePort')
        rate1=resolveTBRateStimulus(this);
        factor=rate1;
    end
    latency=0;
    if this.getHDLParameter('filter_registered_input')==1
        latency=latency+factor;
    end

    if this.getHDLParameter('filter_registered_output')==1
        latency=latency+1;
    end

    latency=latency+this.getHDLParameter('filter_excess_latency');
    initlatency=latency;
    latency=this.interpolationfactor;

    preg=this.getHDLParameter('filter_pipelined');
    SLLatency=0;
    if preg&&this.NumberOfSections>1
        SLLatency=SLLatency+this.NumberOfSections;
    end

