function[modelDirectory,modelName,cloneDetectionSettings,loadedModels,selectedBoundary]=...
    validateInputToFindClones(numArguments,modelNameFullPath,cloneDetectionSettings)




    loadedModels={};
    modelName='';
    selectedBoundary='';
    defaultSettings=Simulink.CloneDetection.Settings();
    modelDirectory=pwd;

    if numArguments>=2
        if isempty(cloneDetectionSettings)||...
            ~isa(cloneDetectionSettings,'Simulink.CloneDetection.Settings')
            DAStudio.error('sl_pir_cpp:creator:InvalidCloneDetectionSettingsObject');
        end
    end

    if numArguments<1
        cloneDetectionSettings=defaultSettings;


        cloneDetectionSettings.Folders={pwd};
    else

        if isa(modelNameFullPath,'Simulink.CloneDetection.Settings')

            cloneDetectionSettings=modelNameFullPath;


            if isempty(cloneDetectionSettings.Folders)
                DAStudio.error('sl_pir_cpp:creator:EmptyModelNameAndSettings');
            end
        else

            try
                [firstPartOfPath,secondPartOfPath,~]=fileparts(modelNameFullPath);

                if isfolder(firstPartOfPath)

                    modelDirectory=firstPartOfPath;
                    modelName=secondPartOfPath;
                    selectedBoundary=modelName;
                else


                    selectedBoundary=strsplit(modelNameFullPath,'.');
                    selectedBoundary=selectedBoundary{1};
                    selectedBoundaryPathArray=strsplit(modelNameFullPath,'/');
                    modelNameFullPath=selectedBoundaryPathArray{1};
                    [~,modelName,~]=fileparts(modelNameFullPath);
                end
            catch
                DAStudio.error('Simulink:utility:InvalidBlockDiagramName');
            end

            if isempty(modelName)
                DAStudio.error('sl_pir_cpp:creator:ModelNameIsEmpty');
            end

            if slEnginePir.util.loadBlockDiagramIfNotLoaded(modelNameFullPath)
                loadedModels=[loadedModels;{modelName}];
            end

            if numArguments<2
                cloneDetectionSettings=defaultSettings;
            end

            if~isempty(cloneDetectionSettings.Folders)
                DAStudio.warning('sl_pir_cpp:creator:SettingsConflictFoldersAndSingleModel',modelName);
            end
        end
    end
end

