




function analyzeDeps(rManager)

    rManager.getOptions().VerboseInfoObj.updateTimerMessage();



    rManager.getOptions().VerboseInfoObj.updateProgressBarMessage(...
    'Simulink:Variants:ReducerStatusMsgDepsAnalysis');


    getAllDeps(rManager);
end

function saveSLDDAttachedToBD(bdName)
    ddName=get_param(bdName,'DataDictionary');
    if isempty(ddName)
        return;
    end
    ddObj=Simulink.data.dictionary.open(ddName);
    ddObj.saveChanges();
    ddObj.close();
    disp(['Saved SLDD:',ddName]);
end


function getAllDeps(rManager)

    for modelIdx=numel(rManager.ModelRefModelInfoStructsVec):-1:1
        modelInfoStruct=rManager.ModelRefModelInfoStructsVec(modelIdx);







        modelName=modelInfoStruct.Name;
        modelObj=get_param(modelName,'Object');
        try
            modelObj.refreshModelBlocks;
            i_saveSystem(modelName,modelInfoStruct.FullPath,'SaveDirtyReferencedModels',true);







            saveSLDDAttachedToBD(modelName);
        catch ex %#ok<NASGU> % visited as part of MLINT cleanup
        end
    end












    function blks=getActiveBlocksPerModel(x)
        blks=x.BlksSVCEMap.keys;
        blks=blks(logical(Simulink.variant.utils.i_cell2mat(x.BlksSVCEMap.values)));
    end
    allBlocksInAllModels=arrayfun(@(x)getActiveBlocksPerModel(x),rManager.ModelRefModelInfoStructsVec,'UniformOutput',false);
    allBlocksInAllModels=[allBlocksInAllModels{:}];
    fromFileBlocksInModel=allBlocksInAllModels(strcmp('FromFile',get_param(allBlocksInAllModels,'BlockType')));
    matFilesInFromFileBlocks={};
    if~isempty(fromFileBlocksInModel)
        matFilesInFromFileBlocks=get_param(...
        fromFileBlocksInModel,'FileName');
        matFilesInFromFileBlocks=i_mat2cell(matFilesInFromFileBlocks);
        matFilesInFromFileBlocks=cellfun(@(x)Simulink.loadsave.resolveFile(x,'.mat'),matFilesInFromFileBlocks,'UniformOutput',false);
        matFilesInFromFileBlocks=setdiff(matFilesInFromFileBlocks,'');




        matFilesInFromFileBlocks=matFilesInFromFileBlocks(:)';
    end





    topModelIdx=1;

    modelName=rManager.ProcessedModelInfoStructsVec(topModelIdx).Name;
    origModelName=rManager.ProcessedModelInfoStructsVec(topModelIdx).OrigName;
    modelNameWithFullPath=rManager.ProcessedModelInfoStructsVec(topModelIdx).FullPath;

    try
        varDepsVecForConfig=getVariableDepsOfModel(rManager,modelName,origModelName);
        if~isempty(varDepsVecForConfig)
            rManager.ProcessedModelInfoStructsVec(topModelIdx).Variables={varDepsVecForConfig.Name};
        end

        rManager.ProcessedModelInfoStructsVec(topModelIdx).FileDependencies=getFileDepsOfModel(...
        rManager,modelName,modelNameWithFullPath,origModelName,matFilesInFromFileBlocks);
    catch err
        warnid='Simulink:Variants:CannotFindModelDeps';
        warnmsg=message(warnid,origModelName);
        warnObj=MException(warnmsg);
        warnObj=warnObj.addCause(err);
        rManager.Warnings{end+1}=warnObj;
    end
end








function variableDepsVec=getVariableDepsOfModel(rManager,modelName,origModelName)
    variableDepsVec=[];
    try
        variableDepsVec=Simulink.findVars(modelName,'SearchReferencedModels','on');
        rManager.IsVariableDependencyAnalysisSuccess=true;

    catch warnObj



        rManager.IsVariableDependencyAnalysisSuccess=false;
        warnid='Simulink:Variants:CannotFindVariables';
        warnmsg=message(warnid,origModelName);
        i_getAllExceptions(rManager,warnObj,warnmsg);
    end
end




