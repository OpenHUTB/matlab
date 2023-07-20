function generateVivadoTclInterfaceDefinition(hDI,fid,interfaceName,abstractionVLNV,busVLNV)





    downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclInterfaceDefinition',...
    fid,interfaceName,abstractionVLNV,busVLNV);

end
