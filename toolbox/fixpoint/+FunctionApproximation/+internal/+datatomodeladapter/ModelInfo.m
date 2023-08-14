classdef ModelInfo<matlab.mixin.Copyable







    properties(Constant)
        SourceBlockName='ReplicaOfSource'
        InputPrefix='Input'
        SignalSpecificationPrefix='SigSpec'
        DataTypeConversionPrefix='DTC'
        OutputName='Output'
        ConstantBlockLibraryPath='simulink/Sources/Constant'
        RepeatingSequenceStairBlockLibraryPath='simulink/Sources/Repeating Sequence Stair'
        InportBlockLibraryPath='simulink/Sources/In1'
        OutportBlockLibraryPath='simulink/Sinks/Out1'
        DataTypeConversionBlockPath='simulink/Signal Attributes/Data Type Conversion'
        SignalSpecificationBlockPath='simulink/Signal Attributes/Signal Specification'
        InputBlockSpacing=20
        InputBlockWidth=300
        ModelNamePrefix='ModelWithApproximation_'
    end

    properties(SetAccess=immutable)
        InputValuesVariableName=['InputValues_',datestr(now,'yyyymmddTHHMMSSFFF')]
    end

    properties(SetAccess={...
        ?FunctionApproximation.internal.datatomodeladapter.ModelInfo,...
        ?FunctionApproximation.internal.datatomodeladapter.DataToModel,...
        })
        ModelObject=[]
        ModelName=''
        ModelWorkspace=[]
        TempDirHandler=[]
    end

    properties(SetAccess=private)
        VectorizationHandler FunctionApproximation.internal.datatomodeladapter.ModelVectorizationHandler
NumberOfDimensions
    end

    methods
        function this=ModelInfo()
            this.TempDirHandler=FunctionApproximation.internal.TempDirectoryHandler();
            this.TempDirHandler.createDirectory();
            this.VectorizationHandler=FunctionApproximation.internal.datatomodeladapter.ModelVectorizationHandler();
        end

        function name=getInputBlockName(this,portNumber)

            name=[this.InputPrefix,num2str(portNumber,'%g')];
        end

        function name=getSignalSpecificationName(this,portNumber)


            name=[this.SignalSpecificationPrefix,num2str(portNumber,'%g')];
        end

        function name=getDataTypeConversionName(this,portNumber)


            name=[this.DataTypeConversionPrefix,num2str(portNumber,'%g')];
        end

        function blockPath=getBlockPath(this)

            blockPath=[this.ModelName,'/',this.SourceBlockName];
        end

        function blockPath=getInputPath(this,portNumber)

            blockName=getInputBlockName(this,portNumber);
            blockPath=[this.ModelName,'/',blockName];
        end

        function blockPath=getSignalSpecificationPath(this,portNumber)


            blockName=getSignalSpecificationName(this,portNumber);
            blockPath=[this.ModelName,'/',blockName];
        end

        function blockPath=getDataTypeConversionPath(this,portNumber)


            blockName=getDataTypeConversionName(this,portNumber);
            blockPath=[this.ModelName,'/',blockName];
        end

        function blockPath=getOutputBlockPath(this)

            blockPath=[this.ModelName,'/',this.OutputName];
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

        function update(this,blockData)


            this.NumberOfDimensions=blockData.NumberOfDimensions;
            for ii=1:blockData.NumberOfDimensions
                set_param(getSignalSpecificationPath(this,ii),'OutDataTypeStr',blockData.InputTypes(ii).tostring());
            end
        end

        function blockHandles=getBlockHandlesForInternalBlocks(this)




            allBlocks=find_system(this.ModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','Block');
            for ii=numel(allBlocks):-1:1
                if contains(allBlocks{ii},[this.ModelName,'/',this.InputPrefix])||contains(allBlocks{ii},[this.ModelName,'/',this.OutputName])
                    allBlocks(ii)=[];
                end
            end

            blockHandles=zeros(1,numel(allBlocks));
            for ii=1:numel(blockHandles)
                blockHandles(ii)=get_param(allBlocks{ii},'Handle');
            end
        end

        function inputBlockHandles=getInputBlockHandle(this)



            allBlocks=find_system(this.ModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','Block');
            for ii=numel(allBlocks):-1:1
                if~contains(allBlocks{ii},[this.ModelName,'/',this.InputPrefix])
                    allBlocks(ii)=[];
                end
            end

            inputBlockHandles=zeros(1,numel(allBlocks));
            for ii=1:numel(inputBlockHandles)
                inputBlockHandles(ii)=get_param(allBlocks{ii},'Handle');
            end
        end

        function inputBlockPositions=getInputBlockPositions(this)

            inputBlockHandles=getInputBlockHandle(this);
            inputBlockPositions=zeros(numel(inputBlockHandles),4);
            for ii=1:numel(inputBlockHandles)
                inputBlockPositions(ii,:)=get_param(inputBlockHandles(ii),'Position');
            end
        end

        function unlinkModel(this)

            this.ModelObject=[];
            this.ModelWorkspace=[];
            this.ModelName='';
        end

        function saveModel(this)

            if~isempty(this.ModelObject)
                this.TempDirHandler.createDirectory();
                curDir=pwd;
                cd(this.TempDirHandler.TempDir);
                save_system(this.ModelName);
                cd(curDir);
            end
        end

        function closeModel(this)


            if~isempty(this.ModelObject)
                saveModel(this);
                close_system(this.ModelName,0);
                this.ModelObject=[];
                this.ModelWorkspace=[];
            end
        end

        function loadModel(this)

            if isempty(this.ModelObject)
                curDir=pwd;
                cd(this.TempDirHandler.TempDir);
                load_system(this.ModelName);
                this.ModelObject=get_param(this.ModelName,'Object');
                this.ModelWorkspace=get_param(this.ModelName,'ModelWorkspace');
                cd(curDir);
            end
        end

        function setVectorized(this,value)
            if~isempty(this.ModelObject)


                this.VectorizationHandler.handle(this,value);
            end
        end
    end
end
