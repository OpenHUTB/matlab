function setModelForCoderTarget(hCS,hardwareName)




    if~codertarget.target.supportsCoderTarget(hCS)
        if~isequal(get_param(hCS,'SystemTargetFile'),'autosar.tlc')
            if isequal(get_param(hCS,'SystemTargetFile'),'ert.tlc')

                set_param(hCS,'SystemTargetFile','grt.tlc');
            end
            set_param(hCS,'SystemTargetFile','ert.tlc');

            if slfeature('AutoMigrationIM')>0


                codertarget.target.copyInactiveCodeMappingsIfNeeded(hCS.getModel)
            end

        end
        codertarget.updateExtension(hCS,'UseCoderTarget');
    end
    if hCS.isValidParam('CoderTargetData')
        codertarget.data.setData(hCS,[]);
    end









    cachedCS=hCS.getConfigSetCache;
    if~isempty(cachedCS)&&cachedCS.isValidParam('CoderTargetData')&&...
        codertarget.data.isValidParameter(cachedCS,'TargetHardware')
        oldHW=codertarget.data.getParameterValue(cachedCS,'TargetHardware');
        doReset=~isequal(oldHW,hardwareName);
    else
        doReset=true;
    end

    try
        codertarget.target.useCoderTarget(hCS,true,hardwareName,doReset);
        codertarget.data.setVersion(hCS);
        loc_setUseCoderProductsDefaults(hCS);
        loc_setSoCProductsDefaults(hCS);
        targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
        if~isempty(targetInfo)&&~isempty(targetInfo.getOnHardwareSelectHook)
            feval(targetInfo.getOnHardwareSelectHook,hCS);
        end
    catch e
        error(message('codertarget:build:HardwareSelectError',hardwareName,hardwareName));
    end
end



function loc_setUseCoderProductsDefaults(hCS)
    targetName=codertarget.target.getTargetName(hCS);
    targetType=codertarget.target.getTargetType(targetName);
    licState={'off','on'};
    isSLC=dig.isProductInstalled('Simulink Coder');
    isEC=dig.isProductInstalled('Embedded Coder');
    switch(targetType)
    case 0
        set_param(hCS,'UseSimulinkCoderFeatures','on');
        set_param(hCS,'UseEmbeddedCoderFeatures','on');
    case 1
        set_param(hCS,'UseSimulinkCoderFeatures',licState{isSLC+1});
        set_param(hCS,'UseEmbeddedCoderFeatures',licState{isEC+1});
    case 2
        set_param(hCS,'UseSimulinkCoderFeatures','on');
        set_param(hCS,'UseEmbeddedCoderFeatures',licState{isEC+1});
    end
end



function loc_setSoCProductsDefaults(hCS)
    if codertarget.utils.isMdlConfiguredForSoC(hCS)


        set_param(hCS,'CodeExecutionProfiling','off');
    end
end


