function success=buildCustomCodeForModel(modelHandle)


    try
        slcc('buildCustomCodeForModel',modelHandle);
        success=true;
    catch ME
        reportAsError(MSLDiagnostic(ME),get_param(modelHandle,'Name'),1);
        success=false;
    end