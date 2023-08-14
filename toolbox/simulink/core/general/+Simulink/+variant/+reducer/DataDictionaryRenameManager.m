classdef(Hidden,Sealed)DataDictionaryRenameManager<handle




    properties(Transient,Access=private)

        ReductionManager;


        DDNameRedDDNameMap;


        DDNameParentDDNamesMap;


        DDCyclicParentNameRefDDNameMap;


        DDNameRedModelWithVCDOWithDDNameAsSourceMap;


        AllDataDictionariesFilePathList(1,:)cell={};


        DDNameAssociatedOrigModelNamesMap;




        OrigModelDataDictionaryParamModificationMap;


        RenamedModelsSoFar={};


        AllHierarchicalModels={};
    end

    methods(Access=public)


        function obj=DataDictionaryRenameManager(rManager)
            obj.ReductionManager=rManager;
            obj.setMapsToDefault();
        end

        function delete(obj)
            obj.restoreOrigModelsDataDictionaryParams();
            obj.setMapsToDefault();
        end


        function isRenamedDataDictionary=getIsRenamedDataDictionary(obj,dataDictionaryName)
            isRenamedDataDictionary=obj.DDNameRedDDNameMap.isKey(dataDictionaryName);
        end


        function isRenamedReducedDataDictionary=getIsRenamedReducedDataDictionary(obj,dataDictionaryName)
            isRenamedReducedDataDictionary=any(strcmp(obj.getAllReducedRenamedDataDictionaries(),dataDictionaryName));
        end


        function allReducedRenamedDataDictionaries=getAllReducedRenamedDataDictionaries(obj)
            allReducedRenamedDataDictionaries=cellfun(@(X)obj.DDNameRedDDNameMap(X),obj.DDNameRedDDNameMap.keys,'UniformOutput',false);
        end


        function allDataDictionariesFilePathList=getAllDataDictionariesFilePathList(obj)
            allDataDictionariesFilePathList=obj.AllDataDictionariesFilePathList;
        end


        function restoreOrigModelsDataDictionaryParams(obj)
            origModelsWithModifiedDDParams=obj.OrigModelDataDictionaryParamModificationMap.keys;
            for i=1:numel(origModelsWithModifiedDDParams)





                Simulink.variant.reducer.utils.setParamWithDirtyOff(origModelsWithModifiedDDParams{i},'DataDictionary',obj.OrigModelDataDictionaryParamModificationMap(origModelsWithModifiedDDParams{i}));

                obj.OrigModelDataDictionaryParamModificationMap.remove(origModelsWithModifiedDDParams{i});
            end
        end


        function[err,dataDictionaryNameRed,dataDictionaryFileRed]=renameReducedDataDictionarySemantically(obj,dataDictionaryNameOrig,dataDictionaryFileOrig,absOutDirPath,modelName,redModelName)




            err=[];
            dataDictionaryNameRed=Simulink.variant.reducer.DataDictionaryRenameManager.getDataDictionaryNameOfReducedModel(dataDictionaryFileOrig,obj.ReductionManager.ReductionOptions.Suffix);
            dataDictionaryFileRed=fullfile(absOutDirPath,dataDictionaryNameRed);


            hasDDBeenRenamed=any(strcmp(dataDictionaryNameOrig,obj.DDNameRedDDNameMap.keys));
            if~hasDDBeenRenamed
                copyfile(dataDictionaryFileOrig,dataDictionaryFileRed,'f');
                fileattrib(dataDictionaryFileRed,'+w');
                obj.DDNameRedDDNameMap(dataDictionaryNameOrig)=dataDictionaryNameRed;
            end

            obj.updateDataDictionaryParams(modelName,redModelName,dataDictionaryNameOrig,dataDictionaryNameRed);

            dataDictionaryObjOrig=Simulink.data.dictionary.open(dataDictionaryNameOrig);
            dataDictionaryObjRed=Simulink.data.dictionary.open(dataDictionaryNameRed);

            if~hasDDBeenRenamed
                [~,selfAndChildDataDictionaryFilePathList,dirtyDataDictionaries]=Simulink.variant.reducer.DataDictionaryRenameManager.getAllChildDictionaries(dataDictionaryNameOrig,obj.ReductionManager.Environment.DirtyDataDictionaryFilesBeforeReduction);
                obj.AllDataDictionariesFilePathList=[obj.AllDataDictionariesFilePathList,selfAndChildDataDictionaryFilePathList];
                if~isempty(dirtyDataDictionaries)


                    errid='Simulink:Variants:InvalidModelDDDirty';
                    errmsg=message(errid,modelName,strjoin(dirtyDataDictionaries,', '));
                    err=MException(errmsg);
                    return;
                end


                dataDictionaryObjRed.EnableAccessToBaseWorkspace=dataDictionaryObjOrig.EnableAccessToBaseWorkspace;



                if obj.DDNameParentDDNamesMap.isKey(dataDictionaryNameOrig)
                    parentDataDictionaries=obj.DDNameParentDDNamesMap(dataDictionaryNameOrig);
                    for i=1:numel(parentDataDictionaries)
                        parentDataDictionaryRedObj=Simulink.data.dictionary.open(obj.DDNameRedDDNameMap(parentDataDictionaries{i}));
                        Simulink.variant.reducer.DataDictionaryRenameManager.updateDataSource(parentDataDictionaryRedObj,dataDictionaryNameOrig,dataDictionaryNameRed);
                        parentDataDictionaryRedObj.close();
                    end

                    obj.DDNameParentDDNamesMap.remove(dataDictionaryNameOrig);
                end

                refDataDictionariesRed=dataDictionaryObjRed.DataSources();
                for i=1:numel(refDataDictionariesRed)

                    Simulink.variant.utils.i_addKeyValueToMap(obj.DDNameParentDDNamesMap,refDataDictionariesRed{i},{dataDictionaryNameOrig});



                    if obj.DDNameRedDDNameMap.isKey(refDataDictionariesRed{i})
                        Simulink.variant.reducer.DataDictionaryRenameManager.updateDataSource(dataDictionaryObjRed,refDataDictionariesRed{i},obj.DDNameRedDDNameMap(refDataDictionariesRed{i}));
                    end
                end


                allChildDataDictionariesList=Simulink.variant.reducer.DataDictionaryRenameManager.getAllChildDictionaries(dataDictionaryNameOrig,obj.ReductionManager.Environment.DirtyDataDictionaryFilesBeforeReduction);
                cyclicParents=Simulink.variant.reducer.DataDictionaryRenameManager.getAllCyclicParents(dataDictionaryNameOrig,allChildDataDictionariesList);
                for i=1:numel(cyclicParents)
                    cyclicParent=cyclicParents{i};
                    if any(strcmp(cyclicParent,obj.DDNameRedDDNameMap.keys))
                        continue;
                    end
                    dataDictionaryObjParent=Simulink.data.dictionary.open(cyclicParent);
                    Simulink.variant.reducer.DataDictionaryRenameManager.updateDataSource(dataDictionaryObjParent,dataDictionaryNameOrig,dataDictionaryNameRed);
                    obj.DDCyclicParentNameRefDDNameMap(cyclicParent)=dataDictionaryNameOrig;
                    dataDictionaryObjParent.close();
                end

                if obj.DDCyclicParentNameRefDDNameMap.isKey(dataDictionaryNameOrig)
                    oldSource=obj.DDNameRedDDNameMap(obj.DDCyclicParentNameRefDDNameMap(dataDictionaryNameOrig));
                    newSource=obj.DDCyclicParentNameRefDDNameMap(dataDictionaryNameOrig);
                    Simulink.variant.reducer.DataDictionaryRenameManager.updateDataSource(dataDictionaryObjOrig,oldSource,newSource);
                    obj.DDCyclicParentNameRefDDNameMap.remove(dataDictionaryNameOrig);
                end
            end

            if~obj.ReductionManager.ReductionOptions.IsConfigVarSpec






                for midx=1:numel(obj.AllHierarchicalModels)
                    modelName=obj.AllHierarchicalModels{midx};




                    if isKey(obj.ReductionManager.BDNameRedBDNameMap,modelName)
                        modelName=obj.ReductionManager.BDNameRedBDNameMap(modelName);
                    end

                    variantConfigurationObject=Simulink.variant.utils.getConfigurationDataNoThrow(modelName);
                    if isempty(variantConfigurationObject)
                        continue;
                    end


                    processedModels=obj.DDNameRedModelWithVCDOWithDDNameAsSourceMap.values;
                    if~isempty(processedModels)&&any(strcmp([processedModels{:}],modelName))
                        continue;
                    end

                    sources=variantConfigurationObject.getSourcesOfControlVars();
                    for i=1:numel(sources)
                        Simulink.variant.utils.i_addKeyValueToMap(obj.DDNameRedModelWithVCDOWithDDNameAsSourceMap,sources{i},{modelName});
                    end
                end
            end

            if obj.DDNameRedModelWithVCDOWithDDNameAsSourceMap.isKey(dataDictionaryNameOrig)


                modelsWithVCDOWithDDNameAsSource=obj.DDNameRedModelWithVCDOWithDDNameAsSourceMap(dataDictionaryNameOrig);
                for i=1:numel(modelsWithVCDOWithDDNameAsSource)



                    modelName=modelsWithVCDOWithDDNameAsSource{i};
                    if isKey(obj.ReductionManager.BDNameRedBDNameMap,modelName)
                        modelName=obj.ReductionManager.BDNameRedBDNameMap(modelName);
                    end
                    variantConfigurationObject=Simulink.variant.utils.getConfigurationDataNoThrow(modelName);
                    if~isempty(variantConfigurationObject)
                        variantConfigurationObject.updateSource(dataDictionaryNameRed,dataDictionaryNameOrig);
                        Simulink.variant.manager.configutils.saveFor(modelName,get_param(modelName,'VariantConfigurationObject'),variantConfigurationObject);
                    end
                end
                obj.DDNameRedModelWithVCDOWithDDNameAsSourceMap.remove(dataDictionaryNameOrig);
            end


            if~strcmp(redModelName,obj.ReductionManager.ReductionOptions.TopModelName)&&obj.ReductionManager.ReductionOptions.IsConfigVarSpec
                variantConfigurationObject=Simulink.variant.utils.getConfigurationDataNoThrow(obj.ReductionManager.ReductionOptions.TopModelName);
                if~isempty(variantConfigurationObject)


                    variantConfigurationObject.updateSource(dataDictionaryNameRed,dataDictionaryNameOrig);
                    Simulink.variant.manager.configutils.saveFor(obj.ReductionManager.ReductionOptions.TopModelName,get_param(obj.ReductionManager.ReductionOptions.TopModelName,'VariantConfigurationObject'),variantConfigurationObject);
                end
            end
            dataDictionaryObjRed.close();
            dataDictionaryObjOrig.close();
        end


        function initializeDDNameAssociatedOrigModelNamesMap(obj,modelName)
            Simulink.variant.utils.assert(strcmp(obj.ReductionManager.ReductionOptions.TopModelOrigName,modelName));

            obj.AllHierarchicalModels=[modelName,Simulink.variant.utils.i_find_mdlrefs(modelName,struct('RecurseIntoModelReferences',true))];
            for i=1:numel(obj.AllHierarchicalModels)
                dataDictionaryName=get_param(obj.AllHierarchicalModels{i},'DataDictionary');
                if~isempty(dataDictionaryName)
                    Simulink.variant.utils.i_addKeyValueToMap(obj.DDNameAssociatedOrigModelNamesMap,dataDictionaryName,obj.AllHierarchicalModels(i));
                end
            end
        end
    end

    methods(Access=private)


        function setMapsToDefault(obj)
            obj.DDNameRedDDNameMap=containers.Map('keyType','char','valueType','char');
            obj.DDNameParentDDNamesMap=containers.Map('keyType','char','valueType','any');
            obj.DDCyclicParentNameRefDDNameMap=containers.Map('keyType','char','valueType','any');
            obj.DDNameRedModelWithVCDOWithDDNameAsSourceMap=containers.Map('keyType','char','valueType','any');
            obj.DDNameAssociatedOrigModelNamesMap=containers.Map('keyType','char','valueType','any');
            obj.OrigModelDataDictionaryParamModificationMap=containers.Map('keyType','char','valueType','any');
        end



        function updateDataDictionaryParams(obj,modelName,redModelName,dataDictionaryNameOrig,dataDictionaryNameRed)
            if~isempty(redModelName)
                obj.RenamedModelsSoFar=[obj.RenamedModelsSoFar,modelName];
                set_param(redModelName,'DataDictionary',dataDictionaryNameRed);
                allChildReferenceModelsWithSameDDName=setdiff(obj.DDNameAssociatedOrigModelNamesMap(dataDictionaryNameOrig),obj.RenamedModelsSoFar);
                for i=1:numel(allChildReferenceModelsWithSameDDName)
                    if obj.OrigModelDataDictionaryParamModificationMap.isKey(allChildReferenceModelsWithSameDDName{i})
                        continue;
                    end
                    obj.OrigModelDataDictionaryParamModificationMap(allChildReferenceModelsWithSameDDName{i})=get_param(allChildReferenceModelsWithSameDDName{i},'DataDictionary');





                    Simulink.variant.reducer.utils.setParamWithDirtyOff(allChildReferenceModelsWithSameDDName{i},'DataDictionary',dataDictionaryNameRed);
                end

                if obj.OrigModelDataDictionaryParamModificationMap.isKey(modelName)





                    Simulink.variant.reducer.utils.setParamWithDirtyOff(modelName,'DataDictionary',obj.OrigModelDataDictionaryParamModificationMap(modelName));

                    obj.OrigModelDataDictionaryParamModificationMap.remove(modelName);
                end
            end
        end
    end

    methods(Static=true,Access=private)


        function dataDictionaryNameRed=getDataDictionaryNameOfReducedModel(dataDictionaryFileOrig,suffix)
            [~,ddNameWithoutExt,ext]=fileparts(dataDictionaryFileOrig);
            dataDictionaryNameRed=[ddNameWithoutExt,suffix,ext];
        end


        function cyclicParents=getAllCyclicParents(dataDictionaryNameOrig,allChildDataDictionariesList)
            cyclicParents={};
            for i=1:numel(allChildDataDictionariesList)
                if(numel(allChildDataDictionariesList{i})>1)&&strcmp((allChildDataDictionariesList{i}{end}),dataDictionaryNameOrig)
                    cyclicParents=[cyclicParents,allChildDataDictionariesList{i}{end-1}];%#ok<AGROW>
                end
            end
        end



        function[childDataDictionariesList,selfAndChildDataDictionaryFilePathList,dirtyDataDictionariesUsed]=getAllChildDictionaries(dataDictionaryName,initialDirtyDataDictionaryFiles,varargin)
            if isempty(varargin)
                dataDictionariesSoFar={dataDictionaryName};
            else
                dataDictionariesSoFar=varargin{1};
            end

            dataDictionaryObj=Simulink.data.dictionary.open(dataDictionaryName);

            selfAndChildDataDictionaryFilePathList={dataDictionaryObj.filepath};

            childDataDictionaries=dataDictionaryObj.DataSources();
            childDataDictionariesList={childDataDictionaries};

            initialDirtyDataDictionaryNames=cellfun(@(X)(Simulink.variant.reducer.DataDictionaryRenameManager.getDataDictionaryNameFromFile(X)),initialDirtyDataDictionaryFiles,'UniformOutput',false);

            if any(strcmp(dataDictionaryName,initialDirtyDataDictionaryNames))
                dirtyDataDictionariesUsed={dataDictionaryName};
            else
                dirtyDataDictionariesUsed={};
            end

            listIndex=1;
            for i=1:numel(childDataDictionaries)
                childDataDictionary=childDataDictionaries{i,1};
                if any(strcmp(dataDictionariesSoFar,childDataDictionary))





                    childDataDictionariesListNested={{}};
                else
                    [childDataDictionariesListNested,selfAndChildDataDictionaryFilePathListNested,dirtyDataDictionariesUsedNested]=Simulink.variant.reducer.DataDictionaryRenameManager.getAllChildDictionaries(childDataDictionary,initialDirtyDataDictionaryFiles,[dataDictionariesSoFar,childDataDictionary]);
                    selfAndChildDataDictionaryFilePathList=[selfAndChildDataDictionaryFilePathList,selfAndChildDataDictionaryFilePathListNested];%#ok<AGROW>
                    dirtyDataDictionariesUsed=[dirtyDataDictionariesUsed,dirtyDataDictionariesUsedNested];%#ok<AGROW>
                end
                for j=1:numel(childDataDictionariesListNested)
                    childDataDictionariesList{listIndex,1}=[{childDataDictionary},childDataDictionariesListNested{j,:}(:)'];
                    listIndex=listIndex+1;
                end
            end
            dataDictionaryObj.close();
        end


        function dataDictionaryName=getDataDictionaryNameFromFile(dataDictionaryFile)
            [~,name,ext]=fileparts(dataDictionaryFile);
            dataDictionaryName=[name,ext];
        end


        function updateDataSource(dataDictionaryObj,oldSource,newSource)
            dataDictionaryObj.removeDataSource(oldSource);
            dataDictionaryObj.addDataSource(newSource);
        end
    end
end


