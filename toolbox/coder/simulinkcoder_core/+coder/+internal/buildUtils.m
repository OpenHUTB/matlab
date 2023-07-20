






function varargout=buildUtils(method,varargin)
    [varargout{1:nargout}]=feval(method,varargin{1:end});


    function SetSolverToFixStepSolver(mdlHdl)
        mdl_solver=get_param(mdlHdl,'Solver');
        fixstep_solver=MapVariableSolverToFixStepSolver(mdl_solver);
        if~isempty(fixstep_solver)
            set_param(mdlHdl,'Solver',fixstep_solver);
        end



        function out=MapVariableSolverToFixStepSolver(mdl_solver)
            out='';
            vstep_solver={...
            'VariableStepAuto','ode45','ode23','ode113','ode15s','ode23s','ode23t','ode23tb',...
            'VariableStepDiscrete'};
            fstep_solver={...
            'FixedStepAuto','ode5','ode3','ode3','ode5','ode3','ode3','ode3',...
            'FixedStepDiscrete'};
            solver_num=ismember(vstep_solver,mdl_solver);
            if any(solver_num)
                out=fstep_solver{solver_num};
            end




            function retVal=HasTargetVariableStepSolverSupport(mdlHdl)
                retVal=any(strcmp(get_param(mdlHdl,'SystemTargetFile'),...
                {'rsim.tlc','rtwsfcn.tlc'}));



                function isUsingERT=IsUsingERT(model)

                    ertSTF='ert.tlc';
                    currentSTF=get_param(model,'SystemTargetFile');
                    isUsingERT=strncmp(currentSTF,ertSTF,length(ertSTF));



                    function SetupModelForSFunctionGeneration(mdlHdl,useERT)
                        cs=getActiveConfigSet(mdlHdl);
                        newTarget=false;
                        includeCustomSrc=contains(get_param(cs,'TLCOptions'),'-aAlwaysIncludeCustomSrc=1');
                        if useERT
                            if~IsUsingERT(mdlHdl)
                                settings.GenerateReport=get_param(cs,'GenerateReport');
                                settings.TemplateMakefile='ert_default_tmf';
                                cs.switchTarget('ert.tlc',settings);
                                newTarget=true;
                                set_param(cs,'GenerateReport',settings.GenerateReport);
                                set_param(cs,'SupportContinuousTime','on');
                                set_param(cs,'SupportNonInlinedSFcns','on');
                            end
                            cs.setProp('CreateSILPILBlock','SIL');
                            if~HasTargetVariableStepSolverSupport(mdlHdl)
                                SetSolverToFixStepSolver(mdlHdl);
                            end
                        else
                            if~strcmp(get_param(mdlHdl,'SystemTargetFile'),'rtwsfcn.tlc')
                                settings.TemplateMakefile='rtwsfcn_default_tmf';
                                settings.TLCOptions='';
                                if contains(get_param(mdlHdl,'RTWMakeCommand'),'make_rtw')
                                    settings.MakeCommand=get_param(mdlHdl,'RTWMakeCommand');
                                else
                                    settings.MakeCommand='make_rtw';
                                end


                                opt=cs.get_param('RTWCompilerOptimization');
                                cs.switchTarget('rtwsfcn.tlc',settings);
                                cs.set_param('RTWCompilerOptimization',opt);
                                newTarget=true;
                            end
                            set_param(mdlHdl,'DefaultParameterBehavior','Inlined');


                            portH=find_system(mdlHdl,'FindAll','on','LookUnderMasks','all',...
                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                            'Regexp','on','type','port',...
                            'RTWStorageClass','^[^A]');
                            for i=1:length(portH)
                                set_param(portH(i),'RTWStorageClass','Auto');
                                set_param(portH(i),'RTWStorageTypeQualifier','');
                            end
                            set_param(mdlHdl,'IgnoreCustomStorageClasses','on');
                        end
                        if newTarget
                            hardware=cs.getComponent('Hardware Implementation');





                            slprivate('setHardwareDevice',hardware,'Target','MATLAB Host');

                            if includeCustomSrc
                                TLCOptions=get_param(mdlHdl,'TLCOptions');
                                TLCOptions=strcat(TLCOptions,' -aAlwaysIncludeCustomSrc=1');
                                set_param(mdlHdl,'TLCOptions',TLCOptions);
                            end
                        end
                        set_param(mdlHdl,'GenerateMakefile','on');
                        set_param(mdlHdl,'RTWGenerateCodeOnly','off');
                        set_param(mdlHdl,'SaveOutput','off');
                        set_param(mdlHdl,'SaveState','off');
                        set_param(mdlHdl,'SaveTime','off');
                        set_param(mdlHdl,'SaveFinalState','off');





                        function SaveSInfo(mdlHdl,blkHdl,buildDir)


                            if nargin<3
                                buildDir=rtwprivate('rtwattic','getBuildDir');
                                rtwprivate('rtwattic','setBuildDir','');
                            end
                            if ischar(blkHdl)&&~contains(blkHdl,'/')

                                blkSID=blkHdl;
                            else
                                blkSID=Simulink.ID.getSID(blkHdl);
                            end
                            blkPath=getfullname(blkHdl);
                            blkMdl=strtok(blkPath,'/');
                            if ischar(mdlHdl)
                                modelName=mdlHdl;
                            else
                                modelName=get_param(mdlHdl,'Name');
                            end

                            folders=Simulink.filegen.internal.FolderConfiguration(blkMdl);
                            matFileDir={folders.CodeGeneration.absolutePath('ModelReferenceCode'),'tmwinternal'};

                            rtwprivate('rtw_create_directory_path',matFileDir{:});
                            matFileName=fullfile(matFileDir{:},'sinfo.mat');
                            if exist(matFileName,'file')
                                infoStruct=load(matFileName);
                                infoStruct=infoStruct.infoStruct;
                                subsystems=infoStruct.Subsystems;
                                if isempty(subsystems)
                                    index=1;
                                else
                                    [~,index]=ismember(blkPath,{subsystems.BlockPath});
                                    if index==0
                                        index=length(subsystems)+1;
                                    end
                                end
                            else
                                index=1;
                            end

                            infoStruct.Subsystems(index).BlockPath=blkPath;
                            infoStruct.Subsystems(index).BlockSID=blkSID;
                            infoStruct.Subsystems(index).TmpMdlName=modelName;
                            infoStruct.Subsystems(index).buildDir=buildDir;
                            infoStruct.Subsystems(index).TimeStamp=rtwprivate('getFileTimeStamp',buildDir);
                            save(matFileName,'infoStruct');




