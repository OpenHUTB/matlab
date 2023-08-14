function success=parseCustomCode(modelHandle,forceSync)


    if nargin<2
        forceSync=false;
    end
    try
        slcc('parseCustomCode',modelHandle,forceSync);
        success=true;
    catch ME
        reportAsError(MSLDiagnostic(ME),get_param(modelHandle,'Name'),1);
        success=false;
    end