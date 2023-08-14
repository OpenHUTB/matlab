





function[bSuccess,aSystemType]=SystemTypeFactory(aSystemOrBlockContext)
    bSuccess=false;
    aSystemType=[];

    try
        aSystemHandle=aSystemOrBlockContext.blockHandle;

        if~ishandle(aSystemHandle)
            return;
        end

        modelName=bdroot(aSystemHandle);
        modelHandle=get_param(modelName,'Handle');
        isRootModel=isequal(modelHandle,aSystemHandle);
        if isRootModel&&Simulink.internal.isArchitectureModel(modelHandle)
            aSystemType="SYSTEM_COMPOSER";
        elseif isfield(aSystemOrBlockContext,'isMaskOnModel')&&aSystemOrBlockContext.isMaskOnModel
            if isMaskOnSSRef(aSystemOrBlockContext)
                aSystemType="SUBSYSTEM_OR_CORE_BLOCK";
            else
                aSystemType="SYSTEM_MASK";
            end
        elseif isfield(aSystemOrBlockContext,'isMaskOnSystemObject')&&aSystemOrBlockContext.isMaskOnSystemObject
            aSystemType="SYSTEM_OBJECT_MASK";
        else
            if Simulink.internal.isArchitectureModel(modelHandle)&&~strcmpi(get_param(get_param(aSystemHandle,'Parent'),'SimulinkSubDomain'),'Simulink')
                aSystemType='SYSTEM_COMPOSER';
            else
                aSystemType="SUBSYSTEM_OR_CORE_BLOCK";
            end
        end

        bSuccess=true;

    catch exp
        msg=slprivate('getExceptionMsgReport',exp);
        showDialog(msg);
    end
end

function isMaskOnSSRef=isMaskOnSSRef(aSytemOrBlockContext)
    isMaskOnSSRef=false;
    aModelHdl=bdroot(aSytemOrBlockContext.blockHandle);
    if strcmp(get_param(aModelHdl,'blockdiagramtype'),'subsystem')
        isMaskOnSSRef=true;
    end
end