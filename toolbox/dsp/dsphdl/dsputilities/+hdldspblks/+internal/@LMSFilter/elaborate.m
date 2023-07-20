function nComp=elaborate(this,hN,hC)




    bfp=hC.SimulinkHandle;


    muport=~strcmpi(get_param(bfp,'stepflag'),'Dialog');
    adapt=strcmpi(get_param(bfp,'Adapt'),'on');
    resetport=~strcmpi(get_param(bfp,'resetflag'),'None');

    numin=numel(hC.PIRInputSignals);
    inportnames=cell(numin,1);
    inportnames{1}='lms_input';
    inportnames{2}='lms_desired';
    inport_idx=3;
    if muport
        inportnames{inport_idx}='lms_step_size';
        inport_idx=inport_idx+1;
    end
    if adapt
        inportnames{inport_idx}='lms_adapt';
        inport_idx=inport_idx+1;
    end
    if resetport
        inportnames{inport_idx}='lms_reset';

    end


    outportnames{1}='lms_output';
    outportnames{2}='lms_error';
    wgt_port=strcmpi(get_param(bfp,'weights'),'on');
    if wgt_port
        outportnames{3}='lms_weights';
    end



    topNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportnames,...
    'OutportNames',outportnames...
    );

    bfp=hC.SimulinkHandle;
    alg=get_param(bfp,'Algo');
    topNet.addComment(['LMS Filter: ',alg,' Algorithm']);


    this.elaborateLMS(topNet,hC);


    for ii=1:numel(hC.PirInputSignals)
        topNet.PirInputSignals(ii).SimulinkRate=hC.PirInputSignals(ii).SimulinkRate;
    end
    for ii=1:numel(hC.PirOutputSignals)
        topNet.PirOutputSignals(ii).SimulinkRate=hC.PirOutputSignals(ii).SimulinkRate;
    end


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

