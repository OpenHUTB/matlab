function renormNet=elabACSRenorm(this,ACSNet,idxType,blockInfo,thred,...
    step,stmetType,stmetvType,ic,dataRate)






    networkName='ACSRenorm';
    t=blockInfo.trellis;

    inportnames={'stMet'};
    inporttypes=stmetvType;
    inportrates=dataRate;


    renormNet=pirelab.createNewNetwork(...
    'Network',ACSNet,...
    'Name',networkName,...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',{'normval','idx'},...
    'OutportTypes',[stmetType,idxType]...
    );
    renormComment=[...
'Calculates the minimum state metric value'...
    ,newline...
    ,'Compares the minimum value to the threshold parameter'...
    ,newline...
    ,'If the minimum value is greater than or equal to the threshold value, '...
    ,newline...
    ,'returns the step parameter; otherwise returns zero'...
    ,newline...
    ];
    renormNet.addComment(renormComment);


    sm_ip=renormNet.PirInputSignals(1);
    normval_op=renormNet.PirOutputSignals(1);
    idx_op=renormNet.PirOutputSignals(2);


    numStates=t.numStates;

    dsm_ip=renormNet.addSignal(stmetvType,'dstMet');
    dsmcomp=pirelab.getUnitDelayComp(renormNet,sm_ip,dsm_ip,'stMetRegister',ic(numStates:-1:1));
    dsmcomp.addComment('Add input register for state metric');


    smarray=this.demuxSignal(renormNet,dsm_ip,'stMet_entry');



    smarray=smarray(numStates:-1:1);

    sm_reorder=renormNet.addSignal(stmetvType,'stMet_reorder');
    muxcomp=pirelab.getMuxComp(renormNet,smarray,sm_reorder);
    muxcomp.addComment('Reorder state metric to match the minimum idx search');


    dsm_reorder=renormNet.addSignal(stmetvType,'dstMet_reorder');
    pirelab.getUnitDelayComp(renormNet,sm_reorder,dsm_reorder,'MininputRegister',ic(numStates:-1:1));


    minval=renormNet.addSignal(stmetType,'minval');


    idxWL=ceil(log2(numStates));
    minidxType=pir_ufixpt_t(idxWL,0);
    minidx=renormNet.addSignal(minidxType,'minidx');


    pipeTree=true;
    pirelab.getTreeArch(renormNet,dsm_reorder,[minval,minidx],'min','Floor',...
    'Wrap','MinimumTree','Zero',pipeTree);




    dminidx=minidx;
    dminval=minval;



    idxmax=renormNet.addSignal(minidxType,'idxmax');
    maxValue=realmax(fi(0,0,idxWL,0));
    constcomp=pirelab.getConstComp(renormNet,idxmax,maxValue);
    constcomp.addComment('Max value of state index');
    pirelab.getSubComp(renormNet,[idxmax,dminidx],idx_op,'Floor','Wrap');


    ufix1Type=pir_ufixpt_t(1,0);
    sel=renormNet.addSignal(ufix1Type,'sel');
    pirelab.getCompareToValueComp(renormNet,dminval,sel,'<',thred);

    step_F=fimath('RoundMode','floor',...
    'OverflowMode','wrap');

    conststep=renormNet.addSignal(stmetType,'conststep');
    stepval=fi(-step,0,stmetType.WordLength,0,step_F);
    cstepcomp=pirelab.getConstComp(renormNet,conststep,stepval);
    cstepcomp.addComment('Normalization constant adjustment value');

    constzero=renormNet.addSignal(stmetType,'constzero');
    czerocomp=pirelab.getConstComp(renormNet,constzero,0);
    czerocomp.addComment('Normalization constant zero');


    pirelab.getSwitchComp(renormNet,[constzero,conststep],normval_op,sel,...
    'normvalswitch','>',0);

end
