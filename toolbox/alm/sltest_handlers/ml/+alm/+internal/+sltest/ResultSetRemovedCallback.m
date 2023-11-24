function ResultSetRemovedCallback(~,resultSetRemovedEventData)

    try
        if~dig.isProductInstalled('Simulink Check')
            return;
        end
        project=matlab.project.currentProject();
        if isempty(project)
            return;
        end
        databaseFullFilePath=alm.internal.ArtifactService.getDatabaseLocation(project.RootFolder);
        if~isfile(databaseFullFilePath)
            return;
        end

        resultSetUuids=resultSetRemovedEventData.UUID;

        artifactService=alm.internal.ArtifactService.get(project.RootFolder);

        if artifactService.getIsUpdatingArtifacts()
            return;
        end

        [databaseFilePath,~]=fileparts(databaseFullFilePath);

        needsUpdateArtifacts=false;

        filesToUpdate=cell(0,1);
        for i=1:numel(resultSetUuids)
            resultSetUuid=char(resultSetUuids(i));
            sessionFullFilePath=fullfile(databaseFilePath,'sltest',...
            [resultSetUuid,'.sltsrf']);

            filesToUpdate{end+1,1}=sessionFullFilePath;%#ok<AGROW>


            if isfile(sessionFullFilePath)
                needsUpdateArtifacts=true;
                delete(sessionFullFilePath);
            end
        end

        if needsUpdateArtifacts
            assert(~artifactService.getIsUpdatingArtifacts(),...
            "Should not call back into update artifacts!");
            artifactService.updateArtifacts(filesToUpdate);
        end

    catch ME
        warning(message('alm:handler_services:CallbackError',...
        'ResultSetRemoved',ME.identifier));
    end

end

