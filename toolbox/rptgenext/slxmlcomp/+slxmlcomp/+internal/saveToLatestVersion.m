function newModelFile=saveToLatestVersion(modelPath,targetDir,avoidNames,renameModel)











    p=inputParser;
    p.addRequired('avoidNames',@iscell);
    p.parse(avoidNames);

    [~,modelName,extension]=fileparts(modelPath);
    if~isempty(extension)&&extension(1)=='.'
        extension(1)=[];
    end
    newModelFile=modelPath;



    if renameModel
        newName=i_GenerateSafeExportName(modelName,avoidNames);
    else

        newName=modelName;
    end

    bWasLoaded=bdIsLoaded(newName);
    if bWasLoaded

        loadedName=get_param(modelName,'FileName');
        if~xmlcomp.internal.compareFilenames(loadedName,modelPath)



            slxmlcomp.internal.error('xmlexport:ShadowedModel',modelName,loadedName,modelName);
        end
    end

    isUsableFormat=i_IsModelCurrentOPC(modelPath);

    if isUsableFormat&&~renameModel
        import slxmlcomp.internal.areLibReferencesCurrent;
        if areLibReferencesCurrent(modelPath)
            if extension=="slx"

                return
            else
                assert(strcmp(extension,'mdl'),'Unexpected file extension');

                newModelFile=fullfile(targetDir,[newName,'.slx']);
                r=Simulink.loadsave.SLXPackageReader(modelPath);
                w=Simulink.loadsave.SLXPackageWriter(newModelFile,r);
                w.close
                return;
            end
        end
    end

    if~bWasLoaded

        Simulink.internal.newSystemFromFile(newName,modelPath,ExecuteCallbacks=false);
    end
    newModelFile=fullfile(targetDir,[newName,'.slx']);




    find_system(newName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','off','LookUnderMasks','all');
    slxmlcomp.internal.testharness.forceInternalTestHarnessesToResave(newName);

    if renameModel
        try

            if exist(newModelFile,'file')
                fileattrib(newModelFile,'+w');
            end

            slInternal('snapshot_slx',newName,newModelFile);
            fileattrib(newModelFile,'-w');

            i_Cleanup(newName,false);

            if(bWasLoaded)
                Simulink.internal.newSystemFromFile(newName,modelPath,ExecuteCallbacks=false);


            end
        catch E
            i_Cleanup(newName,bWasLoaded)
            slxmlcomp.internal.error('xmlexport:ExportToXMLFailed',modelName,E.message);
        end
    else
        try
            slInternal('snapshot_slx',modelName,newModelFile);
        catch E
            i_Cleanup(modelName,bWasLoaded)
            slxmlcomp.internal.error('xmlexport:ExportToXMLFailed',modelName,E.message);
        end
    end


    i_Cleanup(modelName,bWasLoaded||renameModel)
end


function newName=i_GenerateSafeExportName(originalName,otherNames)







    counter=1;
    newName=i_GetTempName(originalName,counter);


    while ismember(lower(newName),lower(otherNames))||bdIsLoaded(newName)||~isempty(which(newName))
        counter=counter+1;
        if counter>95


            newName=sprintf('%s%s',newName,datestr(now,30));
        else
            newName=i_GetTempName(originalName,counter);
        end



        assert(counter<100,'Took too many tries to find a safe name');
    end

end


function i_Cleanup(modelName,bWasLoaded)

    if~bWasLoaded


        close_system(modelName,0,'SkipCloseFcn',true);
    end
end


function newName=i_GetTempName(originalName,counter)
    suffix=['_TEMPORARY_COPY_',int2str(counter)];
    maxNameLength=namelengthmax-length(suffix);
    truncatedName=originalName(1:min(length(originalName),maxNameLength));
    newName=[truncatedName,suffix];
end




function isCurrentVersion=i_IsModelCurrentOPC(modelPath)
    mdlInfo=Simulink.MDLInfo(modelPath);
    simulinkInfo=ver('Simulink');
    isCurrentVersion=strcmp(mdlInfo.SimulinkVersion,simulinkInfo.Version);
    if isCurrentVersion

        isCurrentVersion=(Simulink.loadsave.identifyFileFormat(modelPath)~="mdl");
    end
end

