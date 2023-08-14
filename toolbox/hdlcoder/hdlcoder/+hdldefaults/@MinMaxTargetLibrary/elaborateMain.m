function hNewC=elaborateMain(this,hN,blockComp)




    hInSignals=blockComp.PirInputSignals;
    hOutSignals=blockComp.PirOutputSignals;
    fname=get_param(blockComp.SimulinkHandle,'Function');
    nfpOptions=getNFPBlockInfo(this);

    hNewC=pirelab.getMinMaxComp(hN,hInSignals,hOutSignals,...
    blockComp.Name,fname,false,'Value',true,'',...
    blockComp.SimulinkHandle,nfpOptions);
