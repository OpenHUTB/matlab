function val=getMaxOversampling(this,hC)



    val=hC.PirInputSignals.SimulinkRate/hC.PirOutputSignals(1).SimulinkRate;
    if~isinteger(val)
        val=-1;
    end
