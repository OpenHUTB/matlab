



classdef(Sealed)CodeCovProbeComponentRegistry<codeinstrum.internal.codecov.ProbeComponentRegistry

    properties(GetAccess=public,SetAccess=private)
        IsSIL=true
    end

    methods



        function this=CodeCovProbeComponentRegistry(...
            moduleName,...
            instrumOptions,...
            targetWordSize,...
            maxIdLength)

            this=this@codeinstrum.internal.codecov.ProbeComponentRegistry(...
            moduleName,...
            instrumOptions,...
            targetWordSize,...
            maxIdLength);
        end

        function codeCovSetIsSil(this,val)
            this.IsSIL=val;
        end

        function val=codeCovGetIsSil(this)
            val=this.IsSIL;
        end




        function active=isActive(this,SILPILWrapperUtils)
            if~true&&~SILPILWrapperUtils.isSlCovEnabled()
                active=false;
                return
            end

            topModelName=SILPILWrapperUtils.getInstrumentationSettingsModel();
            covSettings=slprivate('getCodeCoverageSettings',topModelName);
            if~strcmpi(covSettings.CoverageTool,SlCov.getCoverageToolName())
                active=false;
                return
            end

            [modelNameFromModule,covMode,isSharedLib]=...
            SlCov.coder.EmbeddedCoder.parseModuleName(this.ComponentName);


            covMode=SlCov.CovMode.fromString(covMode);
            registryIsSIL=covMode==SlCov.CovMode.SIL||...
            covMode==SlCov.CovMode.ModelRefSIL||...
            covMode==SlCov.CovMode.ModelRefTopSIL;

            simulationIsSIL=isSIL(SILPILWrapperUtils.getSILPILInterface);

            if registryIsSIL~=simulationIsSIL

                active=false;
                return
            end

            if isSharedLib
                modelName=getRootModel(getSILPILInterface(SILPILWrapperUtils));
            else

                modelName=modelNameFromModule;
            end
            active=SlCov.CodeCovUtils.isXILCoverageEnabled(...
            topModelName,modelName,simulationIsSIL);







            if active&&~strcmp(topModelName,modelName)&&...
                ~coder.connectivity.XILSubsystemUtils.isSubsystemWorkflow(topModelName)

                args={...
                'KeepModelsLoaded',false,...
                'AllLevels',true,...
                'IncludeProtectedModels',false,...
                'IncludeCommented',false,...
                'FollowLinks',true,...
                'LookUnderMasks','all',...
                'ReturnTopModelAsLastElement',true...
                };

                if slfeature('StartupVariants')>0
                    mdlRefs=find_mdlrefs(topModelName,...
                    'MatchFilter',@Simulink.match.startupVariants,args{:});
                    if ismember(modelName,mdlRefs(1:end-1))

                        return
                    end
                end

                mdlRefs=find_mdlrefs(topModelName,...
                'MatchFilter',@Simulink.match.activeVariants,args{:});
                if~ismember(modelName,mdlRefs(1:end-1))

                    active=false;
                end
            end
        end
    end
end


