function[latency,initlatency,SLLatency]=latency(this)







    latency=0;
    if this.getHDLParameter('filter_registered_input')==1
        latency=latency+1;
    end

    if this.getHDLParameter('filter_registered_output')==1
        latency=latency+1;
    end

    latency=latency+this.getHDLParameter('filter_excess_latency');
    initlatency=latency*this.getHDLParameter('foldingfactor');

    preg=this.getHDLParameter('filter_pipelined');
    SLLatency=0;

    if~(hdlgetparameter('requestedoptimslowering')||hdlgetparameter('forcedlowering'))
        if preg
            SLLatency=SLLatency+this.NumSections-1;
        end
    end


    if strcmpi(this.implementation,'serial')
        SLLatency=SLLatency...
        +this.getHDLParameter('filter_registered_input')...
        +this.getHDLParameter('filter_registered_output');

    end

