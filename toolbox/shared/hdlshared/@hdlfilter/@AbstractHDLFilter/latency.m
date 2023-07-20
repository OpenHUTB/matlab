function[latency,initlatency]=latency(this)







    latency=0;
    if this.getHDLParameter('filter_registered_input')==1
        latency=latency+1;
    end

    if this.getHDLParameter('filter_registered_output')==1
        latency=latency+1;
    end

    latency=latency+this.getHDLParameter('filter_excess_latency');
    initlatency=latency*this.getHDLParameter('foldingfactor');

