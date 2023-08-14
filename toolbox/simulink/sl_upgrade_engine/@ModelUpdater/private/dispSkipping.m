function dispSkipping(h,block)





    name=cleanBlockName(h,block);
    SL_SlupdateSkipping=DAStudio.message('SimulinkUpgradeEngine:engine:skipping',name);
    fprintf(SL_SlupdateSkipping);

end