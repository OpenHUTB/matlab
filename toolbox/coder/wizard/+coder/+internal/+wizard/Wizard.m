




classdef Wizard<simulinkcoder.internal.wizard.Wizard
    methods
        function env=Wizard(modelName,firstQuestionId)
            if nargin<2
                firstQuestionId='System';
            end
            noGui=true;
            env@simulinkcoder.internal.wizard.Wizard(modelName,firstQuestionId,noGui);
            env.Gui=coder.internal.wizard.Gui(modelName);
            coder.internal.wizard.Wizard.doERTLicenseCheckout();
            env.IsAnalysisDoneBeforeCodegen=true;
        end
        function pushAnswer(env,option_id,answer)
            if env.OptionStack.isKey(option_id)
                o=env.OptionStack(option_id);
                o.setAnswer(answer);
            else
                error(['Option ',option_id,' is not displayed yet.']);
            end
        end
    end
    methods(Hidden)
        function out=apply_postcompile(env)
            env.setupTempDir();
            oc_dir=onCleanup(@()env.removeTempDir);

            warningBt=warning('off','backtrace');
            oc_warnBt=onCleanup(@()warning(warningBt));


            if env.UseModelAdvisor
                q=env.FirstQuestion;
                checkList={};
                while~isempty(q)
                    checkList=[checkList,q.getPostCompileAction()];%#ok<AGROW>
                    prev_q=q;
                    q=q.NextQuestion;
                    if isempty(q)||strcmp(q.Id,prev_q.Id)
                        break;
                    end
                end
                if~isempty(checkList)
                    out=loc_run(env.ModelName,checkList);
                end
            else
                env.runPreCompileChecks();

                protectedMdls=env.runCompile();

                env.runPostCompileChecks(protectedMdls);
            end
        end
        function protectedMdls=runCompile(env)
            q=env.FirstQuestion;
            if strcmp(env.CSM.getParam('SaveOutput'),'on')
                env.CSM.setParamInBaseNonDirty(env.ModelName,'SaveOutput','off');
                restoreSaveOutput=onCleanup(@()env.CSM.setParamInBaseNonDirty(env.ModelName,'SaveOutput','on'));
            end

            feval(env.ModelName,[],[],[],'compile');
            protectedMdls=[];%#ok<NASGU>

            try
                [env.SubModels,protectedMdls]=coder.internal.getUniqueSubModels(env.ModelName);
                env.SupportFlags=coder.internal.getRequiredInterfaceSupportFlags(env.ModelName);



                env.CSM.SubModels=env.SubModels;
                env.HasModelReference=~isempty(env.SubModels);
                env.HasTerminate=coder.internal.modelHasTerminateSS(env.ModelName);


                while~isempty(q)
                    q.onPostCompile();
                    prev_q=q;
                    q=q.NextQuestion;
                    if isempty(q)||strcmp(q.Id,prev_q.Id)
                        break;
                    end
                end
                feval(env.ModelName,[],[],[],'term');
            catch me





                feval(env.ModelName,[],[],[],'term');

                rethrow(me);
            end
        end

        function setAUTOSARModelInterface(env,modelName)
            if env.hasAutosarMapping(modelName)
                return;
            end

            autosar.api.create(modelName,'default');

            env.run_autosar_validation(modelName);
        end

        function setCModelInterface(env,modelName)%#ok<INUSL>
            if coder.internal.isSLXFile(get_param(modelName,'Handle'))&&...
                strcmp(get_param(modelName,'IsERTTarget'),'on')

                Simulink.CodeMapping.doMigrationFromGUI(modelName,false);


                mdlH=get_param(modelName,'Handle');
                coder.internal.CoderDataStaticAPI.createFactoryFunctionClasses(mdlH);
                coder.internal.CoderDataStaticAPI.createExampleStorageClasses(mdlH);
            end
        end

        function constructAndAttachInterface(env)
            if strcmp(env.Flavor,'CppEncap')

                if isempty(env.SourceSubsystem)
                    env.setCppModelInterface(env.ModelName);
                else
                    env.setCppSubsystemInterface();
                end


                for i=1:length(env.SubModels)
                    currentM=env.SubModels{i};
                    wasLoaded=bdIsLoaded(currentM);
                    load_system(currentM);
                    oc=onCleanup(@()coder.internal.wizard.Wizard.closeSystem(currentM,wasLoaded));

                    env.setCppModelInterface(currentM);

                    coder.internal.wizard.Wizard.saveModel(currentM);
                end
            elseif strcmp(env.Flavor,'AUTOSAR')||strcmp(env.Flavor,'AUTOSAR_Adaptive')

                assert(isempty(env.SourceSubsystem),'Not supported');


                env.setAUTOSARModelInterface(env.ModelName);


            elseif strcmp(env.Flavor,'C')
                if isempty(env.SourceSubsystem)
                    env.setCModelInterface(env.ModelName);
                end
            end
        end

        function setCommonSettings(env)
            settings={...
            {'GenerateComments','on'},...
            {'SimulinkBlockComments','on'},...
            {'StateflowObjectComments','off'},...
            {'MATLABSourceComments','off'},...
            {'MATLABFcnDesc','off'},...
            {'ShowEliminatedStatement','on'},...
            {'ForceParamTrailComments','on'},...
            {'InsertBlockDesc','on'},...
            {'SimulinkDataObjDesc','on'},...
            {'MangleLength',1},...
            {'CustomSymbolStrField','$N$M'},...
            {'CustomSymbolStrTmpVar','$N$M'},...
            {'CustomSymbolStrBlkIO','rtb_$N$M'},...
            {'InlinedPrmAccess','Literals'},...
            {'IgnoreCustomStorageClasses','off'},...
            {'GRTInterface','off'},...
            {'CombineOutputUpdateFcns','on'},...
            {'CombineSignalStateStructs','on'},...
            {'PreserveExpressionOrder','off'},...
            {'CheckMdlBeforeBuild','Off'},...
            {'MatFileLogging','off'}...
            };




            if env.doesModelNeedTerminate()
                settings{end+1}={'IncludeMdlTerminateFcn','on'};
            else
                settings{end+1}={'IncludeMdlTerminateFcn','off'};
            end
            if~strcmp(env.Flavor,'AUTOSAR')
                settings{end+1}={'SupportComplex',logicalToString(env.SupportFlags.needsComplex)};









                if env.SupportFlags.needsNonInlinedSFunction
                    settings{end+1}={'SupportNonFinite',logicalToString(env.SupportFlags.needsNonInlinedSFunction)};
                end
                settings{end+1}={'SupportNonInlinedSFcns',logicalToString(env.SupportFlags.needsNonInlinedSFunction)};
            else

                settings{end+1}={'AutoInsertRateTranBlk','off'};
            end




            system=env.ModelName;
            if~isempty(env.SourceSubsystem)
                system=env.SourceSubsystem;
            end
            supportCompactForAUTOSAR=env.supportsCompactAUTOSAR();
            supportCompact=coder.internal.wizard.supportCompactFormat(system);
            if supportCompact&&supportCompactForAUTOSAR
                settings{end+1}={'ERTFilePackagingFormat','CompactWithDataFile'};
            else
                settings{end+1}={'ERTFilePackagingFormat','Modular'};
            end

            if env.HasModelReference
                settings{end+1}={'CustomSymbolStrGlobalVar','$R$N$M'};
                settings{end+1}={'CustomSymbolStrType','$N$R$M_T'};
                settings{end+1}={'CustomSymbolStrFcn','$R$N$M$F'};
                settings{end+1}={'CustomSymbolStrMacro','$R$N$M'};
            else
                settings{end+1}={'CustomSymbolStrGlobalVar','rt$N$M'};
                settings{end+1}={'CustomSymbolStrType','$N$M'};
                settings{end+1}={'CustomSymbolStrFcn','$N$M$F'};
                settings{end+1}={'CustomSymbolStrMacro','$N$M'};
            end

            for i=1:length(settings)
                env.setParamOptional(settings{i}{1},settings{i}{2});
            end



            if~env.SupportFlags.needsContinuousTime&&~env.isSubsystemBuild
                env.setParamRequired('Solver','FixedStepDiscrete');
            end




            if~any(strcmpi(env.Flavor,{'AUTOSAR','AUTOSAR_Adaptive'}))
                if env.isSubsystemBuild


                    env.setParamRequired('SupportContinuousTime',env.HasContinuousTime);
                else
                    env.setParamRequired('SupportContinuousTime',logicalToString(env.SupportFlags.needsContinuousTime));
                end
            end
            env.setParamOptional('SupportAbsoluteTime',logicalToString(env.SupportFlags.needsAbsoluteTime));
            env.setParamOptional('PurelyIntegerCode',logicalToString(~env.SupportFlags.needsFloatingPoint));
            env.setParamOptional('SupportVariableSizeSignals',logicalToString(env.SupportFlags.needsVariableSize));



            if~env.SupportFlags.needsContinuousTime&&env.SupportFlags.needsSuppressErrorStatus
                env.setParamOptional('SuppressErrorStatus','on');
            else
                env.setParamOptional('SuppressErrorStatus','off');
            end
        end

        function out=supportsCompactAUTOSAR(env)
            if strcmp(env.Flavor,'AUTOSAR')&&...
                strcmp(env.getParam('CodeInterfacePackaging'),'Reusable function')
                out=false;
            else
                out=true;
            end
        end

        function out=hasAutosarMapping(env,modelName)
            mgr=get_param(modelName,'MappingManager');
            if strcmp(env.Flavor,'AUTOSAR')
                mapping=mgr.getActiveMappingFor('AutosarTarget');
            elseif strcmp(env.Flavor,'AUTOSAR_Adaptive')
                mapping=mgr.getActiveMappingFor('AutosarTargetCPP');
            else
                assert(false,'Expected AUTOSAR Flavor');
            end
            out=~isempty(mapping);
        end
        function run_autosar_validation(~,modelName)


            assert(any(strcmp(get_param(modelName,'SystemTargetFile'),{'autosar.tlc','autosar_adaptive.tlc'})),'Target not set to autosar');


            autosar.api.validateModel(modelName);



        end
        function runPreCompileChecks(env)


            if strcmpi(env.CSM.getParam('SystemTargetFile'),'ert_shrlib.tlc')
                if~strcmpi(env.Flavor,'C')
                    DAStudio.error('RTW:wizard:ERTShrLibOnlyCompatibleWithC',env.ModelName);
                end
            end


            if~isempty(env.SourceSubsystem)



                if strcmpi(env.Flavor,'CppEncap')

                    try
                        ss_hdl=get_param(env.SourceSubsystem,'Handle');
                        sobj=Simulink.ModelReference.Conversion.ConversionChecks.getConversionCheckObject(ss_hdl);%#ok
                        cmdStr='isConvertible = sobj.checkForError()';
                        checklog=evalc(cmdStr);
                        if~isConvertible
                            DAStudio.error('RTW:buildProcess:ssNotConvertibleToMdlrefCPP',checklog);
                        end
                    catch cpper
                        DAStudio.error('RTW:buildProcess:ssNotConvertibleToMdlrefCPP',cpper.message);
                    end
                end
            end
        end

        function runPostCompileChecks(env,protectedMdls)

            if any(strcmpi(env.Flavor,{'AUTOSAR','AUTOSAR_Adaptive'}))



                if env.UseContinuousSolver||...
                    (env.SupportFlags.needsContinuousTime&&~strcmp(get_param(env.ModelName,'SolverType'),'Variable-step'))
                    DAStudio.error('RTW:wizard:AutosarNotSupportContinuousBlock');
                end
            end


            if strcmpi(env.Flavor,'CppEncap')

                willBeERT=strcmp(env.getParam('SystemTargetFile'),'ert.tlc');
                isCompliant=willBeERT||strcmp(env.getParam('CPPClassGenCompliant'),'on');



                isERT=env.getParam('IsERTTarget');
                if strcmp(isERT,'on')&&~isCompliant
                    DAStudio.error('RTW:wizard:CppNonCompliantTarget',get_param(env.ModelName,'SystemTargetFile'));
                end
            end


            if~isempty(protectedMdls)
                DAStudio.error('RTW:wizard:ProtectedModelsNotSupported');
            end
        end
        function out=hasSLFcns(env)
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
            oc=onCleanup(@()Simulink.CMI.EIAdapter(sess.oldFeatureValue));
            try
                interface=get_param(env.ModelName,'Object');
                out=interface.hasSimulinkFunctions;
            catch
                out=false;
            end
        end
    end
    methods(Hidden)
        function init(env)
            env.QuestionMap=containers.Map;
            env.OptionMap=containers.Map;
            env.QuestionStack=containers.Map;
            env.OptionStack=containers.Map;

            coder.internal.wizard.question.StartWithError(env);
            coder.internal.wizard.question.Start(env);
            coder.internal.wizard.question.System(env);
            coder.internal.wizard.question.Flavor(env);
            coder.internal.wizard.question.Analyze(env);
            coder.internal.wizard.question.Scheduler(env);
            if slfeature('QuickStartProfile')
                coder.internal.wizard.question.MappingProfileCustomization(env);
            end
            coder.internal.wizard.question.Wordsize(env);
            coder.internal.wizard.question.Optimization(env);
            coder.internal.wizard.question.Finish(env);
            coder.internal.wizard.question.ApplyFail(env);
            coder.internal.wizard.question.CodeGenFail(env);
            coder.internal.wizard.question.Additional(env);

            env.updateOption;

        end
    end
    methods(Access=private)
        function needsTerminate=doesModelNeedTerminate(env)

            needsTerminate=env.HasTerminate;
            if strcmp(env.Flavor,'AUTOSAR_Adaptive')



                needsTerminate=needsTerminate||...
                autosar.validation.AdaptiveConfigSetValidator.isModelProvidingService(env.ModelHandle);

            end
        end
    end
    methods(Static)

        function res=isFeatureOn()
            licenses={'MATLAB_Coder','Real-Time_Workshop','RTW_Embedded_Coder'};
            res=true;
            for i=1:length(licenses)
                res=res&&license('test',licenses{i});
            end
            res=res&&...
            dig.isProductInstalled('Embedded Coder')&&...
            dig.isProductInstalled('MATLAB Coder')&&...
            dig.isProductInstalled('Simulink Coder');
        end
        function doERTLicenseCheckout()
            licenses={'Matlab_Coder','Real-Time_Workshop','RTW_Embedded_Coder'};
            for i=1:length(licenses)
                if(builtin('_license_checkout',licenses{i},'quiet')~=0)
                    DAStudio.error('RTW:wizard:CoderLicenseNotAvailable',licenses{i});
                end
            end
        end
    end
end

function out=loc_run(model,checkList)
    out=ModelAdvisor.run(model,...
    checkList,'DisplayResults','none','tempdir','on');
end

function out=logicalToString(val)
    if islogical(val)
        if val
            out='on';
        else
            out='off';
        end
    else
        out=val;
    end
end






