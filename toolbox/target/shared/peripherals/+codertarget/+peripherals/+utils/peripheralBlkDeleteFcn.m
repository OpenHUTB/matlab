function peripheralBlkDeleteFcn(type,blkH)





    mdl=codertarget.utils.getModelForBlock(blkH);
    if strcmp(get_param(mdl,'BlockDiagramType'),'library'),return;end


    appMdl=codertarget.peripherals.AppModel(mdl);
    appMdl.removePeripheralInfoFromModel(blkH,type);
end
