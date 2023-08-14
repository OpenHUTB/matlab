function hC=pirAddNtwkInstanceComp(this,slbh,hThisNetwork,hChildNetwork)













    if hChildNetwork.hasForIterDataTag

        hC=hThisNetwork.addComponent('for_iter_comp',hChildNetwork);
    elseif hChildNetwork.hasNPUDataTag

        hC=hThisNetwork.addComponent('npu_comp',hChildNetwork);
    else
        hC=hThisNetwork.addComponent('ntwk_instance_comp',hChildNetwork);
    end

    nname=this.validateAndGetName(get_param(slbh,'Name'));
    hC.Name=nname;
    hC.SimulinkHandle=slbh;
