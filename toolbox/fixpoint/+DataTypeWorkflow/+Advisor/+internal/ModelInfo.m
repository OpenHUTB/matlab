classdef ModelInfo<handle







    properties(Constant)
        SourceBlockName=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.SourceBlockName
        InputDataTypeConversionPrefix=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.InputDataTypeConversionPrefix
        OutputDataTypeConversionPrefix=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.OutputDataTypeConversionPrefix
        SubsystemPrefix=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.SubsystemPrefix


        DataTypeConversionBlockPath=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.DataTypeConversionBlockPath

        InputBlockSpacing=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.InputBlockSpacing
        InputBlockWidth=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.InputBlockWidth
        ModelNamePrefix=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.ModelNamePrefix
    end

    properties
ModelObject
        ModelName=''
    end

    methods

        function name=getInputDataTypeConversionName(this,portNumber)

            name=[this.InputDataTypeConversionPrefix,num2str(portNumber,'%g')];
        end

        function name=getOutputDataTypeConversionName(this,portNumber)

            name=[this.OutputDataTypeConversionPrefix,num2str(portNumber,'%g')];
        end

        function name=getSubsystemName(this)

            name=[this.SubsystemPrefix,this.SourceBlockName];
        end

        function blockPath=getBlockPath(this)

            blockPath=[this.ModelName,'/',this.SourceBlockName];
        end

        function blockPath=getInputDataTypeConversionPath(this,portNumber)


            blockName=getInputDataTypeConversionName(this,portNumber);
            blockPath=[this.ModelName,'/',blockName];
        end

        function blockPath=getOutputDataTypeConversionPath(this,portNumber)


            blockName=getOutputDataTypeConversionName(this,portNumber);
            blockPath=[this.ModelName,'/',blockName];
        end

        function blockPath=getSubsystemPath(this)

            blockName=getSubsystemName(this);
            blockPath=[this.ModelName,'/',blockName];
        end

        function show(this)

            set_param(this.ModelName,'Open','on');
        end

        function dirtyOff(this)

            set_param(this.ModelName,'Dirty','off');
        end

        function hide(this)

            set_param(this.ModelName,'Open','off');
        end

        function clearAutosaveFile(this)

            autosaveFile=[this.ModelName,'.slx.autosave'];
            FunctionApproximation.internal.deleteFile(autosaveFile);
        end

        function clearSimulinkCache(this)

            cacheFile=[this.ModelName,'.slxc'];
            FunctionApproximation.internal.deleteFile(cacheFile);
        end

        function clearTempFiles(this)

            clearAutosaveFile(this);
            clearSimulinkCache(this);
        end

        function delete(this)

            close_system(this.ModelName,0);
        end

        function blockHandles=getBlockHandlesForInternalBlocks(this)




            allBlocks=find_system(this.ModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','Block');

            blockHandles=zeros(1,numel(allBlocks));
            for ii=1:numel(blockHandles)
                blockHandles(ii)=get_param(allBlocks{ii},'Handle');
            end
        end

        function unlinkModel(this)

            this.ModelObject=[];
            this.ModelName='';
        end
    end
end
