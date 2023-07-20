function configName=getPreferredConfigurationName(modelName)















    [isInstalled,err]=slvariants.internal.utils.getVMgrInstallInfo('Simulink.VariantManager.getPreferredConfigurationName');
    if~isInstalled
        throwAsCaller(err);
    end

    narginchk(1,1);
    nargoutchk(0,1);

    if~ischar(modelName)&&~(isstring(modelName)&&isscalar(modelName))
        messageId='Simulink:Variants:InvalidModelName';
        excepObj=MException(message(messageId));
        throwAsCaller(excepObj);
    end

    if~isvarname(modelName)

        excepObj=MException(message('Simulink:LoadSave:InvalidBlockDiagramName',modelName));
        throwAsCaller(excepObj);
    end

    if~bdIsLoaded(modelName)

        excepObj=MException(message('Simulink:VariantManager:ModelNotLoaded',modelName));
        throwAsCaller(excepObj);
    end

    vcdoName=get_param(modelName,'VariantConfigurationObject');

    if isempty(vcdoName)
        configName='';
        return;
    end


    try
        vcdoObj=Simulink.VariantConfigurationData.getFor(modelName);
    catch ME
        throwAsCaller(ME);
    end

    configName=vcdoObj.PreferredConfiguration;
end
