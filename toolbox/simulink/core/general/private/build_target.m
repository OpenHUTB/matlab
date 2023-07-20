function varargout=build_target(iSubFcn,varargin)





    [varargout{1:nargout}]=feval(iSubFcn,varargin{1:end});





    function Setup(iMdl,iBuildState,iBuildArgs)
        iBuildState.mModel=iMdl;
        iBuildState.mMdlsToClose=load_model(iMdl);

        if slfeature('ConfigSetActivator')>0
            if~isempty(iBuildArgs.ConfigSetActivator)
                if~isequal(iMdl,iBuildArgs.TopOfBuildModel)
                    iBuildArgs.ConfigSetActivator.activate(iMdl);
                end
            end
        end
        iBuildState.ConfiguredForProtectedModel=false;
        iBuildState.buildResult=[];



        iBuildState.mCurrentSystem=saveAndSetPrm(0,'CurrentSystem',iMdl);


        iBuildState.mWarning=[warning;warning('query','backtrace')];
        warning off backtrace;




        if strcmp(iMdl,iBuildArgs.TopOfBuildModel)&&...
            strcmp(iBuildArgs.ModelReferenceTargetType,'NONE')&&...
            Simulink.ModelReference.ProtectedModel.protectingModel(iBuildArgs.TopOfBuildModel)
            build_target('protectedModelCreatorSetup',iBuildState,iBuildArgs.TopOfBuildModel);
        end



        if(strcmp(iMdl,iBuildArgs.TopOfBuildModel)&&...
            ~Simulink.ModelReference.ProtectedModel.protectingModel(iBuildArgs.TopOfBuildModel)&&...
            strcmp(get_param(iMdl,'UpdateModelReferenceTargets'),'AssumeUpToDate')&&...
            strcmpi(get_param(iMdl,'CheckModelReferenceTargetMessage'),'none'))
            minfo=coder.internal.infoMATFileMgr('load','minfo',iMdl,iBuildArgs.ModelReferenceTargetType);
            builtin('_unpackSLCacheSIMSubModels',iMdl,false,minfo.modelRefs);
        end





        function protectedModelCreatorSetup(iBuildState,topOfBuildModel)



            if~isempty(topOfBuildModel)&&...
                Simulink.ModelReference.ProtectedModel.protectingModel(topOfBuildModel)

                iBuildState.preserve_dirty=Simulink.PreserveDirtyFlag(iBuildState.mModel,'blockDiagram');
                pmCreator=get_param(topOfBuildModel,'ProtectedModelCreator');
                pmCreator.configModel(iBuildState.mModel);
                iBuildState.ConfiguredForProtectedModel=true;
            end




            function protectedModelCreatorCleanup(iBuildState,topOfBuildModel)
                if iBuildState.ConfiguredForProtectedModel

                    pmCreator=get_param(topOfBuildModel,'ProtectedModelCreator');
                    pmCreator.restoreModel(iBuildState.mModel);
                    delete(iBuildState.preserve_dirty);
                end





                function Cleanup(iBuildState,iBuildArgs)

                    warning(iBuildState.mWarning);




                    try
                        restorePrm(iBuildState.mCurrentSystem);
                    catch exc %#ok
                    end

                    if strcmp(iBuildState.mModel,iBuildArgs.TopOfBuildModel)&&...
                        strcmp(iBuildArgs.ModelReferenceTargetType,'NONE')
                        build_target('protectedModelCreatorCleanup',iBuildState,iBuildArgs.TopOfBuildModel);
                    end

                    close_models(iBuildState.mMdlsToClose);




                    function unlockLibraryBDIfNecessary(iBuildArgs,iLib)
                        if iBuildArgs.LibraryBuild
                            if strcmp(get_param(iLib,'Lock'),'on')
                                set_param(iLib,'Lock','off');
                            end
                        end




                        function[buildResult,mainObjFolder]=RunBuildCmd(iMdl,iBuildArgs,varargin)

                            buildResult=[];
                            mainObjFolder='';

                            unlockLibraryBDIfNecessary(iBuildArgs,iMdl);
                            Simulink.BuildInProgress(iMdl);


                            iBuildArgs.DispHook={@Simulink.output.info};


                            hTflControl=get_param(iMdl,'TargetFcnLibHandle');
                            hTflControl.resetUsageCounts();

                            isCustomMakeCmd=strcmp(get_param(iMdl,'GenerateMakefile'),'on')&&...
                            ~strcmp(strtok(get_param(iMdl,'MakeCommand')),'make_rtw')&&...
                            ~isequal(iBuildArgs.ModelReferenceTargetType,'SIM');

                            ts=clock();
                            if~isCustomMakeCmd
                                if iBuildArgs.LibraryBuild
                                    rtwprivate('libgencode',iMdl,...
                                    iBuildArgs.BaDefaultCompInfo);
                                else
                                    [buildResult,mainObjFolder]=...
                                    coder.internal.ModelBuilder.make_rtw(iBuildArgs,iMdl,varargin{:});
                                end
                            else

                                [buildCmdFcn,buildCmdArgs]=coder.internal.getBuildCmdNonSimTarget(iMdl);


                                if strncmp(buildCmdFcn,'make_',5)
                                    buildCmdArgs=['mdl:',iMdl,' ',buildCmdArgs];
                                end


                                if~any(exist(buildCmdFcn,'file')==[6,2])
                                    beep;
                                    DAStudio.error('Simulink:utility:commandNotFound',buildCmdFcn);
                                end

                                feval(buildCmdFcn,iBuildArgs,buildCmdArgs);
                            end
                            tf=clock();

                            if(~isempty(buildResult)&&...
                                isfield(buildResult,'codeWasUpToDate')&&...
                                ~buildResult.codeWasUpToDate)
                                buildStats=rtwprivate('buildStats',ts,tf);
                                coder.internal.infoMATFileMgr('setBuildStats','binfo',iMdl,...
                                iBuildArgs.ModelReferenceTargetType,buildStats);
                            end


                            iBuildArgs.BuildSummary.updateAction(iMdl,iBuildArgs.ModelReferenceTargetType,buildResult);





