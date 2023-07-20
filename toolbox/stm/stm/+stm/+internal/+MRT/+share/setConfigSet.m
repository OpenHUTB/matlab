function[cleanupStruct,out]=setConfigSet(modelToRun,configName,configPath,configVarName,configSetOverrideSetting,~)
    cleanupStruct=[];










    out.messages={};
    out.errorOrLog={};




    loadConfigSetFromFile=configSetOverrideSetting==2;
    if(loadConfigSetFromFile)


        if isempty(configPath)
            out.messages{end+1}=stm.internal.MRT.share.getString('stm:general:NoExternalReferenceSpecified');
            out.errorOrLog{end+1}=false;
        else



            configVal=loadConfigFromMATFile(configPath,configVarName);
            cleanupStruct=placeConfigInBaseWorkspace(configVarName,configVal,cleanupStruct);
            [configName,cleanupStruct]=attachConfigCopyToModel(modelToRun,configVal,cleanupStruct);
        end
    end




    testConfigIsAttachedToModel=~isempty(configName)&&configSetOverrideSetting~=0;
    if(testConfigIsAttachedToModel)
        testConfigSet=getConfigSet(modelToRun,configName);
        if isempty(testConfigSet)
            stm.internal.MRT.share.error('stm:general:ConfigSetNotFound',configName);
        end
    else
        testConfigSet=getActiveConfigSet(modelToRun);
    end


    currConfigSet=getActiveConfigSet(modelToRun);
    cleanupStruct.currConfigSet=currConfigSet;



    if isa(testConfigSet,'Simulink.ConfigSetRef')

        copiedConfigSet=copyConfigRef(testConfigSet);


        preserveDirty=Simulink.PreserveDirtyFlag(get_param(modelToRun,'Handle'),'blockDiagram');
        attachConfigSet(modelToRun,copiedConfigSet,true);
        delete(preserveDirty);
        copiedConfigSetName=copiedConfigSet.Name;
        preserveDirty=Simulink.PreserveDirtyFlag(get_param(modelToRun,'Handle'),'blockDiagram');
        setActiveConfigSet(modelToRun,copiedConfigSetName);
        delete(preserveDirty);


        cleanupStruct.removeConfigSet1=copiedConfigSetName;
    else
        setActiveConfigSet(modelToRun,testConfigSet.Name);
    end
end

function configVal=loadConfigFromMATFile(configPath,configVarName)


    [~,~,ext]=fileparts(configPath);


    if~exist(configPath,'file')
        stm.internal.MRT.share.error('stm:general:ConfigurationSetFileNotFound',configPath);
    end


    if~strcmpi(ext,'.mat')
        stm.internal.MRT.share.error('stm:general:FileFormatShouldBeMAT',configPath);
    end


    vars=whos('-file',configPath);
    if isempty(configVarName)||isempty(vars)||~ismember(configVarName,{vars.name})
        stm.internal.MRT.share.error('stm:general:ConfigSetVariableNotFound',configVarName,configPath);
    end


    outStruct=load(configPath,configVarName);
    configVal=outStruct.(configVarName);


    isAConfigSet=isa(configVal,'Simulink.ConfigSet');
    isAConfigRef=isa(configVal,'Simulink.ConfigSetRef');
    isAValidConfig=isAConfigSet||isAConfigRef;

    if~isAValidConfig
        stm.internal.MRT.share.error('stm:general:NotAValidConfigSet',configVarName);
    end

end

function cleanupStruct=placeConfigInBaseWorkspace(configVarName,configVal,cleanupStruct)

    configVarCleanup=stm.internal.util.RestoreVariable(configVarName);
    cleanupStruct.baseWsConfigVarName=configVarCleanup;
    assignin('base',configVarName,configVal);

end

function[attachedConfigName,cleanupStruct]=attachConfigCopyToModel(model,configToAttach,cleanupStruct)


    configToAttach.Name=['__stm__',configToAttach.Name];
    attachConfigSetCopy(model,configToAttach);


    attachedConfigName=configToAttach.Name;
    cleanupStruct.removeConfigSet=attachedConfigName;

end

function copiedConfigSet=copyConfigRef(configRefToCopy)

    refConfSet=getRefConfigSet(configRefToCopy);
    copiedConfigSet=copy(refConfSet);


    configRefHasOverrides=~isempty(configRefToCopy.ParameterOverrides);
    if configRefHasOverrides

        paramOverrides=configRefToCopy.ParameterOverrides;
        paramOverrideValues=configRefToCopy.ParameterOverrideValues;

        for overrideIdx=1:length(paramOverrides)
            param=paramOverrides{overrideIdx};
            value=paramOverrideValues{overrideIdx};
            copiedConfigSet.set_param(param,value);
        end

    end

end