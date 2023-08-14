function savedFilterFilePath=makeFilterFromRedObjectivesInSldvData(modelName,sldvData,filterFilePath)




    if~isSLDVInstalledAndLicensed
        error(message('Sldv:Filter:SimulinkDesignVerifierNotLicensed'));
    end
    if builtin('_license_checkout','Simulink_Design_Verifier','quiet')~=0
        error(message('Sldv:Filter:SimulinkDesignVerifierNotLicensed'));
    end

    filter=Sldv.Filter.getInstance(modelName,filterFilePath);

    if~strcmp(sldvData.AnalysisInformation.Options.Mode,'PropertyProving')
        for idx=1:length(sldvData.Objectives)
            objective=sldvData.Objectives(idx);

            if~(Sldv.utils.isTestGenObjectiveForFiltering(objective)||...
                Sldv.utils.isErrorDetectionObjective(objective))


                continue;
            end

            if any(strcmp(objective.status,{'Unsatisfiable',...
                'Dead Logic',...
                'Falsified',...
                'Falsified - No Counterexample',...
                'Falsified - needs simulation'}))
                processObjectiveForFilter(filter,sldvData,idx,1);
            end
        end
    end

    filter.save(filterFilePath);
    delete(filter);

    savedFilterFilePath=filterFilePath;

    [path,~,~]=fileparts(filterFilePath);
    if~isempty(path)
        return;
    end

    filterFilePath=which(filterFilePath);
    if isempty(filterFilePath)
        return;
    end

    savedFilterFilePath=filterFilePath;
end
