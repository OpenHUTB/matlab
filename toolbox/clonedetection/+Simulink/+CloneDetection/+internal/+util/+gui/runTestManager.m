function resultSet=runTestManager(sysName)




    resultSet=[];
    resultSet.Data=[];
    resultSet.IsEquivalencyCheckPassed=false;
    resultSet.OriginalModel='';
    resultSet.UpdatedModel='';

    ui=get_param(sysName,'CloneDetectionUIObj');

    modelName1=get_param(ui.model,'name');
    resultSet.UpdatedModel=[modelName1,'.slx'];
    fileTimeStamp=ui.m2mObj.genmodelprefix(9:end);
    if~isempty(ui.libraryList)
        modelName2=slEnginePir.util.getBackupModelName(ui.m2mObj.genmodelprefix,modelName1);
        allblocks=ui.blockPathCategoryMap.keys;
        allblocks1=allblocks;
    elseif ui.enableClonesAnywhere
        allblocks=[];
        allblocks1=[];
        modelName2=slEnginePir.util.getBackupModelName(ui.m2mObj.genmodelprefix,modelName1);
    else
        modelName2=slEnginePir.util.getTemporaryModelName(ui.m2mObj.genmodelprefix,modelName1);

        blockPathCategoryMap1=containers.Map('KeyType','char','ValueType','double');

        for i=1:length(ui.m2mObj.exclusionList)
            blockPathCategoryMap1(ui.m2mObj.exclusionList{i})=1;
        end

        if isfield(ui.m2mObj.cloneresult,'exact')&&~isempty(ui.m2mObj.cloneresult.exact)
            cloneResultStruct=ui.m2mObj.cloneresult.exact;
            for i=1:length(cloneResultStruct)
                if~ui.m2mObj.enableClonesAnywhere
                    nodeChildrenArray=ui.m2mObj.cloneresult.Before{cloneResultStruct{i}.index};
                    for j=1:length(nodeChildrenArray)
                        blockPathCategoryMap1(nodeChildrenArray{j})=1;
                    end
                else
                    nodeChildrenArray=ui.m2mObj.cloneresult.Before(cloneResultStruct{i}.index);
                    for j=1:length(nodeChildrenArray.Region)
                        region1=nodeChildrenArray.Region(j);
                        for k=1:length(region1.Candidates)
                            blockPathCategoryMap1(region1.Candidates{k})=1;
                        end
                    end
                end
            end
        end

        if isfield(ui.m2mObj.cloneresult,'similar')&&~isempty(ui.m2mObj.cloneresult.similar)
            cloneResultStruct=ui.m2mObj.cloneresult.similar;
            for i=1:length(cloneResultStruct)
                if~ui.m2mObj.enableClonesAnywhere
                    nodeChildrenArray=ui.m2mObj.cloneresult.Before{cloneResultStruct{i}.index};
                    for j=1:length(nodeChildrenArray)
                        blockPathCategoryMap1(nodeChildrenArray{j})=1;
                    end
                else
                    nodeChildrenArray=ui.m2mObj.cloneresult.Before(cloneResultStruct{i}.index);
                    for j=1:length(nodeChildrenArray.Region)
                        region1=nodeChildrenArray.Region(j);
                        for k=1:length(region1.Candidates)
                            blockPathCategoryMap1(region1.Candidates{k})=1;
                        end
                    end
                end
            end
        end


        allblocks=ui.blockPathCategoryMap.keys;
        allblocks1=keys(blockPathCategoryMap1);
    end

    try
        [~,~]=Simulink.CloneDetection.internal.util.checkFileInAllPaths(...
        [ui.m2mObj.m2m_dir,modelName2]);
    catch
        DAStudio.error('sl_pir_cpp:creator:BackupModelNotFound',modelName2);
    end

    resultSet.OriginalModel=[ui.m2mObj.m2m_dir,modelName2,'.slx'];

    modelsToLoad={};
    modelsToLoad=[modelsToLoad,modelName1];
    modelsToLoad=[modelsToLoad,ui.m2mObj.refModels];
    backupModelsOrgToLoad=slEnginePir.util.getBackupModelName(ui.m2mObj.genmodelprefix,modelsToLoad);
    backupModelsOrgToLoad=strcat(ui.m2mObj.m2m_dir,backupModelsOrgToLoad);

    temporaryModelsToLoad=slEnginePir.util.getTemporaryModelName(ui.m2mObj.genmodelprefix,modelsToLoad);
    temporaryModelsToLoad=strcat(ui.m2mObj.m2m_dir,temporaryModelsToLoad);

    loadedModels={};

    for modelIndex=1:length(modelsToLoad)
        if(exist([modelsToLoad{modelIndex},'.mdl'],'file')>0||...
            exist([modelsToLoad{modelIndex},'.slx'],'file')>0)&&...
            slEnginePir.util.loadBlockDiagramIfNotLoaded(modelsToLoad{modelIndex})
            [~,modelNameWithoutExtension,~]=fileparts(modelsToLoad{modelIndex});
            loadedModels=[loadedModels;modelNameWithoutExtension];
        end

        if(exist([backupModelsOrgToLoad{modelIndex},'.mdl'],'file')>0||...
            exist([backupModelsOrgToLoad{modelIndex},'.slx'],'file')>0)&&...
            slEnginePir.util.loadBlockDiagramIfNotLoaded(backupModelsOrgToLoad{modelIndex})
            [~,modelNameWithoutExtension,~]=fileparts(backupModelsOrgToLoad{modelIndex});
            loadedModels=[loadedModels;modelNameWithoutExtension];
        end

        if(exist([temporaryModelsToLoad{modelIndex},'.mdl'],'file')>0||...
            exist([temporaryModelsToLoad{modelIndex},'.slx'],'file')>0)&&...
            slEnginePir.util.loadBlockDiagramIfNotLoaded(temporaryModelsToLoad{modelIndex})
            [~,modelNameWithoutExtension,~]=fileparts(temporaryModelsToLoad{modelIndex});
            loadedModels=[loadedModels;modelNameWithoutExtension];
        end
    end

    if length(allblocks)~=length(allblocks1)
        warning(message('sl_pir_cpp:creator:InvalidCheckEquivalencyFormat'));
        return;
    end

    dataLoggingForRefactored=containers.Map('KeyType','char','ValueType','any');
    dataLoggingForBackup=containers.Map('KeyType','char','ValueType','any');
    for i=1:length(allblocks)

        blockpath=allblocks{i};
        blockpath1=allblocks1{i};


        if strcmp(get_param(blockpath1,'Type'),'block_diagram')
            reflen=length(ui.m2mObj.refBlocksModels);
            for m=1:reflen
                refmodel=ui.m2mObj.refBlocksModels(m).refmdl;
                if strcmp(refmodel{:},blockpath)
                    blockpath1=ui.m2mObj.refBlocksModels(m).block;
                end
            end
        end

        ph=get_param(blockpath1,'PortHandles');

        lib_flag=0;
        for l=1:length(blockpath1)
            if(strcmp(blockpath1(l),'/'))
                break;
            end
        end
        temp=blockpath1(1:l-1);

        if strcmp(temp,ui.m2mObj.libname)||~isempty(ui.libraryList)
            lib_flag=1;
        end

        if~lib_flag
            validBlockPath=slEnginePir.util.getTemporaryValidBlockPath(ui.m2mObj.genmodelprefix,...
            blockpath);
        else
            validBlockPath=slEnginePir.util.getValidBlockPath(ui.m2mObj.genmodelprefix,blockpath);
        end
        if~strcmp(get_param(validBlockPath,'type'),'block_diagram')
            ph_backup=get_param(validBlockPath,'PortHandles');
            dataLoggingForRefactored(blockpath1)=get_param(ph.Outport,'DataLogging');
            dataLoggingForBackup(blockpath)=get_param(ph_backup.Outport,'DataLogging');
            arrayfun(@(handle)set_param(handle,'DataLogging','on'),ph.Outport);
            arrayfun(@(handle)set_param(handle,'DataLogging','on'),ph_backup.Outport);
        end

    end


    testFile=sltest.testmanager.TestFile([modelName1,'clonedetectionTestFile']);

    testSuites=testFile.getTestSuites;
    testCases=testSuites.getTestCases;


    testFile.convertTestType(sltest.testmanager.TestCaseTypes.Equivalence)


    testCases.setProperty('model',modelName1,'SimulationIndex',1);
    testCases.setProperty('model',modelName2,'SimulationIndex',2);


    resultSet.Data=run(testCases);
    resultSet.IsEquivalencyCheckPassed=strcmp(resultSet.Data.Outcome,'Passed');

    for i=1:length(allblocks)

        blockpath=allblocks{i};
        blockpath1=allblocks1{i};


        if strcmp(get_param(blockpath1,'Type'),'block_diagram')
            reflen=length(ui.m2mObj.refBlocksModels);
            for m=1:reflen
                refmodel=ui.m2mObj.refBlocksModels(m).refmdl;
                if strcmp(refmodel{:},blockpath)
                    blockpath1=ui.m2mObj.refBlocksModels(m).block;
                end
            end
        end

        ph=get_param(blockpath1,'PortHandles');

        lib_flag=0;
        for l=1:length(blockpath1)
            if(strcmp(blockpath1(l),'/'))
                break;
            end
        end
        temp=blockpath1(1:l-1);

        if strcmp(temp,ui.m2mObj.libname)||~isempty(ui.libraryList)
            lib_flag=1;
        end

        if~lib_flag
            validBlockPath=slEnginePir.util.getTemporaryValidBlockPath(ui.m2mObj.genmodelprefix,...
            blockpath);
        else
            validBlockPath=slEnginePir.util.getValidBlockPath(ui.m2mObj.genmodelprefix,blockpath);
        end
        if~strcmp(get_param(validBlockPath,'type'),'block_diagram')
            ph_backup=get_param(validBlockPath,'PortHandles');
            dataLogRefactor=dataLoggingForRefactored(blockpath1);
            dataLogBackup=dataLoggingForBackup(blockpath);
            if length(ph.Outport)==1
                arrayfun(@(handle)set_param(handle,'DataLogging',dataLogRefactor),ph.Outport);
                arrayfun(@(handle)set_param(handle,'DataLogging',dataLogBackup),ph_backup.Outport);
            else
                for j=1:length(ph.Outport)
                    arrayfun(@(handle)set_param(handle,'DataLogging',dataLogRefactor{j}),ph.Outport(j));
                    arrayfun(@(handle)set_param(handle,'DataLogging',dataLogBackup{j}),ph_backup.Outport(j));
                end
            end
        end
    end
    slEnginePir.util.closeBlockDiagramsInList(loadedModels);
end


