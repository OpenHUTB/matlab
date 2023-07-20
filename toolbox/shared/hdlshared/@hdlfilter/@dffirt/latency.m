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


    mip=this.getHDLParameter('multiplier_input_pipeline');
    mop=this.getHDLParameter('multiplier_output_pipeline');
    preg=this.getHDLParameter('filter_pipelined');

    SLLatency=0;

    if~(hdlgetparameter('requestedoptimslowering')||hdlgetparameter('forcedlowering'))
        if preg
            SLLatency=SLLatency+1;
        end
        if mip>0
            SLLatency=SLLatency+this.getHDLParameter('multiplier_input_pipeline');
        end
        if mop>0
            SLLatency=SLLatency+this.getHDLParameter('multiplier_output_pipeline');
        end
    end

    number_channel=this.getHDLParameter('filter_generate_multichannel');
    if number_channel>1
        SLLatency=floor(SLLatency/number_channel)+1;
    end

