

function WrtEnbGenerator(~,hN,WrtEnbGenInSigs,WrtEnbGenOutSigs,hBoolT,slRate,...
    blockInfo)


    hWrtEnbGenN=pirelab.createNewNetwork(...
    'Name','WrtEnbGenerator',...
    'InportNames',{'validIn','ready','lowerTriangEnb','fwdSubEnb',...
    'matMultEnb','wrtEnbStore','wrtEnbLT','wrtEnbFwdSub',...
    'wrtEnbMatMult'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT,hBoolT,hBoolT,...
    WrtEnbGenInSigs(6).Type,...
    WrtEnbGenInSigs(7).Type,...
    WrtEnbGenInSigs(8).Type,...
    WrtEnbGenInSigs(9).Type],...
    'InportRates',slRate*ones(1,9),...
    'OutportNames',{'wrtEnb'},...
    'OutportTypes',pirelab.createPirArrayType(hBoolT,[blockInfo.RowSize+1,0]));

    hWrtEnbGenN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrtEnbGenN.PirOutputSignals)
        hWrtEnbGenN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hWrtEnbGenNinSigs=hWrtEnbGenN.PirInputSignals;
    hWrtEnbGenNoutSigs=hWrtEnbGenN.PirOutputSignals;

    LogicalOperator_out1_s26=l_addSignal(hWrtEnbGenN,sprintf('Logical\nOperator_out1'),...
    hBoolT,slRate);
    Constant19_out1_s8=l_addSignal(hWrtEnbGenN,'Constant19_out1',hBoolT,slRate);
    SwitchReciprocalS=l_addSignal(hWrtEnbGenN,'SwitchReciprocal',hBoolT,slRate);

    wrtEnbLTSplitS=hWrtEnbGenNinSigs(7).split;
    wrtEnbLTSplitSigS=wrtEnbLTSplitS.PirOutputSignals;

    if blockInfo.RowSize>1
        wrtEnbStoreSplitS=hWrtEnbGenNinSigs(6).split;
        wrtEnbStoreSplitSigS=wrtEnbStoreSplitS.PirOutputSignals;




        wrtEnbFwdSubSplitS=hWrtEnbGenNinSigs(8).split;
        wrtEnbFwdSubSplitSigS=wrtEnbFwdSubSplitS.PirOutputSignals;


        wrtEnbMatMultSplitS=hWrtEnbGenNinSigs(9).split;
        wrtEnbMatMultSplitSigS=wrtEnbMatMultSplitS.PirOutputSignals;

    else
        wrtEnbStoreSplitS=hWrtEnbGenNinSigs(6);
        wrtEnbStoreSplitSigS=wrtEnbStoreSplitS;


        wrtEnbFwdSubSplitS=hWrtEnbGenNinSigs(8);
        wrtEnbFwdSubSplitSigS=wrtEnbFwdSubSplitS;


        wrtEnbMatMultSplitS=hWrtEnbGenNinSigs(9);
        wrtEnbMatMultSplitSigS=wrtEnbMatMultSplitS;

    end


    pirelab.getLogicComp(hWrtEnbGenN,...
    [hWrtEnbGenNinSigs(1),hWrtEnbGenNinSigs(2)],...
    LogicalOperator_out1_s26,...
    'and',sprintf('Logical\nOperator'));

    pirelab.getConstComp(hWrtEnbGenN,...
    Constant19_out1_s8,...
    0,...
    'Constant19','on',1,'','','');
    WrtEnbArray=hdlhandles(blockInfo.RowSize,1);

    SwitchStoreS=hdlhandles(blockInfo.RowSize,1);
    SwitchLTS=hdlhandles(blockInfo.RowSize,1);
    SwitchFwdSubS=hdlhandles(blockInfo.RowSize,1);
    SwitchMatMultS=hdlhandles(blockInfo.RowSize,1);

    for itr=1:blockInfo.RowSize

        suffix=['_',int2str(itr)];

        SwitchStoreS(itr)=l_addSignal(hWrtEnbGenN,['SwitchStore',suffix],hBoolT,slRate);
        SwitchLTS(itr)=l_addSignal(hWrtEnbGenN,['SwitchLT',suffix],hBoolT,slRate);
        SwitchFwdSubS(itr)=l_addSignal(hWrtEnbGenN,['SwitchFwdSub',suffix],hBoolT,slRate);
        SwitchMatMultS(itr)=l_addSignal(hWrtEnbGenN,['SwitchMatMult',suffix],hBoolT,slRate);



        pirelab.getSwitchComp(hWrtEnbGenN,...
        [wrtEnbStoreSplitSigS(itr),SwitchLTS(itr)],...
        SwitchStoreS(itr),...
        LogicalOperator_out1_s26,['SwitchStore',suffix],...
        '~=',0,'Floor','Wrap');


        pirelab.getSwitchComp(hWrtEnbGenN,...
        [wrtEnbLTSplitSigS(itr),SwitchFwdSubS(itr)],...
        SwitchLTS(itr),...
        hWrtEnbGenNinSigs(3),['SwitchLT',suffix],...
        '~=',0,'Floor','Wrap');


        pirelab.getSwitchComp(hWrtEnbGenN,...
        [wrtEnbFwdSubSplitSigS(itr),SwitchMatMultS(itr)],...
        SwitchFwdSubS(itr),...
        hWrtEnbGenNinSigs(4),['SwitchFwdSub',suffix],...
        '~=',0,'Floor','Wrap');


        pirelab.getSwitchComp(hWrtEnbGenN,...
        [wrtEnbMatMultSplitSigS(itr),Constant19_out1_s8],...
        SwitchMatMultS(itr),...
        hWrtEnbGenNinSigs(5),['SwitchMatMult',suffix],...
        '~=',0,'Floor','Wrap');

        WrtEnbArray(itr)=SwitchStoreS(itr);
    end

    pirelab.getSwitchComp(hWrtEnbGenN,...
    [wrtEnbLTSplitSigS(blockInfo.RowSize+1),Constant19_out1_s8],...
    SwitchReciprocalS,...
    hWrtEnbGenNinSigs(3),'SwitchReciprocal',...
    '~=',0,'Floor','Wrap');

    pirelab.getMuxComp(hWrtEnbGenN,...
    [(WrtEnbArray(1:end))',SwitchReciprocalS],...
    hWrtEnbGenNoutSigs(1),...
    'concatenate');


    pirelab.instantiateNetwork(hN,hWrtEnbGenN,WrtEnbGenInSigs,WrtEnbGenOutSigs,...
    [hWrtEnbGenN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
