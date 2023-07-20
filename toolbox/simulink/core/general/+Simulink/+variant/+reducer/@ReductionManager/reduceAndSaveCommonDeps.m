









function reduceAndSaveCommonDeps(rManager)

    modelInfoStructsVec=rManager.ProcessedModelInfoStructsVec;
    absOutDirPath=rManager.getOptions().AbsOutDirPath;
    commonReducibleDepExts={'.mat','.sldd'};


    depToModelNamesMap=containers.Map;
    modelNameToInfoStructMap=containers.Map;



    reducedDataDDtoVarsMap=containers.Map;

    vcdoNames={};

    numModels=length(modelInfoStructsVec);
    for modelIdx=1:numModels
        modelInfoStruct=modelInfoStructsVec(modelIdx);

        if modelInfoStruct.IsProtected
            continue;
        end

        if~isempty(modelInfoStruct.VCDOInfo)&&~isempty(modelInfoStruct.VCDOInfo.VCDOName)
            vcdoNames=[vcdoNames,modelInfoStruct.VCDOInfo.VCDOName];%#ok<AGROW> 
        end

        fullModelPath=modelInfoStruct.FullPath;
        modelNameToInfoStructMap(fullModelPath)=modelInfoStruct;

        modelDepsStruct=modelInfoStruct.FileDependencies;
        for depIdx=1:numel(modelDepsStruct)

            if modelDepsStruct(depIdx).DependencyType~=Simulink.variant.reducer.enums.ModelDependencyType.COMMON_REDUCIBLE
                continue;
            end

            depPath=modelDepsStruct(depIdx).DependencyPath;
            [~,depName,ext]=fileparts(depPath);
            if isempty(Simulink.variant.reducer.utils.searchNameInCell(ext,commonReducibleDepExts))
                continue;
            end

            if isKey(depToModelNamesMap,depPath)
                depModelInfoStructsVec=depToModelNamesMap(depPath);
                depModelInfoStructsVec(end+1)=modelInfoStruct;%#ok<AGROW> % visited as part of MLINT cleanup
                depToModelNamesMap(depPath)=depModelInfoStructsVec;
            else
                depToModelNamesMap(depPath)=modelInfoStruct;
            end


            isToBeCopiedDependency=~(strcmp(ext,'.sldd')&&rManager.DataDictionaryRenameManager.getIsRenamedReducedDataDictionary([depName,ext]));

            if isToBeCopiedDependency
                depSavePath=[absOutDirPath,filesep,depName,ext];
                if strcmp(depSavePath,depPath)
                    warnid='Simulink:Variants:DepCannotBeOverwritten';
                    warnmsg=message(warnid,depPath);
                    warnObj=MException(warnmsg);
                    rManager.Warnings{end+1}=warnObj;
                end
            end
        end
    end


    sectionsMap=Simulink.variant.reducer.utils.getSLDDSectionsToPrune();


    uniqueDepsCell=keys(depToModelNamesMap);
    numDeps=length(uniqueDepsCell);
    for depIdx=1:numDeps
        uniqueDepPath=uniqueDepsCell{depIdx};
        [~,depName,ext]=fileparts(uniqueDepPath);

        depSavePath=[absOutDirPath,filesep,depName,ext];


        depModelInfoStructsVec=depToModelNamesMap(uniqueDepPath);
        namesOfVarsUsedInModelsCell={depModelInfoStructsVec.Variables};
        namesOfVarsUsedInModelsCell=unique([namesOfVarsUsedInModelsCell{:}]);
        if isempty(namesOfVarsUsedInModelsCell)


            namesOfVarsUsedInModelsCell={};
        end


        varNamesInDep=struct();
        if strcmp(ext,'.mat')
            varsStruct=load(uniqueDepPath);
            if~isempty(varsStruct)
                varNamesInDep.("MAT")=fields(varsStruct);
            end
        elseif strcmp(ext,'.sldd')
            try
                slddConn=Simulink.dd.open(uniqueDepPath);
                sections=sectionsMap.keys;
                for secIdx=1:numel(sections)
                    varsVec=slddConn.evalin('whos',sections{secIdx});
                    if~isempty(varsVec)
                        varNamesInDep.(sections{secIdx})={varsVec.name};
                    end
                end
                slddConn.close();
            catch ex
                warnid='Simulink:Variants:ErrAccessingDD';
                warnmsg=message(warnid,uniqueDepPath);
                warnObj=MException(warnmsg);
                rManager.Warnings{end+1}=warnObj;
                rManager.Warnings{end+1}=ex;
                try
                    slddConn.close();
                catch
                end
            end
        end


        if~isempty(vcdoNames)


            namesOfVarsUsedInModelsCell=setdiff(namesOfVarsUsedInModelsCell,vcdoNames);
        end



        varNamesTobeSaved=structfun(@(x)intersect(x,namesOfVarsUsedInModelsCell),varNamesInDep,'UniformOutput',false);


        if strcmp(ext,'.mat')
            try
                if rManager.IsVariableDependencyAnalysisSuccess
                    if~isempty(varNamesTobeSaved.("MAT"))
                        save(depSavePath,'-struct','varsStruct',varNamesTobeSaved.("MAT"){:});
                    else
                        varsStruct=struct();
                        save(depSavePath,'-struct','varsStruct');
                    end
                else




                    copyfile(uniqueDepPath,depSavePath);
                    fileattrib(depSavePath,'+w');
                end
            catch ex %#ok<NASGU>
                warnid='Simulink:Variants:MatDepCannotBeSaved';
                warnmsg=message(warnid,uniqueDepPath,depSavePath);
                warnObj=MException(warnmsg);
                rManager.Warnings{end+1}=warnObj;
            end
        elseif strcmp(ext,'.sldd')
            dataDictionaryNameOrig=[depName,ext];




            if~rManager.DataDictionaryRenameManager.getIsRenamedDataDictionary(dataDictionaryNameOrig)&&~rManager.DataDictionaryRenameManager.getIsRenamedReducedDataDictionary(dataDictionaryNameOrig)
                try
                    [err,depSavePath]=rManager.DataDictionaryRenameManager.renameReducedDataDictionarySemantically(dataDictionaryNameOrig,uniqueDepPath,absOutDirPath,modelInfoStruct.OrigName,[]);
                    Simulink.variant.reducer.utils.assert(isempty(err),'None of the data dictionaries at this stage should have been dirty');
                catch ex %#ok<NASGU>
                    warnid='Simulink:Variants:DDDepCannotBeSaved';
                    warnmsg=message(warnid,uniqueDepPath,depSavePath);
                    warnObj=MException(warnmsg);
                    rManager.Warnings{end+1}=warnObj;
                end
            end
            varsTobeDeleted=[];
            varNameFields=fieldnames(varNamesInDep);
            for fieldIdx=1:numel(varNameFields)
                field=varNameFields{fieldIdx};
                varsTobeDeleted.(field)=setdiff(varNamesInDep.(field),varNamesTobeSaved.(field));
            end


            if~isempty(varsTobeDeleted)
                reducedDataDDtoVarsMap(depSavePath)=varsTobeDeleted;
            end
        end


        rManager.ReportDataObj.addDependentFile(depSavePath);
    end










    reduceDataDictionary(rManager,reducedDataDDtoVarsMap);


    reducedRenamedDataDictionaries=rManager.DataDictionaryRenameManager.getAllReducedRenamedDataDictionaries();
    openDataDictionaryFiles=Simulink.variant.utils.getOpenAndDirtyDataDictionaryFiles();
    openDataDictionaryNames=cellfun(@(X)(getDataDictionaryNameFromFile(X)),openDataDictionaryFiles,'UniformOutput',false);
    reducedRenamedDataDictionaries=intersect(reducedRenamedDataDictionaries,openDataDictionaryNames);

    for i=1:numel(reducedRenamedDataDictionaries)
        Simulink.data.dictionary.closeAll(reducedRenamedDataDictionaries{i},'-save');
    end

    function dataDictionaryName=getDataDictionaryNameFromFile(dataDictionaryFile)
        [~,name,ext]=fileparts(dataDictionaryFile);
        dataDictionaryName=[name,ext];
    end


