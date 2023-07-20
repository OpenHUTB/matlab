classdef(Sealed,Hidden)Core<handle




    methods(Access=public)

        function obj=Core()
            Simulink.variant.reducer.AliveSwitch.getInstance().setAliveStatus(true);
            obj.ReductionInfo=slvariants.internal.reducer.ReductionInfo();
            obj.ConfigHandler=slvariants.internal.reducer.ConfigHandler(obj.ReductionInfo);
            obj.Layouter=slvariants.internal.reducer.Layouter();
        end

        function delete(~)


            Simulink.variant.reducer.AliveSwitch.getInstance().setAliveStatus(false);
        end

        function processConfigs(obj,modelPath)












            [folderPath,~,~]=fileparts(modelPath);
            obj.ReductionInfo.setReducedModelPath(modelPath);
            cd(folderPath);
            obj.ConfigHandler.processConfigs();
        end

        function validateSlExpr(obj)
            obj.ConfigHandler.validateSlExpr();
        end

        function compile(obj,configName)
            obj.ConfigHandler.compileForConfig(configName);
        end

        function setReductionOptions(obj,rOpts)
            cleanup=onCleanup(@()obj.postProcessReduceModelError());
            try
                obj.ReductionInfo.setReductionOptions(rOpts);
                obj.ConfigHandler.getCompileHandler.setReductionInfo(obj.ReductionInfo);
            catch excep
                Simulink.variant.reducer.utils.logException(excep);
                obj.Error=excep;
            end
        end

        function reduce(obj)
            if~isempty(obj.Error)
                return;
            end
            cleanup=onCleanup(@()obj.postProcessReduceModelError());
            try
                slvariants.internal.reducer.reduceModel(obj.ReductionInfo.getReductionOptions(),obj);
            catch excep
                Simulink.variant.reducer.utils.logException(excep);
                obj.Error=excep;
                obj.clearOutputDir(excep);
            end

        end

        function error=getError(obj)
            error=obj.Error;
        end

        function warnings=getWarnings(obj)
            warnings=num2cell(obj.Warnings);
        end

        function redMdlPath=getReducedModelPath(obj)
            redMdlPath=obj.ReductionInfo.getReducedModelPath();
        end

        function generateReport(obj,summaryData)
            if~obj.ReductionInfo.getReductionOptions().getGenerateSummary()
                return;
            end
            if~isempty(obj.Error)
                return;
            end


            rptName='variantReducerRpt';
            modelName=obj.ReductionInfo.getReducedModelName();
            source=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+variant','+reducer','+summary','@VRedSummary','two_webviews.htmtx');
            destination=obj.ReductionInfo.getReductionOptions().getOutputFolder();
            copyfile(source,destination);

            reportDataObj=getReportDataObjForSummary(obj,summaryData);
            rptgen=Simulink.variant.reducer.summary.VRedSummary(rptName,modelName,reportDataObj);
            fill(rptgen);
            close(rptgen);
            rptview([rptName,filesep,'report.html']);
        end

        function storeMdlAndItsBlks(obj,mdlAndBlk)
            obj.MdlAndItsBlks=mdlAndBlk;
        end

        function logMsg=getReducerLog(obj)
            logMsg='';

            logMsg=append(logMsg,getLogForSFChartWithVarTrans(obj));


            obj.CallbackInfo=slvariants.internal.reducer.getCallbacks(obj.MdlAndItsBlks);
            logMsg=append(logMsg,getMdlCallbackLog(obj));
            logMsg=append(logMsg,getBlkCallbackLog(obj));
            logMsg=append(logMsg,getPortCallbackLog(obj));
            logMsg=append(logMsg,getMaskCallbackLog(obj));

            logMsg=append(logMsg,getFailureLog(obj));

            logMsg=append(logMsg,getWarningLog(obj));
        end

        function[varDeps,success]=getVariableDependenciesForReducedModel(obj,useCache)
            dependencyAnalyser=slvariants.internal.reducer.DependencyAnalyser(...
            obj.ReductionInfo.getReducedModelPath());
            [varDeps,success]=dependencyAnalyser.getVariableDependenciesForReducedModel(useCache);
            obj.Warnings=horzcat(obj.Warnings,dependencyAnalyser.getVariableDependenciesFailures());
        end

        function[varDeps,success]=getVariableDependenciesForBlock(obj,blk,useCache)
            dependencyAnalyser=slvariants.internal.reducer.DependencyAnalyser(...
            obj.ReductionInfo.getReducedModelPath());
            [varDeps,success]=dependencyAnalyser.getVariableDependenciesForBlock(blk,useCache);
            obj.Warnings=horzcat(obj.Warnings,dependencyAnalyser.getVariableDependenciesFailures());
        end

        function[fileDeps,success]=getFileDependencies(obj)
            dependencyAnalyser=slvariants.internal.reducer.DependencyAnalyser(...
            obj.ReductionInfo.getReducedModelPath());
            [fileDeps,success]=dependencyAnalyser.getFileDependencies();
            if success
                obj.Warnings=horzcat(obj.Warnings,dependencyAnalyser.getMissingDependenciesFailures());
            else
                obj.Warnings=horzcat(obj.Warnings,dependencyAnalyser.getFileDependenciesFailures());
            end
        end

        function saveAnnotationInfoBeforeReduction(obj,bdToAutoLytInfo)
            obj.Layouter.saveAnnotationInfoBeforeReduction(bdToAutoLytInfo);
        end

        function layoutGraphs(obj,bdToAutoLytInfo)
            obj.Layouter.layoutGraphs(bdToAutoLytInfo);
        end

        function addModelsForDefaultConfigHandling(obj,models)
            for mdlIdx=1:numel(models)
                obj.ReductionInfo.getEnvironment().addModelForDefaultConfigHandling(models{mdlIdx});
            end
        end

        function setRedBDName2OrigBDNameInfo(obj,redBDName2OrigBDNameMap)
            obj.RedBDName2OrigBDNameMap=redBDName2OrigBDNameMap;
            redBDNames=keys(obj.RedBDName2OrigBDNameMap);
            obj.ReductionInfo.getEnvironment().setReducedBDNames(redBDNames);
        end

        function setCommand(obj,cmd)
            obj.Command=cmd;
        end

        function command=getCommand(obj)
            command=obj.Command;
        end

        function restoreDefaultConfigs(obj)
            obj.ReductionInfo.getEnvironment().resetDefaultConfigs();
        end

        function updateProgressBarMessage(obj,msgId)
            obj.ReductionInfo.getVerboseInfoObj().updateProgressBarMessage(msgId);
        end

        function frInfo=getFullRangeAnalysisInfo(obj)
            frInfo=obj.ConfigHandler().getFullRangeAnalysisInfo();
        end

    end

    properties(Access=private)


        ReductionInfo slvariants.internal.reducer.ReductionInfo;


        RedBDName2OrigBDNameMap;


        Warnings(1,:)MException;


        Error MException;


        ConfigHandler slvariants.internal.reducer.ConfigHandler;


        Layouter slvariants.internal.reducer.Layouter;


        Command(1,:)char;


        MdlAndItsBlks;


        RegexHyperlink='<a\s+href\s*=\s*"[^"]*"[^>]*>(.*?)</a>';


        CallbackInfo;


        SFChartWithVariantTrans;

    end

    methods(Access=private)

        function throwStoredWarnings(obj)
            if obj.ReductionInfo.getVerboseInfoObj().isCalledFromVM()


                return;
            end

            for idx=1:numel(obj.Warnings)


                warning(obj.Warnings(idx).identifier,'%s',obj.Warnings(idx).message);
            end
        end

        function postProcessReduceModelError(obj)
            obj.throwStoredWarnings();



            if isempty(obj.RedBDName2OrigBDNameMap)
                return;
            end



            if isempty(obj.Error)
                return;
            end



            obj.Error=Simulink.variant.reducer.utils.fixErrorToRemoveSuffix(obj.RedBDName2OrigBDNameMap,obj.Error);
        end

        function clearOutputDir(obj,err)


            errIdForNoOutDirDeletion={'Simulink:Variants:OutputDirPublic',...
            'Simulink:VariantReducer:OutputDirInstall',...
            'Simulink:Variants:ReducerCWDUnderOutputDir',...
            'Simulink:Variants:SameSrcAndDstDirs',...
            'Simulink:Variants:ModelPathUnderOutputDir',...
            'Simulink:Variants:OutputDirNotWritable',...
            'Simulink:Variants:ErrRedMdlIsOpen',...
            'Simulink:VariantReducer:ClearOutDirFailed',...
            'Simulink:Variants:ErrRedMdlIsOpen',...
            'Simulink:VariantReducer:ClearOutDirFailed'};
            if isa(err,'MException')&&...
                ~any(strcmp(err.identifier,errIdForNoOutDirDeletion))

                outDir=obj.ReductionInfo.getReductionOptions().getOutputFolder();
                Simulink.variant.reducer.utils.deleteDirectoryContents(outDir,true);
            end
        end

        function reportDataObj=getReportDataObjForSummary(obj,summaryData)
            rOpts=obj.getROptsForSummary();
            reportDataObj=Simulink.variant.reducer.summary.SummaryData(rOpts);
            reportDataObj.BlocksAdded=summaryData.BlocksAdded;
            reportDataObj.BlocksRemoved=summaryData.BlocksRemoved;
            reportDataObj.BlocksModified=summaryData.BlocksModified;
            reportDataObj.MaskedBlocksModified=summaryData.MaskedBlocksModified;
            reportDataObj.VariantVariablesReduced=summaryData.VariantVariablesReduced;
            reportDataObj.VariantVariablesConverted=summaryData.VariantVariablesConverted;
            reportDataObj.FileDependencies=summaryData.FileDependencies;
            reportDataObj.Configurations=obj.ConfigHandler.getConfigsForSummary();
            reportDataObj.Callbacks=obj.CallbackInfo;
            reportDataObj.SFChartContainingVariantTrans=obj.SFChartWithVariantTrans;
            reportDataObj.Warnings=obj.getWarnings();
        end

        function rOpts=getROptsForSummary(obj)
            rOpts.TopModelOrigName=obj.ReductionInfo.getReductionOptions().getModelName();
            rOpts.TopModelName=obj.ReductionInfo.getReducedModelName();
            rOpts.CompileMode=obj.ReductionInfo.getReductionOptions().getCompileMode();
            if slfeature('VRedRearch')>0&&slfeature('VRedExcludeFiles')>0
                rOpts.ExcludeFiles=obj.ReductionInfo.getReductionOptions().getExcludeFiles();
            end
            rOpts.ValidateSignals=obj.ReductionInfo.getReductionOptions().getPreserveSignalAttributes();
            rOpts.Suffix=obj.ReductionInfo.getReductionOptions().getModelSuffix();
            rOpts.GenerateReport=obj.ReductionInfo.getReductionOptions().getGenerateSummary();
            reducedModelPath=getReducedModelPath(obj);
            [outputFolder,~,~]=fileparts(reducedModelPath);
            rOpts.OutputFolder=outputFolder;
            rOpts.VerboseInfoObj=obj.ReductionInfo.getVerboseInfoObj();
            rOpts.FullRangeVariables=obj.ReductionInfo.getFullRangeVariables();
        end

        function logMsg=getLogForSFChartWithVarTrans(obj)

            logMsg='';
            obj.SFChartWithVariantTrans=slvariants.internal.reducer.getSFVariantBlks(obj.MdlAndItsBlks);

            if isempty(obj.SFChartWithVariantTrans)
                return;
            end

            msg=message('Simulink:VariantReducer:VarSFTransNotSupported').getString();
            logMsg=append(logMsg,msg,newline);

            for sfBlkI=1:numel(obj.SFChartWithVariantTrans)
                logMsg=append(logMsg,getfullname(obj.SFChartWithVariantTrans(sfBlkI)),newline);
            end
            logMsg=append(logMsg,newline);
        end

        function logMsg=getAllMsg(obj,msgContainer)
            logMsg='';
            for i=1:numel(msgContainer)
                msg=regexprep(msgContainer(i).message,obj.RegexHyperlink,'$1');
                logMsg=append(logMsg,msg,newline);
            end
        end

        function logMsg=getMdlCallbackLog(obj)

            logMsg='';
            mdlCallbacks=obj.CallbackInfo.mdlCallbacks;
            if isempty(mdlCallbacks)
                return;
            end

            msg=message('Simulink:Variants:ReducerModelCallbackMsg').getString();
            logMsg=append(logMsg,msg,newline);
            for mdlCallbkId=1:numel(mdlCallbacks)
                logMsg=append(logMsg,mdlCallbacks(mdlCallbkId).ModelName,': ',newline);
                logMsg=append(logMsg,obj.getSpecifiedCbLog(mdlCallbacks(mdlCallbkId).Callbacks));
            end
            logMsg=append(logMsg,newline);
        end

        function logMsg=getBlkCallbackLog(obj)

            logMsg='';
            blkCallbacks=obj.CallbackInfo.blkCallbacks;
            if isempty(blkCallbacks)
                return;
            end
            msg=message('Simulink:Variants:ReducerBlockCallbackMsg').getString();
            logMsg=append(logMsg,msg,newline);
            for blkCallbkId=1:numel(blkCallbacks)
                logMsg=append(logMsg,blkCallbacks(blkCallbkId).BlkPaths,': ',newline);
                logMsg=append(logMsg,obj.getSpecifiedCbLog(blkCallbacks(blkCallbkId).Callbacks));
            end
            logMsg=append(logMsg,newline);
        end

        function logMsg=getPortCallbackLog(obj)

            logMsg='';
            portCallbacks=obj.CallbackInfo.portCallbacks;
            if isempty(portCallbacks)
                return;
            end
            msg=message('Simulink:Variants:ReducerPortCallbackMsg').getString();
            logMsg=append(logMsg,msg,newline);
            for portCallbkId=1:numel(portCallbacks)
                logMsg=append(logMsg,portCallbacks(portCallbkId).BlkPaths,': ',newline);
                logMsg=append(logMsg,obj.getSpecifiedCbLog(portCallbacks(portCallbkId).Callbacks));
            end
            logMsg=append(logMsg,newline);
        end

        function logMsg=getMaskCallbackLog(obj)

            logMsg='';
            maskCallbacks=obj.CallbackInfo.maskCallbacks;
            if isempty(maskCallbacks)
                return;
            end
            msg=message('Simulink:Variants:ReducerMaskCallbackMsg').getString();
            logMsg=append(logMsg,msg,newline);
            for maskCallbkId=1:numel(maskCallbacks)
                logMsg=append(logMsg,maskCallbacks(maskCallbkId).BlkPaths,newline);
            end
            logMsg=append(logMsg,newline);
        end

        function logMsg=getFailureLog(obj)

            failureMessageDetails={};

            if isempty(obj.Error)
                logMsg=[message('Simulink:Variants:VariantReducerSuccessDiffModelNames',...
                obj.ReductionInfo.getReducedModelPath()).getString(),newline];
                return;
            end


            if~isempty(obj.Error.cause)
                failureMessageDetails=cell(1,numel(obj.Error.cause));
                for i=1:numel(obj.Error.cause)
                    cause=obj.Error.cause{i};
                    failureMessageDetails{1,i}=cause.message;
                end
            end

            errMsgHeader=message('Simulink:Variants:ReducerLogErrorPrefix').getString();
            logMsg=[errMsgHeader,newline];


            errMsg=regexprep(obj.Error.message,obj.RegexHyperlink,'$1');
            logMsg=append(logMsg,errMsg,newline);

            if isempty(failureMessageDetails)
                return;
            end

            causedBy=message('Simulink:Variants:CausedBy').getString();
            logMsg=append(logMsg,causedBy);
            logMsg=append(logMsg,getAllMsg(obj,failureMessageDetails));
        end

        function logMsg=getWarningLog(obj)

            logMsg='';
            if isempty(obj.Warnings)
                return;
            end

            warnMsgHeader=message('Simulink:Variants:ReducerLogWarningPrefix').getString();
            logMsg=[warnMsgHeader,newline];
            logMsg=append(logMsg,getAllMsg(obj,obj.Warnings));
        end
    end

    methods(Static)

        function logMsg=getSpecifiedCbLog(callbacks)
            logMsg='';
            for callbkId=1:numel(callbacks)
                logMsg=append(logMsg,callbacks{callbkId},newline);
            end
            logMsg=append(logMsg,newline);
        end

    end
end


