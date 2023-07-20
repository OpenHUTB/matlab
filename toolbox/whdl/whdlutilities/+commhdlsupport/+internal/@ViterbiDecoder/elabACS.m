function acsNet=elabACS(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    numStates=blockInfo.Trellis.numStates;
    bmVType=blockInfo.bmType;
    smVType=blockInfo.smType;

    dbType=pirelab.getPirVectorType(ufix1Type,numStates);


    if~(strcmpi(blockInfo.OperationMode,'Continuous'))
        acsinsignals={'bmet','bmvalid','acsrstd'};
        acsinporttypes=[bmVType,ufix1Type,ufix1Type];
        acsinrates=[dataRate,dataRate,dataRate];
    else
        if(blockInfo.ResetPort)
            acsinsignals={'bmet','bmvalid','acsrstd'};
            acsinporttypes=[bmVType,ufix1Type,ufix1Type];
            acsinrates=[dataRate,dataRate,dataRate];
        else
            acsinsignals={'bmet','bmvalid'};
            acsinporttypes=[bmVType,ufix1Type];
            acsinrates=[dataRate,dataRate];
        end
    end


    acsNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ACS',...
    'Inportnames',acsinsignals,...
    'InportTypes',acsinporttypes,...
    'InportRates',acsinrates,...
    'Outportnames',{'statemetrics','decbits','smvalid'},...
    'OutportTypes',[smVType,dbType,ufix1Type]...
    );

    bmetrics=acsNet.PirInputSignals(1);
    bmvalid=acsNet.PirInputSignals(2);

    if~(strcmpi(blockInfo.OperationMode,'Continuous'))
        acsrst=acsNet.PirInputSignals(3);
    else
        if(blockInfo.ResetPort)
            acsrst=acsNet.PirInputSignals(3);
        end
    end

    smetric=acsNet.PirOutputSignals(1);
    decbits=acsNet.PirOutputSignals(2);
    smvalid=acsNet.PirOutputSignals(3);


    acsengNet=this.elabACSEngine(acsNet,blockInfo,bmetrics.SimulinkRate);

    ic=[];
    for i=1:numStates-1
        ic=[ic,blockInfo.stateMetMax];%#ok<*AGROW>
    end
    ic=[blockInfo.stateMetMin,ic];

    initsmet=acsNet.addSignal(smVType,'initStateMet');
    icomp=pirelab.getConstComp(acsNet,initsmet,ic);
    icomp.addComment('Initial State Metrics')

    prevsmet=acsNet.addSignal(smVType,'prevStateMet');

    smetric1=acsNet.addSignal(smVType,'dsmteric');
    decbits1=acsNet.addSignal(dbType,'ddecbits');
    smvalid1=acsNet.addSignal(ufix1Type,'dsmvalid');

    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(blockInfo.ResetPort)
            acsengineIns=[bmetrics,prevsmet,bmvalid,acsrst];
        else
            acsengineIns=[bmetrics,prevsmet,bmvalid];
        end
    else
        acsengineIns=[bmetrics,prevsmet,bmvalid,acsrst];
    end

    feedenb=acsNet.addSignal(ufix1Type,'feedEnb');


    if strcmpi(blockInfo.OperationMode,'Continuous')&&(blockInfo.ResetPort)
        pirelab.getLogicComp(acsNet,[bmvalid,acsrst],feedenb,'or');
    else
        pirelab.getWireComp(acsNet,bmvalid,feedenb);
    end



    acomp=pirelab.instantiateNetwork(acsNet,acsengNet,acsengineIns,[smetric1,decbits1,smvalid1],'ACS_Engine_Inst');
    acomp.addComment('ACS Engine Instantiation');

    dcomp=pirelab.getUnitDelayEnabledComp(acsNet,smetric1,prevsmet,feedenb,'Feedback_',ic);
    dcomp.addComment('Feedback of Next State Metrics');

    pirelab.getWireComp(acsNet,prevsmet,smetric);
    pirelab.getUnitDelayComp(acsNet,decbits1,decbits,'',0);
    pirelab.getUnitDelayComp(acsNet,smvalid1,smvalid,'',0);
end