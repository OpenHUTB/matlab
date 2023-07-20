function generateVivadoTclParameter(hDI,fid,interfaceName,parameterName,parameterValue)





    downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclParameter',...
    fid,interfaceName,parameterName,parameterValue);

end