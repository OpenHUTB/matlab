function nComp=elaborate(this,hN,hC)






    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=getSysObjInfo(this,sysObjHandle);
    else
        blockInfo=getBlockInfo(this,hC);
    end


    inportnames={[hC.Name,'_in']};
    if blockInfo.hasResetPort
        inportnames{end+1}=[hC.Name,'_reset'];
    end

    outportnames={[hC.Name,'_out']};
    if blockInfo.hasFSt
        outportnames{end+1}=[hC.Name,'_FSt'];
    else
    end




    topNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportnames,...
    'OutportNames',outportnames...
    );

    topNet.addComment('Convolutional Encoder Block');

    topNet.addComment(blockInfo.Comment);


    this.elaborateConvEncoderNetwork(topNet,blockInfo);


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
