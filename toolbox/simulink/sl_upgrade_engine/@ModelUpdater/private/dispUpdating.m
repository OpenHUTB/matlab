function dispUpdating(h,block,reason)





    if(doUpdate(h))
        SL_SlupdateUpdating=DAStudio.message(...
        'SimulinkUpgradeEngine:engine:updatingProgress',block,reason);
        fprintf(SL_SlupdateUpdating);
    end

end