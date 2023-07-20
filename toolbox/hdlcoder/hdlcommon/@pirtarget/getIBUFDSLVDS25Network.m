function hIONet=getIBUFDSLVDS25Network(topNet,pirInstance,networkName)




    ufix1Type=pir_ufixpt_t(1,0);

    hIONet=pirelab.createNewNetwork(...
    'PirInstance',pirInstance,...
    'Network',topNet,...
    'Name',networkName,...
    'InportNames',{'I','IB'},...
    'InportTypes',[ufix1Type,ufix1Type],...
    'OutportNames',{'O'},...
    'OutportTypes',ufix1Type);


    hIONet.addCustomLibraryPackage('UNISIM','vcomponents');


    in_I=hIONet.PirInputSignals(1);
    in_IB=hIONet.PirInputSignals(2);
    out_O=hIONet.PirOutputSignals(1);


    hInSignals=[in_I,in_IB];
    hOutSignals=out_O;
    pirtarget.getIBUFDSLVDS25Comp(hIONet,hInSignals,hOutSignals);
