function cb_close(ddgdialog)




    dialogSource=ddgdialog.getDialogSource();
    dialogSource.closeCallback(ddgdialog);
    blk=dialogSource.getBlock;
    block=getFullName(blk);

    map=Simulink.signaleditorblock.ListenerMap.getInstance;
    map.removeListener(num2str(getSimulinkBlockHandle(block),32));
    try
        Simulink.signaleditorblock.MaskSetting.enableMaskInitialization(block);
    catch




    end
end
