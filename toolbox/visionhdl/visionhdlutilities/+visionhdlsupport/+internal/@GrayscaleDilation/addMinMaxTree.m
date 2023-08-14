function mmNet=addMinMaxTree(~,topNet,blockInfo,sigInfo,inRate,inPortSignals,outPortSignals,numElements)




    inType=sigInfo.inType;






    mmNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MinMaxTree',...
    'InportSignals',inPortSignals,...
    'OutportSignals',outPortSignals);


    mmNet.PirOutputSignals.SimulinkRate=mmNet.PirInputSignals.SimulinkRate;





    if numElements>1
        pirelab.getTreeArch(mmNet,mmNet.PirInputSignals,mmNet.PirOutputSignals,...
        'max','floor','wrap','max','Zero',true);
    else
        pirelab.getWireComp(mmNet,mmNet.PirInputSignals,mmNet.PirOutputSignals);
    end
