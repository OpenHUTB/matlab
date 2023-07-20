function val=hasDesignDelay(this,hN,hC)

















    mode=get_param(hC.SimulinkHandle,'opMode');
    if~strcmp(mode,'Vector')
        val=true;
    else
        val=false;
    end
