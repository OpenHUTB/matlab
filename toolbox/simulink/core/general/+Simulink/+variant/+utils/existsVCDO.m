function[varExists,varIsVarConfigDataObject,section]=existsVCDO(modelName,varName)









    varExists=false;
    varIsVarConfigDataObject=false;
    section='';
    if~isvarname(varName)
        return
    end

    warnStateDC=warning('off','Simulink:VariantManager:DefaultConfigurationRemoved');
    warnStateSMC=warning('off','Simulink:VariantManager:SubModelConfigsRemoved');
    warnStateDCCleanup=onCleanup(@()warning(warnStateDC));
    warnStateSMCCleanup=onCleanup(@()warning(warnStateSMC));

    if isvarname(varName)
        classOfVar='';
        ddSpec=get_param(modelName,'DataDictionary');
        hasAccessToBaseWks=strcmp(get_param(modelName,'HasAccessToBaseWorkspace'),'on');
        if~isempty(ddSpec)
            ddConn=Simulink.dd.open(ddSpec);

            section='Configurations';
            inConfigurationsSectionDD=ddConn.entryExists(['Configurations','.',varName],true);
            inGlobalSectionDD=ddConn.entryExists(['Global','.',varName],true);
            inDD=inConfigurationsSectionDD||inGlobalSectionDD;
            if hasAccessToBaseWks&&~inDD
                varExists=evalin('base',['exist(''',varName,''', ''var'');']);
            elseif inConfigurationsSectionDD
                varExists=true;
            else
                section='Global';
                if inGlobalSectionDD
                    varExists=true;
                end
            end
            if varExists

                if~inDD&&hasAccessToBaseWks
                    classOfVar=evalin('base',['class(',varName,');']);
                else
                    classOfVar=Simulink.variant.utils.evalExpressionInSection(...
                    modelName,['class(',varName,');'],section);
                end
            end
        else

            varExists=evalin('base',['exist(''',varName,''', ''var'');']);
            if varExists

                classOfVar=evalin('base',['class(',varName,');']);
            end
        end
        if~isempty(classOfVar)&&...
            strcmp(classOfVar,'Simulink.VariantConfigurationData')
            varIsVarConfigDataObject=true;
        end
    end
end
