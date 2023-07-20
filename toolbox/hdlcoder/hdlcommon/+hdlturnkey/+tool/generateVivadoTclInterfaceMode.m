function generateVivadoTclInterfaceMode(hDI,fid,interfaceName,channelDirType)





    downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclInterfaceMode',...
    fid,interfaceName,channelDirType);

end