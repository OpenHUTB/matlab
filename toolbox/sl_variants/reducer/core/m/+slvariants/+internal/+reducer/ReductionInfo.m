classdef(Sealed,Hidden)ReductionInfo<handle




    methods(Access=public)

        function obj=ReductionInfo()
            obj.ReductionOptions=slvariants.internal.reducer.ReductionOptions();
            obj.Environment=Simulink.variant.reducer.Environment();
        end

        function env=getEnvironment(obj)
            env=obj.Environment;
        end

        function reducedModelPath=getReducedModelPath(obj)
            reducedModelPath=obj.ReducedModelPath;
        end

        function setReducedModelPath(obj,reducedModelPath)
            obj.ReducedModelPath=reducedModelPath;
            [~,obj.ReducedModelName,~]=fileparts(obj.ReducedModelPath);
        end

        function redMdlName=getReducedModelName(obj)
            redMdlName=obj.ReducedModelName;
        end

        function setReductionOptions(obj,rOpts)
            obj.UIFrameHandle=rOpts.UIFrameHandle;
            obj.FullRangeVariables=rOpts.FullRangeVariables;
            obj.ReducedModelName=[rOpts.TopModelOrigName,rOpts.Suffix];
            obj.ConfigInfos=rOpts.ConfigInfos;
            obj.VerboseInfoObj=Simulink.variant.utils.VerboseInfoHandler(rOpts);

            if~isempty(rOpts.OutputFolder)
                obj.ReductionOptions.setOutputFolder(rOpts.OutputFolder);
            end

            obj.ReductionOptions.setModelName(rOpts.TopModelOrigName);
            obj.ReductionOptions.setCompileMode(rOpts.CompileMode);
            obj.ReductionOptions.setPreserveSignalAttributes(rOpts.ValidateSignals);
            obj.ReductionOptions.setVerbose(rOpts.Verbose);
            obj.ReductionOptions.setModelSuffix(rOpts.Suffix);
            obj.ReductionOptions.setGenerateSummary(rOpts.GenerateReport);

            if~isempty(rOpts.ExcludeFiles)

                filesFullList=...
                slvariants.internal.reducer.ReductionInfo.getFullFilesListWithCheck(rOpts.ExcludeFiles);
                obj.ReductionOptions.setExcludeFilesFullList(filesFullList);
                obj.ReductionOptions.setExcludeFiles(rOpts.ExcludeFiles);
            end

            isVarGroupCfg=rOpts.IsConfigVarSpec||~isempty(rOpts.FullRangeVariables);
            obj.ReductionOptions.setConfigSpecifiedAsVariableGroups(isVarGroupCfg);
            isNamedCfg=~isVarGroupCfg;
            if isNamedCfg
                if isa(rOpts.ConfigInfos,'char')
                    obj.ConfigInfos=cellstr(rOpts.ConfigInfos);
                end
                obj.validateNamedConfigs();





                obj.ReductionOptions.setNamedConfigurations(obj.ConfigInfos);
            end
        end

        function opts=getReductionOptions(obj)
            opts=obj.ReductionOptions;
        end

        function val=isSimCompileMode(obj)
            val=strcmp(obj.ReductionOptions.getCompileMode(),'sim');
        end

        function configInfo=getConfigInfos(obj)
            configInfo=obj.ConfigInfos;
        end

        function setGeneratedNamedCfgs(obj,namedCfgs)






            obj.ReductionOptions.setNamedConfigurations(namedCfgs);
        end

        function fullRangeVar=getFullRangeVariables(obj)
            fullRangeVar=obj.FullRangeVariables;
        end

        function validateNamedConfigs(obj)
            checkEveryNamedCfgIsChar(obj);



            configNamesCell=obj.ConfigInfos;
            numConfigs=length(configNamesCell);
            numUniqueConfigs=length(unique(configNamesCell));
            if numConfigs~=numUniqueConfigs
                errid='Simulink:Variants:NonUniqueConfigNames';
                errmsg=message(errid,obj.ReductionOptions.getModelName());
                err=MException(errmsg);
                throwAsCaller(err);
            end
        end

        function verboseInfoObj=getVerboseInfoObj(obj)
            verboseInfoObj=obj.VerboseInfoObj;
        end

    end

    methods(Access=private)

        function checkEveryNamedCfgIsChar(obj)



            for configIdx=1:numel(obj.ConfigInfos)
                if isa(obj.ConfigInfos{configIdx},'char')
                    continue;
                end
                errid='Simulink:Variants:InvalidModelConfigsArgNonChar';
                errmsg=message(errid,configIdx,1);
                err=MException(errmsg);
                throwAsCaller(err);
            end
        end

    end

    methods(Access=private,Static)

        function fileList=getFullFilesListWithCheck(skipFiles)

            fileList={};
            for ii=1:length(skipFiles)

                tmp=dir(skipFiles{ii});
                if~isempty(tmp)
                    fileList=[fileList;arrayfun(@(x)(fullfile(x.folder,x.name)),tmp,...
                    'UniformOutput',false);];%#ok<AGROW> 
                else



                    tmp=which(skipFiles{ii});
                    if~isempty(tmp)
                        fileList=[fileList;{tmp}];%#ok<AGROW> 
                    end
                end
            end




            [~,~,exts]=cellfun(@fileparts,fileList,'UniformOutput',false);
            errIdx=arrayfun(@(x)(~strcmp(x,'.sldd')&&~strcmp(x,'.mat')),exts);
            if any(errIdx)


                errid='Simulink:VariantReducer:InvalidExcludeFiles';
                errmsg=message(errid,strjoin(fileList(errIdx),', '));
                err=MException(errmsg);
                throwAsCaller(err);
            end

            fileList=fileList.';
        end

    end

    properties(Access=private)


        ReducedModelPath(1,:)char;


        ReducedModelName(1,:)char;


        Environment Simulink.variant.reducer.Environment;


        ConfigInfos={};


        FullRangeVariables(1,:)cell={};


        UIFrameHandle=[];


        ReductionOptions(1,1)slvariants.internal.reducer.ReductionOptions;


        VerboseInfoObj(1,1)Simulink.variant.utils.VerboseInfoHandler;

    end

end
