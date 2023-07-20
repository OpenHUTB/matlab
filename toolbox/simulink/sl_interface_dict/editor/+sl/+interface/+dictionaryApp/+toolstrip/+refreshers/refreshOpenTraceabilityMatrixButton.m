function refreshOpenTraceabilityMatrixButton(cbinfo,action)%#ok<INUSD>






    [rmiInstalled,rmiLicensed]=rmi.isInstalled();
    action.enabled=rmiInstalled&&rmiLicensed;
end
