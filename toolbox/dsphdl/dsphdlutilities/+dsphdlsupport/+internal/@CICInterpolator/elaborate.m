function hNewComp=elaborate(this,hN,hC)














    blockInfo=getBlockInfo(this,hC);
    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    slRate=hInSignals(1).SimulinkRate;

    inportnames{1}='dataIn';
    inportnames{2}='validIn';
    if blockInfo.inMode(2)&&blockInfo.inMode(3)
        inportnames{3}='R';
        inportnames{4}='syncReset';
    elseif blockInfo.inMode(2)&&~blockInfo.inMode(3)
        inportnames{3}='R';
    elseif~blockInfo.inMode(2)&&blockInfo.inMode(3)
        inportnames{3}='syncReset';
    end
    outportnames{1}='dataOut';
    outportnames{2}='validOut';
    outportnames{3}='readyOut';


    hTopN=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'Name','CICInterpolator',...
    'InportNames',inportnames,...
    'OutportNames',outportnames...
    );

    blockInfo.inResetSS=hN.isInResettableHierarchy;


    for loop=1:numel(hTopN.PirOutputSignals)
        hTopN.PirOutputSignals(loop).SimulinkRate=slRate;
    end


    this.elabCICInterpolator(hTopN,blockInfo,slRate);





    if blockInfo.inResetSS
        hTopN.setTreatNetworkAsResettableBlock;
    end


    hNewComp=pirelab.instantiateNetwork(hN,hTopN,hInSignals,hOutSignals,...
    [hC.Name,'_inst']);
    hNewComp.addComment('StartHere');