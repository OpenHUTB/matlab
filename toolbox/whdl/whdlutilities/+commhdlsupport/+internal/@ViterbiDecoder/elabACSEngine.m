function acsengNet=elabACSEngine(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);

    numStates=blockInfo.Trellis.numStates;
    outputs=oct2dec(blockInfo.Trellis.outputs)+1;
    nextStates=blockInfo.Trellis.nextStates+1;

    dbType=pirelab.getPirVectorType(ufix1Type,numStates);

    smType=blockInfo.smType;
    bmType=blockInfo.bmType;
    if(blockInfo.issigned)
        sType=pir_sfixpt_t(blockInfo.stateMetWL,0);
    else
        sType=pir_ufixpt_t(blockInfo.stateMetWL,0);
    end


    if((strcmpi(blockInfo.OperationMode,'Continuous')&&(blockInfo.ResetPort))...
        ||~(strcmpi(blockInfo.OperationMode,'Continuous')))
        innames={'branchMetrics','prevStateMet','bmValid','acsRst'};
        intypes=[bmType,smType,ufix1Type,ufix1Type];
        inrates=[dataRate,dataRate,dataRate,dataRate];
    else
        innames={'branchMetrics','prevStateMet','bmValid'};
        intypes=[bmType,smType,ufix1Type];
        inrates=[dataRate,dataRate,dataRate];
    end


    acsengNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ACSEngine',...
    'Inportnames',innames,...
    'InportTypes',intypes,...
    'InportRates',inrates,...
    'Outportnames',{'stateMetrics','decBits','stateMetValid'},...
    'OutportTypes',[smType,dbType,ufix1Type]...
    );

    acsengNetComment=[...
'Instantiate the ACS Units'...
    ,newline...
    ,'Pass the corresponding state metric and branch metric to each instance'...
    ,newline...
    ,'Gather the output of each instance to send as output'...
    ];

    acsengNet.addComment(acsengNetComment);


    bmet=acsengNet.PirInputSignals(1);
    prevsmet=acsengNet.PirInputSignals(2);
    bmvalid=acsengNet.PirInputSignals(3);

    if((strcmpi(blockInfo.OperationMode,'Continuous')&&(blockInfo.ResetPort))...
        ||~(strcmpi(blockInfo.OperationMode,'Continuous')))
        acsrst=acsengNet.PirInputSignals(4);
    end


    smet=acsengNet.PirOutputSignals(1);
    acsdec=acsengNet.PirOutputSignals(2);
    smvalid=acsengNet.PirOutputSignals(3);


    if~(strcmpi(blockInfo.OperationMode,'Continuous'))
        ic=[];
        for i=1:numStates-1
            ic=[ic,blockInfo.stateMetMax];%#ok<*AGROW>
        end
        ic=[blockInfo.stateMetMin,ic];

        initsmet=acsengNet.addSignal(smType,'initStateMet');
        icomp=pirelab.getConstComp(acsengNet,initsmet,ic);
        icomp.addComment('Initial State Metrics')

        prevsmet1=acsengNet.addSignal(smType,'prevsmetd');
        pirelab.getSwitchComp(acsengNet,[initsmet,prevsmet],prevsmet1,acsrst,'','==',1);


        smarray=this.demuxSignal(acsengNet,prevsmet1,'stateMet');
    else

        smarray=this.demuxSignal(acsengNet,prevsmet,'stateMet');
    end


    bmarray=this.demuxSignal(acsengNet,bmet,'bMet');

    decarray(numStates)=acsengNet.addSignal(ufix1Type,['decBit_entry',num2str(numStates)]);
    nxtsmarray(numStates)=acsengNet.addSignal(sType,['nxtMet_entry',num2str(numStates)]);

    for idx=1:numStates

        decarray(idx)=acsengNet.addSignal(ufix1Type,['decBit_entry',num2str(idx)]);


        nxtsmarray(idx)=acsengNet.addSignal(sType,['nxtMet_entry',num2str(idx)]);
    end


    acsunitNet=this.elabACSUnit(acsengNet,blockInfo,sType,dataRate);
    acsunitNet.addComment('Add Compare Select Unit');

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


        acsunitComp=pirelab.instantiateNetwork(acsengNet,acsunitNet,...
        [bmarray(bm0idx),bmarray(bm1idx),smarray(smIdx),smarray(smIdx+1)],...
        [decarray(idx),nxtsmarray(nextStateIdx)],...
        ['ACSUnit',num2str(idx)]);
        acsunitComp.addComment(['ACSUnit',num2str(idx)]);
    end


    this.muxSignal(acsengNet,decarray,acsdec);

    if(strcmpi(blockInfo.OperationMode,'Continuous')&&(blockInfo.ResetPort))
        ic=[];
        for i=1:numStates-1
            ic=[ic,blockInfo.stateMetMax];%#ok<*AGROW>
        end
        ic=[blockInfo.stateMetMin,ic];
        initsmet=acsengNet.addSignal(smType,'initStateMet');
        icomp=pirelab.getConstComp(acsengNet,initsmet,ic);
        icomp.addComment('Initial State Metrics')
        prevsmet1=acsengNet.addSignal(smType,'prevsmetd');
        this.muxSignal(acsengNet,nxtsmarray,prevsmet1);
        pirelab.getSwitchComp(acsengNet,[initsmet,prevsmet1],smet,acsrst,'','==',1);
    else
        this.muxSignal(acsengNet,nxtsmarray,smet);
    end

    pirelab.getWireComp(acsengNet,bmvalid,smvalid);

end