function hIONet=getOBUFDSNetwork(topNet,pirInstance,networkName)




    ufix1Type=pir_ufixpt_t(1,0);

    hIONet=pirelab.createNewNetwork(...
    'PirInstance',pirInstance,...
    'Network',topNet,...
    'Name',networkName,...
    'InportNames',{'I'},...
    'InportTypes',ufix1Type,...
    'OutportNames',{'O','OB'},...
    'OutportTypes',[ufix1Type,ufix1Type]);


    hIONet.addCustomLibraryPackage('UNISIM','vcomponents');


    in_I=hIONet.PirInputSignals(1);
    out_O=hIONet.PirOutputSignals(1);
    out_OB=hIONet.PirOutputSignals(2);


    hInSignals=in_I;
    hOutSignals=[out_O,out_OB];
    pirtarget.getOBUFDSComp(hIONet,hInSignals,hOutSignals);
