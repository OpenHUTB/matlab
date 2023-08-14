function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);

    outportnames{1}='Sine Wave_out1';


    topNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'OutportNames',outportnames...
    );

    topNet.addComment('Sine Wave');

    this.elaborateTopLevel(topNet,blockInfo);


    nComp=pirelab.instantiateNetwork(hN,topNet,[],hC.PirOutputSignals,hC.Name);

end