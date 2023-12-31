function nComp=elaborate(this,hN,hC)






    blockInfo=getBlockInfo(this,hC);


    inportnames={[hC.Name,'_in'],...
    [hC.Name,'_start'],...
    [hC.Name,'_end'],...
    [hC.Name,'_datavalid'],...
    };


    outportnames={[hC.Name,'_out'],...
    [hC.Name,'_startout'],...
    [hC.Name,'_endout'],...
    [hC.Name,'_datavalidout'],...
    };



    topNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportnames,...
    'OutportNames',outportnames...
    );

    topNet.addComment('Reed-Solomon Encoder Block');


    this.elaborateRSEncoderNetwork(topNet,blockInfo);


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
