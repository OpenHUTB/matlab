function[clkrate,latency]=getClkrateAndLatency(this,filterobj)







    latency=1+hdlfilterlatency(filterobj);
    clkrate=1;
