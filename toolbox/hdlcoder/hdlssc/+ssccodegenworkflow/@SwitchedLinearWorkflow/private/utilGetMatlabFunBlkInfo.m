function MlBlkInfo=utilGetMatlabFunBlkInfo(computeModeFcn,U,X,nfpConfigSettings)





    fid=fopen('compute_modes.m','w');
    fprintf(fid,'%s',computeModeFcn);
    fclose(fid);


    MlBlkInfo=calculateMLLatencyResource('compute_modes',{X,U,0},nfpConfigSettings);
end

function MlBlkInfo=calculateMLLatencyResource(fcnName,args,fpConfig)



    report=codegen(fcnName,'-args',args,'-config:mex','-silent');
    inferenceReport=report.inference;


    gp=pir;
    gp.destroy;


    p=pir(fcnName);


    hdlProps=hdlcoderprops.HDLProps;
    hdlProps=struct(hdlProps.INI);
    hdlProps.floatingPointTargetConfiguration=fpConfig;
    hdlProps.generateTargetComps=true;
    hdlProps.balancedelays=true;
    hdlProps.clockinputs=1;
    p.initialize(hdlProps);
    hTopNetwork=p.addNetwork;
    p.setTopNetwork(hTopNetwork);



    hdldriver=slhdlcoder.HDLCoder;
    hdldriver.setParameter('FloatingPointTargetConfiguration',fpConfig);
    hdldriver.PirInstance=p;
    hdlcurrentdriver(hdldriver);




    slRate=1;
    settings={...
...
    'ParentNetwork',hTopNetwork,...
...
...
...
    'UserComments',false,...
...
...
...
    'InstantiateFunctions',false,...
...
    'SLRate',slRate};

    [hFunctionNIC,failed]=internal.ml2pir.mlhdlc.createPIRfromML(fcnName,inferenceReport,settings{:});
    latency=0;
    mlfbAdds=0;
    mlfbMuls=0;
    if~failed
        hFunctionNetwork=hFunctionNIC.ReferenceNetwork;

        nicInputs=hFunctionNetwork.PirInputSignals;
        for ii=1:numel(nicInputs)
            topInputPort=hTopNetwork.addInputPort;
            topInputSig=hTopNetwork.addSignal(nicInputs(ii));
            topInputSig.SimulinkRate=slRate;
            topInputSig.addDriver(topInputPort);
            topInputSig.addReceiver(hFunctionNIC.PirInputPorts(ii));
        end
        nicOutputs=hFunctionNetwork.PirOutputSignals;
        for ii=1:numel(nicOutputs)
            topOutputPort=hTopNetwork.addOutputPort;
            topOutputSig=hTopNetwork.addSignal(nicOutputs(ii));
            topOutputSig.SimulinkRate=slRate;
            topOutputSig.addDriver(hFunctionNIC.PirOutputPorts(ii));
            topOutputSig.addReceiver(topOutputPort);
        end


        hdlcoder.TransformDriver.targetCodeGeneration(p);

        latency=hTopNetwork.Components.getAccumOutputLatency;

        nfp_stat=hdlcoder.characterization.create();
        nfp_stat.doit(p);
        mlfbAdds=nfp_stat.getTotalFrequency('target_add_comp');
        mlfbMuls=nfp_stat.getTotalFrequency('target_mul_comp');
        hdlcoder.characterization.destroy(nfp_stat);

    end

    hdlcurrentdriver([]);

    MlBlkInfo.mlfbBlkLatency=latency;
    MlBlkInfo.mlfbAdds=mlfbAdds;
    MlBlkInfo.mlfbMuls=mlfbMuls;
    MlBlkInfo.failed=failed;
end