end



function reduceDataDictionary(rManager,reducedDataDDtoVarsMap)


    sectionsMap=Simulink.variant.reducer.utils.getSLDDSectionsToPrune();


    datadicts=reducedDataDDtoVarsMap.keys';
    for ddId=1:reducedDataDDtoVarsMap.Count
        depSavePath=datadicts{ddId};
        try

            makeFileWriteableStatus=fileattrib(depSavePath,'+w');
            if makeFileWriteableStatus

                slddConn=Simulink.dd.open(depSavePath);
                if rManager.IsVariableDependencyAnalysisSuccess

                    varsTobeDeleted=reducedDataDDtoVarsMap(depSavePath);
                    fields=fieldnames(varsTobeDeleted);
                    for fIdx=1:numel(fields)
                        field=fields{fIdx};
                        fVars=varsTobeDeleted.(field);
                        numTobeDeleted=length(fVars);
                        for varIdx=1:numTobeDeleted
                            checkWeakReferenceToBW=false;
                            if slddConn.entryExists([sectionsMap(field),'.',fVars{varIdx}],checkWeakReferenceToBW)

                                slddConn.deleteEntry([sectionsMap(field),'.',fVars{varIdx}]);
                            end
                        end
                    end
                end
                slddConn.saveChanges();
                slddConn.close();
            else
                warnid='Simulink:Variants:DDDepNotModifiable';
                warnmsg=message(warnid,depSavePath);
                warnObj=MException(warnmsg);
                rManager.Warnings{end+1}=warnObj;
            end
        catch ex %#ok<NASGU>
            warnid='Simulink:Variants:CannotReduceDDDep';
            warnmsg=message(warnid,depSavePath);
            warnObj=MException(warnmsg);
            rManager.Warnings{end+1}=warnObj;
            try
                slddConn.close();
            catch
            end
        end
    end
end


