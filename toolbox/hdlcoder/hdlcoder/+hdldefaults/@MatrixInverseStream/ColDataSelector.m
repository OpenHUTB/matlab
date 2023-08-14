



function ColDataSelector(~,hN,ColDataSelInSigs,ColDataSelOutSigs,...
    slRate,blockInfo)


    hColDataSelN=pirelab.createNewNetwork(...
    'Name','ColDataSelector',...
    'InportNames',{'colCount','rdData'},...
    'InportTypes',[ColDataSelInSigs(1).Type,ColDataSelInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'colData'},...
    'OutportTypes',ColDataSelOutSigs(1).Type);

    hColDataSelN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hColDataSelN.PirOutputSignals)
        hColDataSelN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hColDataSelNinSigs=hColDataSelN.PirInputSignals;
    hColDataSelNoutSigs=hColDataSelN.PirOutputSignals;


    hBoolT=pir_boolean_t;
    hInputDataT=pir_single_t;


    Constant5_out1_s5=l_addSignal(hColDataSelN,'Constant5_out1',hInputDataT,slRate);

    rdData=hColDataSelNinSigs(2);
    rdDataSplitS=rdData.split;
    colCount=hColDataSelNinSigs(1);
    colData=hColDataSelNoutSigs(1);

    pirelab.getConstComp(hColDataSelN,...
    Constant5_out1_s5,...
    single(0),...
    'Constant5','on',1,'','','');

    SwitchOutArray=hdlhandles(blockInfo.RowSize-1,1);

    CompareToConstantS=hdlhandles(blockInfo.RowSize-1,1);
    SwitchS=hdlhandles(blockInfo.RowSize-1,1);


    for itr=1:blockInfo.RowSize-1

        suffix=['_',int2str(itr)];

        CompareToConstantS(itr)=l_addSignal(hColDataSelN,['CompareToConstant',suffix],...
        hBoolT,slRate);
        SwitchS(itr)=l_addSignal(hColDataSelN,['Switch',suffix],hInputDataT,slRate);

        pirelab.getCompareToValueComp(hColDataSelN,...
        colCount,...
        CompareToConstantS(itr),...
        '>=',itr+1,...
        ['CompareToConstant',suffix],0);

        pirelab.getSwitchComp(hColDataSelN,...
        [Constant5_out1_s5,rdDataSplitS.PirOutputSignals(itr)],...
        SwitchS(itr),...
        CompareToConstantS(itr),['Switch',suffix],...
        '~=',0,'Floor','Wrap');

        SwitchOutArray(itr)=SwitchS(itr);

    end

    pirelab.getMuxComp(hColDataSelN,...
    [(SwitchOutArray(1:end))',rdDataSplitS.PirOutputSignals(blockInfo.RowSize)],...
    colData,...
    'concatenate');


    pirelab.instantiateNetwork(hN,hColDataSelN,ColDataSelInSigs,ColDataSelOutSigs,...
    [hColDataSelN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
