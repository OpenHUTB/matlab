function invokeViewerForReport(libName)


    try
        hTfl=getEmlTflControl(libName);
        RTW.viewTfl(hTfl);
    catch me %#ok
        RTW.viewTfl(libName);
    end

