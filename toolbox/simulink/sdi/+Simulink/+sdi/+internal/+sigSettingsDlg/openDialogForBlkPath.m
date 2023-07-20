


function openDialogForBlkPath(blkPath,portIdx,mdl)

    blkH=get_param(blkPath,'handle');
    portHandles=get_param(blkH,'PortHandles');
    portH=portHandles.Outport(str2double(portIdx));
    cbinfo.userdata.mdl=mdl;
    cbinfo.userdata.portH=portH;
    Simulink.sdi.internal.sigSettingsDlg.openDialog(cbinfo);
end

