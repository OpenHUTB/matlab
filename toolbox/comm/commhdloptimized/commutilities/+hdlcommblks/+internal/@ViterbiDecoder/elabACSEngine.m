function[acsdec,nsm]=elabACSEngine(this,ACSNet,normedbm,bmvType,...
    sm,t,stmetType,dataRate,decvType,stmetvType)







    networkName='ACSEngine';

    acsunitinstNet=pirelab.createNewNetwork(...
    'Network',ACSNet,...
    'Name',networkName,...
    'InportNames',{'branchMetric','stateMetric'},...
    'InportTypes',[bmvType,stmetvType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'acsDecision','nextStateMetric'},...
    'OutportTypes',[decvType,stmetvType]...
    );
    acsunitinstComment=[...
'Instantiate the ACS units'...
    ,newline...
    ,'Pass the right state metric and branch metrics to each instance'...
    ,newline...
    ,'Gather the output of each instance to send as output'...
    ];
    acsunitinstNet.addComment(acsunitinstComment);


    bMet_ip=acsunitinstNet.PirInputSignals(1);
    sMet_ip=acsunitinstNet.PirInputSignals(2);
    acsdec_op=acsunitinstNet.PirOutputSignals(1);
    nsMet_op=acsunitinstNet.PirOutputSignals(2);


    acsunitNet=this.elabACSUnit(acsunitinstNet,stmetType,dataRate);
    acsunitNet.addComment('Add Compare Select Unit');


    smarray=this.demuxSignal(acsunitinstNet,sMet_ip,'stMet_entry');


    bmarray=this.demuxSignal(acsunitinstNet,bMet_ip,'bMet_normed_entry');

    ufix1Type=pir_ufixpt_t(1,0);

    numStates=t.numStates;
    outputs=oct2dec(t.outputs)+1;
    nextStates=t.nextStates+1;


    decarray(numStates)=acsunitinstNet.addSignal(ufix1Type,...
    ['acsdec_entry',num2str(numStates)]);
    nsmarray(numStates)=acsunitinstNet.addSignal(stmetType,...
    ['nstMet_entry',num2str(numStates)]);
    for idx=1:numStates

        decarray(idx)=acsunitinstNet.addSignal(ufix1Type,...
        ['acsdec_entry',num2str(idx-1)]);

        nsmarray(idx)=acsunitinstNet.addSignal(stmetType,...
        ['nstMet_entry',num2str(idx-1)]);
    end

    for idx=1:numStates

        offsetIdx=idx*2-1;
        nextStateIdx=nextStates(offsetIdx);


        bm0idx=outputs(offsetIdx);
        bm1idx=outputs(offsetIdx+1);

        if(offsetIdx>numStates)
            smIdx=offsetIdx-numStates;
        else
            smIdx=offsetIdx;
        end

        acsunitComp=pirelab.instantiateNetwork(acsunitinstNet,acsunitNet,...
        [bmarray(bm0idx),bmarray(bm1idx),smarray(smIdx),smarray(smIdx+1)],...
        [decarray(idx),nsmarray(nextStateIdx)],...
        ['ACSUnit',num2str(idx)]);
        acsunitComp.addComment(['ACSUnit',num2str(idx)]);

    end


    this.muxSignal(acsunitinstNet,decarray,acsdec_op);
    this.muxSignal(acsunitinstNet,nsmarray,nsMet_op);


    acsdec=ACSNet.addSignal2('Type',decvType,'name','acsdec');
    nsm=ACSNet.addSignal(stmetvType,'nstMet');
    acsunitinstComp=pirelab.instantiateNetwork(ACSNet,acsunitinstNet,...
    [normedbm,sm],[acsdec,nsm],networkName);
    acsunitinstComp.addComment('ACS Unit Instantiation');


end
