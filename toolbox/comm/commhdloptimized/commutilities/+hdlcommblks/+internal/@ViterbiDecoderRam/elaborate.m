function nComp=elaborate(this,hN,hC)











    blockInfo=getBlockInfo(this,hC);


    topNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',{'in'},...
    'OutportNames',{'decoded'}...
    );
    topNet.addComment('Top level of RAM-based Viterbi Decoder, consists of three basic components: Branch Metric, ACS,and Traceback ');


    this.elaborateViterbiRamNetwork(topNet,blockInfo);


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

