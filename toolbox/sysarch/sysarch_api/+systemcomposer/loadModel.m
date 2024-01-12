function zcModel=loadModel(modelName)

    try
        bdH=load_system(modelName);
    catch ex
        msgObj=message('SystemArchitecture:API:LoadModelError',modelName);
        exception=MException('systemcomposer:API:LoadModelError',msgObj.getString);
        exception=exception.addCause(ex);
        throw(exception);
    end
    archSubDomain=get_param(bdH,'SimulinkSubDomain');
    zcModel=systemcomposer.arch.Model.empty;
    if any(strcmpi(archSubDomain,{'Architecture','SoftwareArchitecture','AutosarArchitecture'}))
        zcModel=systemcomposer.arch.Model(bdH);
    end
end
