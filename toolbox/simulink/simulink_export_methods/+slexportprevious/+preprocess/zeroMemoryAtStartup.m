function zeroMemoryAtStartup(obj)




    if isReleaseOrEarlier(obj.ver,'R2019b')
        if slfeature('DisableZeroInitForCppEncap')==0
            return;
        end

        sets=getConfigSets(obj.modelName);

        for i=1:length(sets)
            CS=getConfigSet(obj.modelName,sets{i});

            if isa(CS,'Simulink.ConfigSetRef')
                if strcmp(CS.SourceResolved,'off')
                    return;
                end
            end

            if strcmp(get_param(CS,'CodeInterfacePackaging'),'C++ class')


                obj.appendRule('<ZeroInternalMemoryAtStartup:repval on>');


                cppObj=RTW.getEncapsulationInterfaceSpecification(obj.modelName);
                if~isempty(cppObj)&&~isa(cppObj,'RTW.ModelCPPArgsClass')
                    obj.appendRule('<ZeroExternalMemoryAtStartup:repval on>');
                end
            end
        end

    end

end
