function invokeViewerForReport(mdlName,libName)


    try
        hTfl=get_param(mdlName,'TargetFcnLibHandle');
        RTW.viewTfl(hTfl);
    catch me %#ok
        RTW.viewTfl(libName);
    end

