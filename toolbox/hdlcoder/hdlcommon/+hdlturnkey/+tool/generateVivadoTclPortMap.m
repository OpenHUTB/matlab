function generateVivadoTclPortMap(hDI,fid,interfaceName,xilinxPortID,interfacePortID)





    if nargin<5
        downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclPortMap',...
        fid,interfaceName,xilinxPortID);
    else
        downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclPortMap',...
        fid,interfaceName,xilinxPortID,interfacePortID);
    end

end