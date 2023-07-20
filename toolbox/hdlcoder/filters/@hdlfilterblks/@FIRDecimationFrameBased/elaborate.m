function hNewC=elaborate(this,hN,hC)


    slbh=hC.SimulinkHandle;

    hTopNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC);



    hTopNet.PirOutputSignals.Name=hC.PirOutputSignals.Name;
    hTopNet.PirOutputSignals.SimulinkRate=hC.PirOutputSignals.SimulinkRate;


    dfname=hC.Name;
    ip=hdlgetparameter('instance_prefix');
    dfname=regexprep(dfname,['^',ip],'');

    hTopNet.PirInputPorts(1).Name=[dfname,'_in'];
    hTopNet.PirOutputPorts.Name=[dfname,'_out'];
    hTopNet.PirInputSignals(1).Name=[dfname,'_in'];
    hTopNet.PirOutputSignals.Name=[dfname,'_out'];

    if this.allowElabModelGen
        hdlsetparameter('requestedoptimslowering',hN.optimizationsRequested);
        hdlsetparameter('forcedlowering',this.forceElabModelGen(hN,hC));
    else
        hdlsetparameter('requestedoptimslowering',0);
        hdlsetparameter('forcedlowering',false);
    end

    if~isempty(this.getImplParams('MultiplierInputPipeline'))
        hdlsetparameter('multiplier_input_pipeline',this.getImplParams('MultiplierInputPipeline'));
    else
        hdlsetparameter('multiplier_input_pipeline',0);
    end

    if~isempty(this.getImplParams('MultiplierOutputPipeline'))
        hdlsetparameter('multiplier_output_pipeline',this.getImplParams('MultiplierOutputPipeline'));
    else
        hdlsetparameter('multiplier_output_pipeline',0);
    end

    if~isempty(this.getImplParams('AdderTreePipeline'))
        hdlsetparameter('adder_tree_pipeline',this.getImplParams('AdderTreePipeline'));
    else
        hdlsetparameter('adder_tree_pipeline',0);
    end

    blockInfo=getBlockInfo(this,slbh);

    hdlfilterblks.DiscreteFIRFrameBased.elaborateFrameBased(hTopNet,hC,blockInfo);

    hNewC=pirelab.instantiateNetwork(hN,hTopNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end