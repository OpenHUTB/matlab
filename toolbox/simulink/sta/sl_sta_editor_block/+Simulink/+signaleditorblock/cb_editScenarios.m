function cb_editScenarios(obj)





    dialogSource=obj.getDialogSource();
    blk=dialogSource.getBlock;
    blockPath=getFullName(blk);
    Simulink.signaleditorblock.launchEditorForBlock(getSimulinkBlockHandle(blockPath));

end
