function nComp=elaborate(this,hN,hC)






    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=getSysObjInfo(this,sysObjHandle);
    else
        blockInfo=getBlockInfo(this,hC);
    end

    inportnames={[hC.Name,'_in']};
    if blockInfo.hasResetPort
        inportnames{end+1}=[hC.Name,'_rst'];
    end


    topNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportnames,...
    'OutportNames',{'decoded'}...
    );
    topNet.addComment('Top level of Viterbi Decoder, consists of three basic components: Branch Metric, ACS,and Traceback ');


    this.elaborateViterbiNetwork(topNet,blockInfo);


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
