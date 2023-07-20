function openPeripheralConfigurationFromBlockCb(blk)








    mdl=codertarget.utils.getModelForBlock(get_param(blk,'Handle'));
    if strcmp(get_param(mdl,'BlockDiagramType'),'library'),return;end
    if~codertarget.peripherals.AppModel.isProcessorModel(mdl)
        errordlg(message('codertarget:peripherals:NoHardwareMappingData',get_param(mdl,'Name')).getString());
        return;
    end

    hCS=getActiveConfigSet(bdroot(blk));
    codertarget.peripherals.utils.openPeripheralConfiguration(hCS,blk);
end
