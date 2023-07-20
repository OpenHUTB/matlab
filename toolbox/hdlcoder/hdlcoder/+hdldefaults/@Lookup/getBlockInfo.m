function[tablein,tableout,oType_ex]=getBlockInfo(~,hC)


    slbh=hC.SimulinkHandle;
    iType_ex=pirelab.getTypeInfoAsFi(hC.PirInputSignals(1).Type,'Nearest','Saturate');
    tablein=fi(hdlslResolve('InputValues',slbh),fimath(iType_ex),numerictype(iType_ex));
    tableout=hdlslResolve('OutputValues',slbh);
    oType_ex=pirelab.getTypeInfoAsFi(hC.PirOutputSignals(1).Type,'Nearest','Saturate');
