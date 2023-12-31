

function RdAddrGenerator(~,hN,RdAddrGenInSigs,RdAddrGenOutSigs,hBoolT,hAddrT,...
    slRate,blockInfo)


    hRdAddrGenN=pirelab.createNewNetwork(...
    'Name','RdAddrGenerator',...
    'InportNames',{'lowerTriangEnb','fwdSubEnb','matMultEnb','rdAddrOut'...
    ,'rdAddrLT','rdAddrFwdSub','rdAddrMatMult','outStreamEnb'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT,hAddrT,...
    RdAddrGenInSigs(5).Type,...
    RdAddrGenInSigs(6).Type,...
    RdAddrGenInSigs(7).Type,...
    hBoolT],...
    'InportRates',slRate*ones(1,8),...
    'OutportNames',{'rdAddr'},...
    'OutportTypes',pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize+1,0]));

    hRdAddrGenN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hRdAddrGenN.PirOutputSignals)
        hRdAddrGenN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hRdAddrGenNinSigs=hRdAddrGenN.PirInputSignals;
    hRdAddrGenNoutSigs=hRdAddrGenN.PirOutputSignals;

    Constant19_out1_s8=l_addSignal(hRdAddrGenN,'Constant19_out1',hAddrT,slRate);
    Switch1_out1_s5=l_addSignal(hRdAddrGenN,'Switch1_out1',hAddrT,slRate);
    SwitchReciprocalS=l_addSignal(hRdAddrGenN,'SwitchReciprocal',hAddrT,slRate);

    rdAddrLTSplitS=hRdAddrGenNinSigs(5).split;
    rdAddrFwdSubSplitS=hRdAddrGenNinSigs(6).split;

    if(blockInfo.RowSize>1)

        rdAddrMatMultSplitS=hRdAddrGenNinSigs(7).split;
        rdAddrMatMultSplitSigS=rdAddrMatMultSplitS.PirOutputSignals;
    else

        rdAddrMatMultSplitS=hRdAddrGenNinSigs(7);
        rdAddrMatMultSplitSigS=rdAddrMatMultSplitS;
    end

    pirelab.getConstComp(hRdAddrGenN,...
    Constant19_out1_s8,...
    0,...
    'Constant19','on',1,'','','');

    RdAddrArray=hdlhandles(blockInfo.RowSize,1);

    SwitchStreamS=hdlhandles(blockInfo.RowSize,1);
    SwitchLTS=hdlhandles(blockInfo.RowSize,1);
    SwitchFwdSubS=hdlhandles(blockInfo.RowSize,1);
    SwitchMatMultS=hdlhandles(blockInfo.RowSize,1);

    for itr=1:blockInfo.RowSize

        suffix=['_',int2str(itr)];
        SwitchStreamS(itr)=l_addSignal(hRdAddrGenN,['SwitchStream',suffix],hAddrT,slRate);
        SwitchLTS(itr)=l_addSignal(hRdAddrGenN,['SwitchLT',suffix],hAddrT,slRate);
        SwitchFwdSubS(itr)=l_addSignal(hRdAddrGenN,['SwitchFwdSub',suffix],hAddrT,slRate);
        SwitchMatMultS(itr)=l_addSignal(hRdAddrGenN,['SwitchMatMult',suffix],hAddrT,slRate);

        pirelab.getSwitchComp(hRdAddrGenN,...
        [hRdAddrGenNinSigs(4),SwitchLTS(itr)],...
        SwitchStreamS(itr),...
        hRdAddrGenNinSigs(8),['SwitchStream',suffix],...
        '~=',0,'Floor','Wrap');


        pirelab.getSwitchComp(hRdAddrGenN,...
        [rdAddrLTSplitS.PirOutputSignals(itr),SwitchFwdSubS(itr)],...
        SwitchLTS(itr),...
        hRdAddrGenNinSigs(1),['SwitchLT',suffix],...
        '~=',0,'Floor','Wrap');


        pirelab.getSwitchComp(hRdAddrGenN,...
        [rdAddrFwdSubSplitS.PirOutputSignals(itr),SwitchMatMultS(itr)],...
        SwitchFwdSubS(itr),...
        hRdAddrGenNinSigs(2),['SwitchFwdSub',suffix],...
        '~=',0,'Floor','Wrap');

        pirelab.getSwitchComp(hRdAddrGenN,...
        [rdAddrMatMultSplitSigS(itr),Constant19_out1_s8],...
        SwitchMatMultS(itr),...
        hRdAddrGenNinSigs(3),['SwitchMatMult',suffix],...
        '~=',0,'Floor','Wrap');
        RdAddrArray(itr)=SwitchStreamS(itr);
    end

    pirelab.getSwitchComp(hRdAddrGenN,...
    [rdAddrFwdSubSplitS.PirOutputSignals(blockInfo.RowSize+1),Constant19_out1_s8],...
    Switch1_out1_s5,...
    hRdAddrGenNinSigs(2),'Switch1',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hRdAddrGenN,...
    [rdAddrLTSplitS.PirOutputSignals(blockInfo.RowSize+1),Switch1_out1_s5],...
    SwitchReciprocalS,...
    hRdAddrGenNinSigs(1),'Switch16',...
    '~=',0,'Floor','Wrap');

    pirelab.getMuxComp(hRdAddrGenN,...
    [(RdAddrArray(1:end))',SwitchReciprocalS],...
    hRdAddrGenNoutSigs(1),...
    'concatenate');

    pirelab.instantiateNetwork(hN,hRdAddrGenN,RdAddrGenInSigs,RdAddrGenOutSigs,...
    [hRdAddrGenN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
