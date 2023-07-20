







classdef(Hidden=true)EmbeddedCoder<coder.coverage.CodeCoverageHook

    properties(Constant=true,Hidden=true)
        ToolNameForPreferences='SimulinkCoverage';
        ValidateToolInstallationFile=codeinstrum.internal.Instrumenter.getToolInstallationFile();
    end

    properties(Access=private)
DbRecordStatus
    end

    methods(Access=public)



        function this=EmbeddedCoder(varargin)
            this.DbRecordStatus=0;

            this.processConstructorArgs(varargin{:});
        end




        function delete(this)
            if this.DbRecordStatus>0


                try
                    this.after_on_target_execution();
                catch
                end
            end
        end





        function checksum=getHookChecksum(this)
            checksum=getHookChecksum@coder.coverage.CodeCoverageHook(this);

            topModelName=this.getTopModelName();
            modelName=this.getModelName();

            if~strcmp(topModelName,modelName)

                enabled=SlCov.CodeCovUtils.isXILCoverageEnabled(topModelName,modelName,...
                this.isSilBuild(),this.isTopModelSil());
                checksum=CGXE.Utils.md5(checksum,enabled);
            end

            if this.getCoverageEnabledForThisComponent()


                instrOpts=this.getInstrumOptions();
                checksum=CGXE.Utils.md5(checksum,...
                sldv.code.internal.isXilFeatureEnabled(),...
                instrOpts.Statement,...
                instrOpts.FunExit,instrOpts.FunEntry,instrOpts.FunCall,...
                instrOpts.RelationalBoundary,instrOpts.ResultsMode,instrOpts.MaxMCDCCombinations);
                if codeinstrumprivate('feature','honorCovLogicBlockShortCircuit')
                    covLogicBlockShortCircuit=strcmpi(get_param(modelName,'CovLogicBlockShortCircuit'),'on');
                    checksum=CGXE.Utils.md5(checksum,covLogicBlockShortCircuit);
                end
            end
        end




        function out=getActualVersion(~)
            v=ver('slcoverage');
            if isempty(v)

                out=codeinstrum.internal.Instrumenter.getActualVersion();
            else
                out=v.Version;
            end
        end




        function error(~)

        end





        function[instrumOptions,modelModuleName]=...
            getInstrumentForCoverageArgs(this)

            instrumOptions=getInstrumOptions(this);
            modelModuleName=getModuleName(this);



            instrumOptions.Decision=true;
            instrumOptions.Condition=true;
            instrumOptions.MCDC=true;
        end





        function before_buildApplication(~,~)
        end




        before_on_target_execution(this)




        after_on_target_execution(this)
    end

    methods(Access=private)





        function mode=getCovModeEnum(this)
            [~,modelRefTargetType]=...
            findBuildArg(this.getOriginalComponentBuildInfo,...
            'MODELREF_TARGET_TYPE');

            if strcmp(modelRefTargetType,'NONE')
                if this.isSilBuild()
                    mode=SlCov.CovMode.SIL;
                else
                    mode=SlCov.CovMode.PIL;
                end
            else
                if this.isSilBuild()
                    mode=SlCov.CovMode.ModelRefSIL;
                else
                    mode=SlCov.CovMode.ModelRefPIL;
                end
            end
        end




        function moduleName=getModuleName(this)
            moduleName=[this.getModelName(),' (',char(this.getCovModeEnum()),')'];
        end





        function instrOpts=getInstrumOptions(this)
            instrOpts=internal.cxxfe.instrum.InstrumOptions();
            instrOpts.ResultsMode=codeinstrumprivate('feature','resultsMode');

            if this.isCvCmdCall()
                modelName=this.getModelName();
                modelCovId=get_param(modelName,'CoverageId');

                if~cv('ishandle',modelCovId)
                    return
                end
                testId=cv('get',modelCovId,'.activeTest');
                if~cv('ishandle',testId)
                    return
                end
                testVar=cvtest(testId);
                opts=SlCov.coder.EmbeddedCoder.getOptionsFromTestVar(testVar);
            else
                topModelName=this.getTopModelName();
                opts=SlCov.coder.EmbeddedCoder.getOptions(topModelName);
            end

            instrOpts.Decision=opts.metrics.decision;
            instrOpts.Condition=opts.metrics.condition;
            instrOpts.MCDC=opts.metrics.mcdc;
            instrOpts.RelationalBoundary=opts.metrics.relationalop;
            instrOpts.RelationalBoundaryAbsTol=opts.covBoundaryAbsTol;
            instrOpts.RelationalBoundaryRelTol=opts.covBoundaryRelTol;
        end




        function res=isCvCmdCall(this)
            topModelName=this.getTopModelName();
            res=strcmpi(get_param(topModelName,'cvsimrefCall'),'on');
        end

    end

    methods(Access=public,Static=true)



        function setPath(~)

        end




        function mwPath=getPath()
            mwPath=codeinstrum.internal.Instrumenter.getToolPath();
        end




        function name=getToolName()
            name=SlCov.getCoverageToolName();
        end




        [refModelNames,refModelHandles,topModelIsSILPIL,hasNormalModeRefModel,modelInfoMap]=...
        getRecordingModels(topModelName,opts,fromCvSim,topModelSimMode)





        moduleNames=getSharedModuleName(covMode,folders)





        [hookModelNames,hookCovModes]=getHookModelNames...
        (lBuildInfo,isSil,lInTheLoopType)






        instrumentationUpToDate=setupInstrumentForCoverage...
        (modelName,instrumentationUpToDate,moduleName,anchorFolder,...
        instrumOptions)






        [lEnableSnifferBuild,filesToInstrumentAll]=instrumentForCoverage...
        (lToolchainInfo,compileBuildOptsInstr,snifferFEOpts,modelName,...
        outDirRelative,filesToInstrument,instrumentationUpToDate,...
        componentName,moduleName,lBuildInfoInstr,buildInfoOriginal,lIsSilBuild,...
        lIsTopModelSil,lIsSilBuildAndPortableWordSizes,...
        instrumOptions,lHookChecksum,lInstrObjFolder)
    end

    methods(Static,Hidden)




        function moduleName=buildModuleName(modelName,covMode)

            moduleName=codeinstrum.internal.codecov.ModuleUtils.buildModuleName(...
            false,modelName,char(covMode));
        end




        function[modelNameOrRelBuildDir,covMode,isSharedUtils,isMATLAB]=parseModuleName(moduleName)
            [modelNameOrRelBuildDir,covMode,isSharedUtils,isMATLAB]=...
            codeinstrum.internal.codecov.ModuleUtils.parseModuleName(moduleName);
        end




        function[trDataFile,resHitsFile,buildDir,isSharedUtils,isMATLAB]=getCodeCovDataFiles(moduleName,varargin)
            [trDataFile,resHitsFile,buildDir,isSharedUtils,isMATLAB]=...
            codeinstrum.internal.codecov.ModuleUtils.getCodeCovDataFiles(...
            moduleName,varargin{:});
        end




        function varargout=getCodeCovDataFilesDuringBuild(moduleName,...
            modelName,anchorFolder)




            buildDirInfo=RTW.getBuildDir(modelName);
            buildDirInfo.CodeGenFolder=anchorFolder;

            [varargout{1:nargout}]=...
            SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName,...
            buildDirInfo);
        end




        function opts=getOptions(modelName)
            opts=SlCov.CovSettings(modelName);
        end




        function opts=getOptionsFromTestVar(testVar)
            metrics=struct('decision',testVar.settings.decision,...
            'condition',testVar.settings.condition,...
            'mcdc',testVar.settings.mcdc,...
            'relationalop',testVar.settings.relationalop);
            opts=struct('recordCoverage',~testVar.modelRefSettings.excludeTopModel,...
            'modelRefEnable',~strcmpi(testVar.modelRefSettings.enable,'off'),...
            'covModelRefEnable',testVar.modelRefSettings.enable,...
            'covModelRefExcluded',testVar.modelRefSettings.excludedModels,...
            'metrics',metrics,...
            'covBoundaryAbsTol',testVar.options.covBoundaryAbsTol,...
            'covBoundaryRelTol',testVar.options.covBoundaryRelTol,...
            'covUseTimeInterval',logical(testVar.options.useTimeInterval),...
            'covStartTime',testVar.options.intervalStartTime,...
            'covStopTime',testVar.options.intervalStopTime);
        end

    end

    methods(Static)
        function name=getName()
            name='SimulinkCoverage';
        end
        function name=getDisplayName()
            name=SlCov.getCoverageToolName();
        end
    end

end



