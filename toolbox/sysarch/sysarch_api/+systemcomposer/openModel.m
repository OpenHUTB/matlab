function zcModel=openModel(modelName)

    try
        if~systemcomposer.internal.isSystemComposerModel(modelName)
            msgObj=message('SystemArchitecture:API:ModelNotSystemComposer');
            exception=MException('systemcomposer:API:ModelNotSystemComposer',msgObj.getString);
            throw(exception);
        end
        [~,mdlName,~]=fileparts(modelName);
        open_system(mdlName);
        bdH=get_param(mdlName,'Handle');
    catch ex
        msgObj=message('SystemArchitecture:API:OpenModelError',modelName);
        exception=MException('systemcomposer:API:OpenModelError',msgObj.getString);
        exception=exception.addCause(ex);
        throw(exception);
    end
    archSubDomain=get_param(bdH,'SimulinkSubDomain');
    zcModel=systemcomposer.arch.Model.empty;
    if any(strcmpi(archSubDomain,{'Architecture','SoftwareArchitecture','AutosarArchitecture'}))
        zcModel=systemcomposer.arch.Model(bdH);
    end

end