function fileDepsStruct=getFileDepsOfModel(rManager,modelName,modelNameWithFullPath,origModelName,matFilesInFromFileBlocks)
    fileDepsStruct=Simulink.variant.reducer.types.VRedModelDependencies.empty;
    fullPathsOfDepsCell={};
    missingDepsCell={};

    try


        depsGraph=dependencies.internal.analyze(modelNameWithFullPath);

        fullPathsOfDepsCell=depsGraph.Nodes.Name(depsGraph.Nodes.Resolved);


        allOrigDataDictionariesFilePathList=rManager.DataDictionaryRenameManager.getAllDataDictionariesFilePathList();
        allOrigDataDictionariesMissingInDepAnalysisFilePathList=setdiff(allOrigDataDictionariesFilePathList,fullPathsOfDepsCell);
        allOrigDDFilesNotCopiedAndMissingInDepAnalysis={};

        for i=1:numel(allOrigDataDictionariesMissingInDepAnalysisFilePathList)
            dataDictionaryName=getDataDictionaryNameFromFile(allOrigDataDictionariesMissingInDepAnalysisFilePathList{i});
            if~rManager.DataDictionaryRenameManager.getIsRenamedDataDictionary(dataDictionaryName)
                allOrigDDFilesNotCopiedAndMissingInDepAnalysis=[allOrigDDFilesNotCopiedAndMissingInDepAnalysis;allOrigDataDictionariesMissingInDepAnalysisFilePathList{i}];%#ok<AGROW>
            end
        end



        fullPathsOfDepsCell=[fullPathsOfDepsCell;allOrigDDFilesNotCopiedAndMissingInDepAnalysis];
        missingDepsCell=depsGraph.Nodes.Name(~depsGraph.Nodes.Resolved);
    catch warnObj
        warnid='Simulink:Variants:CannotFindFileDeps';
        warnmsg=message(warnid,origModelName);
        i_getAllExceptions(rManager,warnObj,warnmsg);
    end



    if~isempty(missingDepsCell)


        missingDepsCell=i_mat2cell(missingDepsCell);
        missingDepsCSV=i_cellOfStringsToCSV(missingDepsCell);


        if~isempty(missingDepsCSV)
            warnid='Simulink:Variants:MissingFileDeps';
            warnmsg=message(warnid,modelName,missingDepsCSV);

            warnObj=MException(warnmsg);
            rManager.Warnings{end+1}=warnObj;


            for ii=1:numel(missingDepsCell)
                missingDep=missingDepsCell{ii};
                missingDepFilesCell=predecessors(depsGraph,missingDep);
                missingDepFileString='';


                for ij=1:numel(missingDepFilesCell)
                    filePath=missingDepFilesCell{ij};
                    missingDepFileString=sprintf(['%s',newline,'%s'],missingDepFileString,filePath);
                end

                warnid='Simulink:Variants:VariantReducerMissingDepFiles';
                warnmsg=message(warnid,missingDep,missingDepFileString);
                warnObj=MException(warnmsg);
                rManager.Warnings{end+1}=warnObj;
            end
        end
    end



    if isa(fullPathsOfDepsCell,'char')
        fullPathsOfDepsCell={fullPathsOfDepsCell};
    end


    fullPathsOfDepsCell=setdiff(fullPathsOfDepsCell,modelNameWithFullPath);


    ignorableDepExts={'.mdl','.mdlp','.slx','.slxp'};
    commonReducibleDepExtsCell={'.mat','.sldd'};
    selfReducibleDepExtsCell={'.req'};


    fromFileDepCount=numel(matFilesInFromFileBlocks);
    depFilesCount=numel(union(fullPathsOfDepsCell,matFilesInFromFileBlocks));
    nonFromFileDeps=setdiff(fullPathsOfDepsCell,matFilesInFromFileBlocks);

    for depIdx=depFilesCount:-1:1
        if depIdx>fromFileDepCount
            fileDepsStruct(depIdx).DependencyPath=nonFromFileDeps{depIdx-fromFileDepCount};
            [~,~,ext]=fileparts(fileDepsStruct(depIdx).DependencyPath);
            switch ext
            case ignorableDepExts
                fileDepsStruct(depIdx).DependencyType=Simulink.variant.reducer.enums.ModelDependencyType.IGNORABLE;
            case commonReducibleDepExtsCell
                fileDepsStruct(depIdx).DependencyType=Simulink.variant.reducer.enums.ModelDependencyType.COMMON_REDUCIBLE;
            case selfReducibleDepExtsCell
                fileDepsStruct(depIdx).DependencyType=Simulink.variant.reducer.enums.ModelDependencyType.SELF_REDUCIBLE;
            otherwise
                fileDepsStruct(depIdx).DependencyType=Simulink.variant.reducer.enums.ModelDependencyType.NON_REDUCIBLE;
            end
        else
            fileDepsStruct(depIdx).DependencyPath=matFilesInFromFileBlocks{depIdx};
            fileDepsStruct(depIdx).DependencyType=Simulink.variant.reducer.enums.ModelDependencyType.NON_REDUCIBLE;
        end
    end
end










function i_getAllExceptions(rManager,mexceptionObj,errmsg)











    try
        [excepIds,excepMsgs]=slprivate('getAllErrorIdsAndMsgs',mexceptionObj);
        for ii=1:numel(excepIds)
            rManager.Warnings{end+1}=MException(excepIds{ii},excepMsgs{ii});
        end
    catch
        mexceptionObj=MException(errmsg);
        rManager.Warnings{end+1}=mexceptionObj;
    end
end

function dataDictionaryName=getDataDictionaryNameFromFile(dataDictionaryFile)
    [~,name,ext]=fileparts(dataDictionaryFile);
    dataDictionaryName=[name,ext];
end



