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


    inportnames={'acs_in'};
    inporttypes=invType;
    inportrates=dataRate;

    if blockInfo.hasResetPort
        inportnames{end+1}='acs_rst';
        inporttypes(end+1)=ufix1Type;
        inportrates(end+1)=dataRate;
    end


    ACSNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ACS',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',{'dec','idx'},...
    'OutportTypes',[decvType,idxType]...
    );


    acsin=ACSNet.PirInputSignals(1);
    dec=ACSNet.PirOutputSignals(1);
    idx=ACSNet.PirOutputSignals(2);

    if(blockInfo.hasResetPort)
        acsreset=ACSNet.PirInputSignals(2);
    else
        acsreset=[];
    end



    [thred,step,stmetNT]=this.renormparam(t,blockInfo.nsDec);
    stmetType=pir_ufixpt_t(stmetNT.WordLength,0);
    stmetvType=pirelab.getPirVectorType(stmetType,numStates);


    addervType=pirelab.getPirVectorType(stmetType,numOutputSymbols);
    normedbm=ACSNet.addSignal(addervType,'bMet_normed');
    dnormval=ACSNet.addSignal(stmetType,'dnormval');
    normval=ACSNet.addSignal(stmetType,'normval');
    addcomp=pirelab.getAddComp(ACSNet,[acsin,dnormval],normedbm,'Floor',...
    'wrap','BMet adjustment adders');
    addcomp.addComment('Branch Metric adjustment adders');



    sm=ACSNet.addSignal(stmetvType,'stMet');


    sm.SimulinkRate=dataRate;


    [acsdec,nsm]=this.elabACSEngine(ACSNet,normedbm,addervType,sm,t,...
    stmetType,dataRate,decvType,stmetvType);


    if stmetNT.WordLength>32
        maxVal=2^32-1;
    else
        maxVal=2^(stmetNT.WordLength-1)-1;
    end




    syndelay=ceil(log2(blockInfo.n))+1;
    cntWL=ceil(log2(syndelay+1));
    cntType=pir_ufixpt_t(cntWL,0);
    syncnt=ACSNet.addSignal(cntType,'syncnt');
    iscntlimit=ACSNet.addSignal(ufix1Type,'isCntLimit');

    ccomp=pirelab.getCounterLimitedComp(ACSNet,syncnt,syndelay,dataRate);
    ccomp.addComment('Delays used to synchronize the state metric with valid branch metric data');
    pirelab.getCompareToValueComp(ACSNet,syncnt,iscntlimit,'>=',syndelay);




    synaccu=ACSNet.addSignal(pir_ufixpt_t(1,0),'synaccu');
    dsynaccu=ACSNet.addSignal(pir_ufixpt_t(1,0),'dsyncaccu');
    regenb=ACSNet.addSignal(pir_boolean_t(),'stMetregEnb');

    pirelab.getAddComp(ACSNet,[iscntlimit,dsynaccu],synaccu,'Floor','saturate');
    pirelab.getCompareToValueComp(ACSNet,synaccu,regenb,'>',0);

    ic=maxVal*ones(1,numStates);
    ic(1)=0;


    acsrenormNet=this.elabACSRenorm(ACSNet,idxType,blockInfo,thred,step,...
    stmetType,stmetvType,ic,dataRate);
    acsrenormNet.addComment('State Metric Renormalization');
    pirelab.getUnitDelayComp(ACSNet,synaccu,dsynaccu,'synaccuRegister');

    if isempty(acsreset)

        delaycomp=pirelab.getUnitDelayEnabledComp(ACSNet,nsm,sm,regenb,'stMetRegister',ic);
        pirelab.getUnitDelayComp(ACSNet,normval,dnormval,'NormvalRegister');

    else


        dacsreset=ACSNet.addSignal(ufix1Type,'acs_rst_delay');
        intdcomp=pirelab.getIntDelayComp(ACSNet,acsreset,dacsreset,syndelay);
        intdcomp.addComment('Delay the reset signal');








        dacsresetEnb=dacsreset;
        delaycomp=pirelab.getUnitDelayEnabledResettableComp(ACSNet,nsm,sm,regenb,dacsresetEnb,'stMetRegister',ic,'',1);


        fsmout=ACSNet.addSignal(ufix1Type,'FSMout');
        normvalreset=ACSNet.addSignal(ufix1Type,'normvalRst');
        compName='resetgen_FSM';
        fid=fopen(fullfile(matlabroot,'toolbox','comm','commhdloptimized','commutilities',...
        '+hdlcommblks','+internal','@ViterbiDecoder','normvalReset_FSM.m'),'r');
        fcnBody=fread(fid,Inf,'char=>char')';
        fclose(fid);

        delaylen=log2(numStates)+2;
        desc='FSM that generates signal to reset NormvalRegister';

        ACSNet.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',dacsreset,...
        'OutputSignals',fsmout,...
        'EMLFileName','normvalReset_FSM',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{delaylen},...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'BlockComment',desc);

        pirelab.getUnitDelayComp(ACSNet,fsmout,normvalreset,'normvalRst');





        normvalresetEnb=normvalreset;
        pirelab.getUnitDelayResettableComp(ACSNet,normval,dnormval,normvalresetEnb,'NormvalRegister',0,'',true);
    end

    delaycomp.addComment('State metric register');
    pirelab.instantiateNetwork(ACSNet,acsrenormNet,nsm,[normval,idx],'ACSrenorm_inst');



    intdelaycomp=pirelab.getIntDelayComp(ACSNet,acsdec,dec,(blockInfo.L+1));
    intdelaycomp.addComment('Matching delay from Minimum tree');

end
