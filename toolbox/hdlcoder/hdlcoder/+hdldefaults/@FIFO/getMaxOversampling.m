function val=getMaxOversampling(this,hC)


    info=getBlockInfo(this,hC.SimulinkHandle);
    if info.output_rate==1
        val=-1;
    else
        val=info.output_rate;
    end
