function peripheralBlkPreSaveFcn(type,blkH)





    mdl=codertarget.utils.getModelForBlock(blkH);
    if strcmp(get_param(mdl,'BlockDiagramType'),'library'),return;end

    hCS=getActiveConfigSet(mdl);

    appMdl=codertarget.peripherals.AppModel(hCS);
    appMdl.updatePeripheralBlockSID(type,blkH);
end