function hwiBlkCopyFcn(blkH)




    mdl=codertarget.utils.getModelForBlock(blkH);
    mdlName=get(mdl,'Name');
    if strcmp(get_param(mdl,'BlockDiagramType'),'library'),return;end

    if codertarget.peripherals.AppModel.isProcessorModel(bdroot(blkH))




        codertarget.internal.taskmapper.addHWIInfo(mdlName,blkH);

    end
end