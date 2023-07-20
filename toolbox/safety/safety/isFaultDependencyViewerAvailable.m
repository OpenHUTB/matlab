function[value,msg]=isFaultDependencyViewerAvailable(~)
    [value,msg]=isSafetyAnalyzerInstalledAndLicensed();
    if~value
        return
    end
    value=slfeature('FaultDependencyViewer')>0;
    msg='';
end
