function hNewC=elaborate(this,hN,hC)





    newtonInfo=getBlockInfo(this,hC.SimulinkHandle);
    if(newtonInfo.iterNum>1&&hN.isInCRPPartition)
        v=hdlvalidatestruct(2,message('hdlcoder:validate:newtonsqrtincrphierarchy',...
        'RecipSqrtNewton',getfullname(hC.SimulinkHandle)));
        hdlDriver=hdlcurrentdriver;
        check=struct('path',getfullname(hC.SimulinkHandle),...
        'type','block',...
        'message',v.Message,...
        'level','Warning',...
        'MessageID',v.MessageID);

        hdlDriver.updateChecksCatalog(hdlDriver.ModelName,check);
    end

    hNewC=pirelab.getRecipSqrtNewtonComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
    newtonInfo,hC.SimulinkHandle);
end


