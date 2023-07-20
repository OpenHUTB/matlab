classdef LUTMemoryUsageCalculator<handle







    properties(Constant,Hidden)
        BlockTypesToSearch={'Lookup_n-D'};
        BlockValidationAPI={'isLUTBlock'};
        DataExtractor={'LUTBlockToDataAdapterAssumeModelCompile'};
    end

    properties(Hidden)
        DataBase cell
        FindOptions Simulink.internal.FindOptions=...
        Simulink.FindOptions('IncludeCommented',0);
        StopCompileOnExit logical=true
    end

    methods
        function obj=LUTMemoryUsageCalculator()
            if Simulink.internal.useFindSystemVariantsMatchFilter()




                obj.FindOptions.MatchFilter=@Simulink.match.activeVariants;
            else


                obj.FindOptions.Variants='ActiveVariants';
            end
        end

        function usageTable=memoryusage(this,path)

            isPathOfRegisteredType=isBlockOfRegisteredType(this,path);



            if~isPathOfRegisteredType&&FunctionApproximation.internal.Utils.getBlockType(path)~="SubSystem"
                path=bdroot(path);
            end


            collectData(this,path,isPathOfRegisteredType);


            usageTable=buildTable(this,path,isPathOfRegisteredType);
        end
    end

    methods(Hidden)
        function collectData(this,path,isPathOfRegisteredType)
            slFeatureState=slfeature('EngineInterface');


            topModel=bdroot(path);
            allModelsOpenOld=find_system('Type','block_diagram');
            if isPathOfRegisteredType
                modelsToCompile={topModel};
                allPaths={path};
            else
                if Simulink.internal.useFindSystemVariantsMatchFilter()






                    [allModels,~,mdlRefGraph]=find_mdlrefs(path,...
                    'AllLevels',true,...
                    'IncludeProtectedModels',false,...
                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                    'IncludeCommented',this.FindOptions.IncludeCommented,...
                    'KeepModelsLoaded',true);
                else

                    [allModels,~,mdlRefGraph]=find_mdlrefs(path,...
                    'AllLevels',true,...
                    'IncludeProtectedModels',false,...
                    'Variants',this.FindOptions.Variants,...
                    'IncludeCommented',this.FindOptions.IncludeCommented,...
                    'KeepModelsLoaded',true);
                end
                allSystems=allModels;
                allSystems{end}=path;
                modelsToCompile=getModelsToCompile(this,mdlRefGraph);
                modelsToCompile=[{topModel},modelsToCompile];
            end
            allModelsOpenNew=find_system('Type','block_diagram');
            loadedModels=setdiff(allModelsOpenNew,allModelsOpenOld);


            allModelsCompileHandler=compileModels(this,modelsToCompile);




            if~isPathOfRegisteredType
                allPaths=getBlockPathsForMemoryCalculation(this,allSystems);
            end

            validPaths=true(1,numel(allPaths));
            for ii=1:numel(allPaths)
                validPaths(ii)=~FunctionApproximation.internal.approximationblock.isUnderFunctionApproximationBlock(allPaths{ii});
            end
            allPaths=allPaths(validPaths);



            lutDataCell=cell(size(allPaths));
            for sortedIndices=1:numel(lutDataCell)
                blockObject=get_param(allPaths{sortedIndices},'Object');
                blockType=blockObject.BlockType;
                dataExtractor=this.DataExtractor{cellfun(@(x)~isempty(x),regexp(blockType,this.BlockTypesToSearch))};
                lutDataCell{sortedIndices}=FunctionApproximation.internal.serializabledata.(dataExtractor);
                lutDataCell{sortedIndices}=lutDataCell{sortedIndices}.update(allPaths{sortedIndices});
            end

            if this.StopCompileOnExit

                for iModel=1:numel(allModelsCompileHandler)
                    stop(allModelsCompileHandler{iModel});
                end


                close_system(loadedModels,0);
            end

            this.DataBase=lutDataCell;

            slfeature('EngineInterface',slFeatureState);
        end

        function allModelsCompileHandler=compileModels(~,modelsToCompile)

            for iModel=1:numel(modelsToCompile)
                allModelsCompileHandler{iModel}=fixed.internal.modelcompilehandler.ModelCompileHandler(modelsToCompile{iModel});%#ok<AGROW>
                try
                    start(allModelsCompileHandler{iModel});
                catch
                    stop(allModelsCompileHandler{iModel});
                end
            end
        end

        function allPaths=getBlockPathsForMemoryCalculation(this,allModels)
            allPaths={};
            for iModel=1:numel(allModels)
                modelPath=allModels{iModel};
                for iTypes=1:numel(this.BlockTypesToSearch)
                    blockHandles=Simulink.findBlocksOfType(modelPath,this.BlockTypesToSearch{iTypes},this.FindOptions);
                    blockPaths=arrayfun(@(x)Simulink.ID.getFullName(x),blockHandles,'UniformOutput',false);
                    blockPaths=blockPaths(:);
                    allPaths=[allPaths;blockPaths];%#ok<AGROW>
                end
            end
        end

        function modelsToCompile=getModelsToCompile(~,mdlRefGraph)
            modelsToCompile={};
            mdlRefVertices=mdlRefGraph.getAllVertexIDs';

            for ii=mdlRefVertices
                sourceToTargetEdges=mdlRefGraph.getEdges(ii,'outbound');
                if~isempty(sourceToTargetEdges)
                    targetData=[mdlRefGraph.getVertex([sourceToTargetEdges.TargetID]).Data];
                    modelsToCompile=[modelsToCompile,{targetData.Name}];%#ok<AGROW>
                end
            end
        end

        function usageTable=buildTable(this,path,isPathOfRegisteredType)
            tableBuilderContext=FunctionApproximation.internal.memoryusagetablebuilder.TableBuilderContext();
            tableBuilderContext.setDataBase(this.DataBase);
            descriptionGenerator=FunctionApproximation.internal.memoryusagetablebuilder.getDescriptionGenerator(isPathOfRegisteredType);
            tableBuilderContext.setDescriptionGenerator(descriptionGenerator);
            tableBuilderContext.setPath(path);
            tableBuilder=FunctionApproximation.internal.memoryusagetablebuilder.MemoryUsageTableBuilder();
            usageTable=tableBuilder.build(tableBuilderContext);
        end

        function flag=isBlockOfRegisteredType(this,path)
            flag=false;
            for iTypes=1:numel(this.BlockTypesToSearch)
                flag=FunctionApproximation.internal.Utils.(this.BlockValidationAPI{iTypes})(path);
                if flag
                    break;
                end
            end
        end
    end
end
