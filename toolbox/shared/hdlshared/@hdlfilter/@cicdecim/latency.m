function[latency,initlatency,SLLatency]=latency(this)



















    phases=this.decimationfactor;
    latency=phases;

    initlatency=0;
    if this.getHDLParameter('filter_registered_input')==1
        initlatency=initlatency+1;
    end

    if this.getHDLParameter('filter_registered_output')==1
        initlatency=initlatency+1;
    end
    initlatency=initlatency+this.getHDLParameter('filter_excess_latency');

    preg=this.getHDLParameter('filter_pipelined');
    SLLatency=0;
    if preg&&this.NumberOfSections>1
        SLLatency=SLLatency+this.NumberOfSections-1;
    end

