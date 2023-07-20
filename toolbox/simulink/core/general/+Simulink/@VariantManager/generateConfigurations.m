function varargout=generateConfigurations(modelName,varargin)

































































































    [isInstalled,err]=slvariants.internal.utils.getVMgrInstallInfo('Variant Manager');
    if~isInstalled
        throwAsCaller(err);
    end

    environment=slvariants.internal.manager.configgen.Environment();
    cleanup=onCleanup(@()delete(environment));
    try
        isModelLoadedAlready=bdIsLoaded(modelName);
        if~isModelLoadedAlready
            load_system(modelName);
        end
        [varargout{1:nargout}]=generateConfigurationsImpl(modelName,varargin{:});
    catch excep

        throwAsCaller(excep);
    end
end

function varargout=generateConfigurationsImpl(modelName,varargin)
    nargoutchk(0,2);
    parsedInputStruct=slvariants.internal.manager.configgen.parseInputs(modelName,varargin{:});
    bdHandle=get_param(parsedInputStruct.ModelName,'Handle');
    logger=slvariants.internal.manager.configgen.EnvLogger(parsedInputStruct);
    slvariants.internal.manager.configgen.preProcessDataFromModel(bdHandle);
    slvariants.internal.manager.configgen.generateConfigs(bdHandle,...
    parsedInputStruct.Precondition);
    [varargout{1:nargout}]=slvariants.internal.manager.configgen.constructOutput(parsedInputStruct);
    cfgInfo=[];
    if numel(varargout)==2
        cfgInfo=varargout{2};
    end
    logger.setConfigGenOutput(struct('VCDO',varargout{1},'ConfigsInfo',cfgInfo));
end
