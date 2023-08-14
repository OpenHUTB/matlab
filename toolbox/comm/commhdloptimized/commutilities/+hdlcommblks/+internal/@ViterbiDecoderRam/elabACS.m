function ACSNet=elabACS(this,topNet,blockInfo,dataRate)




    t=blockInfo.trellis;
    numOutputSymbols=t.numOutputSymbols;

    BMoutWL=blockInfo.nsDec+blockInfo.n-1;
    BMoutType=pir_ufixpt_t(BMoutWL,0);
    invType=pirelab.getPirVectorType(BMoutType,numOutputSymbols);



    numStates=t.numStates;
    ufix1Type=pir_ufixpt_t(1,0);
    decvType=pirelab.getPirVectorType(ufix1Type,numStates);
    idxType=pir_ufixpt_t(log2(numStates),0);



    ACSNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ACS',...
    'InportNames',{'acsin'},...
    'InportTypes',invType,...
    'InportRates',dataRate,...
    'OutportNames',{'dec','idx'},...
    'OutportTypes',[decvType,idxType]...
    );


    acsin=ACSNet.PirInputSignals(1);
    dec=ACSNet.PirOutputSignals(1);
    idx=ACSNet.PirOutputSignals(2);



    [thred,step,stmetNT]=this.renormparam(t,blockInfo.nsDec);
    stmetType=pir_ufixpt_t(stmetNT.WordLength,0);
    stmetvType=pirelab.getPirVectorType(stmetType,numStates);


    addervType=pirelab.getPirVectorType(stmetType,numOutputSymbols);
    normedbm=ACSNet.addSignal(addervType,'bMet_normed');
    dnormval=ACSNet.addSignal(stmetType,'dnormval');

    dnormedbm=ACSNet.addSignal(addervType,'dbMet_normed');
    addcomp=pirelab.getAddComp(ACSNet,[acsin,dnormval],normedbm,'Floor',...
    'Wrap','BMet adjustment adders');
    pirelab.getUnitDelayComp(ACSNet,normedbm,dnormedbm,'normadderRegister');

    addcomp.addComment('Branch Metric adjustment adders');



    sm=ACSNet.addSignal(stmetvType,'stMet');


    sm.SimulinkRate=dataRate;


    [acsdec,nsm]=this.elabACSEngine(ACSNet,dnormedbm,addervType,sm,t,...
    stmetType,dataRate,decvType,stmetvType);


    if stmetNT.WordLength>32
        maxVal=2^32-1;
    else
        maxVal=2^(stmetNT.WordLength-1)-1;
    end




    syndelay=ceil(log2(blockInfo.n))+1;
    cntWL=ceil(log2(syndelay+1));
    syncnt=ACSNet.addSignal(pir_ufixpt_t(cntWL,0),'syncnt');
    ccomp=pirelab.getCounterLimitedComp(ACSNet,syncnt,syndelay,dataRate);
    ccomp.addComment('Delays used to synchronize the state metric with valid branch metric data');

    iscntlimit=ACSNet.addSignal(ufix1Type,'isCntLimit');
    pirelab.getCompareToValueComp(ACSNet,syncnt,iscntlimit,'>=',syndelay);



    synaccu=ACSNet.addSignal(pir_ufixpt_t(1,0),'synaccu');
    dsynaccu=ACSNet.addSignal(pir_ufixpt_t(1,0),'dsyncaccu');

    pirelab.getAddComp(ACSNet,[iscntlimit,dsynaccu],synaccu,'Floor','saturate');
    pirelab.getUnitDelayComp(ACSNet,synaccu,dsynaccu,'synaccuRegister');

    regenb=ACSNet.addSignal(pir_boolean_t(),'stMetregEnb');
    pirelab.getCompareToValueComp(ACSNet,synaccu,regenb,'>',0);

    ic=maxVal*ones(1,numStates);
    ic(1)=0;
    delaycomp=pirelab.getUnitDelayEnabledComp(ACSNet,nsm,sm,regenb,'stMetRegister',ic);
    delaycomp.addComment('State metric register');


    normval=this.elabACSRenorm(ACSNet,sm,idx,idxType,thred,step,...
    stmetType,stmetvType,dataRate);
    pirelab.getUnitDelayComp(ACSNet,normval,dnormval,'NormvalRegister');


    intdelaycomp=pirelab.getIntDelayComp(ACSNet,acsdec,dec,(blockInfo.L));
    intdelaycomp.addComment('Matching delay from Minimum tree');

end
