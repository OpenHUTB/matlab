function resultSet=runTestManager(sysName)




    ui=get_param(sysName,'CloneDetectionUIObj');

    modelName1=get_param(ui.model,'name');
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

        if~isempty(ui.m2mObj.cloneresult.exact)
            cloneResultStruct=ui.m2mObj.cloneresult.exact;
            for i=1:length(cloneResultStruct)
                nodeChildrenArray=ui.m2mObj.cloneresult.Before{cloneResultStruct{i}.index};
                for j=1:length(nodeChildrenArray)
                    blockPathCategoryMap1(nodeChildrenArray{j})=1;
                end
            end
        end

        if~isempty(ui.m2mObj.cloneresult.similar)
            cloneResultStruct=ui.m2mObj.cloneresult.similar;
            for i=1:length(cloneResultStruct)
                nodeChildrenArray=ui.m2mObj.cloneresult.Before{cloneResultStruct{i}.index};
                for j=1:length(nodeChildrenArray)
                    blockPathCategoryMap1(nodeChildrenArray{j})=1;
                end
            end
        end


        allblocks=ui.blockPathCategoryMap.keys;
        allblocks1=keys(blockPathCategoryMap1);
    end

    if length(allblocks)~=length(allblocks1)
        warning(message('sl_pir_cpp:creator:InvalidCheckEquivalencyFormat'));
        resultSet=[];
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
            blockpath1);
        else
            validBlockPath=slEnginePir.util.getValidBlockPath(ui.m2mObj.genmodelprefix,blockpath1);
        end
        ph_backup=get_param(validBlockPath,'PortHandles');

        dataLoggingForRefactored(blockpath1)=get_param(ph.Outport,'DataLogging');
        dataLoggingForBackup(blockpath)=get_param(ph_backup.Outport,'DataLogging');
        arrayfun(@(handle)set_param(handle,'DataLogging','on'),ph.Outport);
        arrayfun(@(handle)set_param(handle,'DataLogging','on'),ph_backup.Outport);
    end


    testFile=sltest.testmanager.TestFile([modelName1,'clonedetectionTestFile']);

    testSuites=testFile.getTestSuites;
    testCases=testSuites.getTestCases;


    testFile.convertTestType(sltest.testmanager.TestCaseTypes.Equivalence)


    testCases.setProperty('model',modelName1,'SimulationIndex',1);
    testCases.setProperty('model',modelName2,'SimulationIndex',2);


    resultSet=run(testCases);


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
            blockpath1);
        else
            validBlockPath=slEnginePir.util.getValidBlockPath(ui.m2mObj.genmodelprefix,blockpath1);
        end
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


