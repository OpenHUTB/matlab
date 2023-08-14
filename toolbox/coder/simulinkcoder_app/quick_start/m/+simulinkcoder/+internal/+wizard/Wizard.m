



classdef Wizard<handle
    properties
QuestionMap
OptionMap
        QuestionTopics={}
        QuestionStack={}
        OptionStack={}
        CurrentQuestion=[]
        FirstQuestionId=''
        MaxHeight=0
        ModelHandle=''
        FileName=''
        SubModels={}
        SourceSubsystemHandle=[]
        BuildMode=simulinkcoder.internal.wizard.BuildMode.TOPMODELBUILD
        NonEmptySubsys={}
        RefBlocks={}
        Debug=false
Gui
        ModelSampleTime=[]
        SubsystemSampleTime=[]
        HasContinuousTime=false
        UseContinuousSolver=false
        ExportedFunctionCalls=false
        Deployment=''
        Solver=''
BuildDir
        HasModelReference=[];
        HasTerminate=false
        Flavor='';
        AutosarWizardHdl=[];
        IsCodeGenReady=false;

CSM
        UseModelAdvisor=false
        MultiInstance=[]
        PreserveParameter=false
        PreserveNamedSignal=false

        IsAnalysisDoneBeforeCodegen=false;
    end
    properties(Transient=true)
        TestStatusList={}
LastAnswer
GuiEntry
AnalysisTimeStamp


tmpBuildFolder
addedPath
oldFileGenCfg
SupportFlags
    end

    methods
        function env=Wizard(modelName,firstQuestionId,noGui)
            if nargin<2
                firstQuestionId='Start';
            end
            if nargin<3
                noGui=false;
            end
            env.ModelHandle=simulinkcoder.internal.wizard.Wizard.getModelHandle(modelName);
            simulinkcoder.internal.wizard.Wizard.doGRTLicenseCheckout();

            env.FileName=get_param(modelName,'FileName');
            if~noGui

                env.Gui=simulinkcoder.internal.wizard.Gui(modelName);
            end
            env.FirstQuestionId=firstQuestionId;
            env.CSM=simulinkcoder.internal.wizard.ConfigSetManager(env.ModelName);
            env.GuiEntry=true;
        end
        function out=ModelName(env)
            out='';
            if~isempty(env.ModelHandle)
                out=get_param(env.ModelHandle,'Name');
            end
        end
        function out=SourceSubsystem(env)
            out='';
            if~isempty(env.SourceSubsystemHandle)
                out=getfullname(env.SourceSubsystemHandle);
            end
        end

        function registerQuestion(env,q)
            env.QuestionMap(q.Id)=q;
            if~isempty(q.Topic)&&~ismember(q.Topic,env.QuestionTopics)
                env.QuestionTopics{end+1}=q.Topic;
            end
        end

        function registerOption(env,o)
            env.OptionMap(o.Id)=o;
        end
        function out=getOptionAnswer(env,option_id)
            out=-1;
            if env.OptionMap.isKey(option_id)
                o=env.OptionMap(option_id);
                out=o.Answer;
            end
        end
        function out=getOptionList(env,question_id)
            if env.QuestionMap.isKey(question_id)
                out=env.QuestionMap(question_id).Options;
            else
                error([question_id,' is not in question map.']);
            end
        end
        function out=getOptionParam(env,option_id)
            tmp=env.OptionMap(option_id);
            out=tmp.MsgParam;
        end
        function out=getOption(env,option_id)
            out=env.OptionMap(option_id);
        end
        function out=getNextQuestionId(env,option_id)
            if env.OptionMap.isKey(option_id)
                tmp=env.OptionMap(option_id);
                out=tmp.NextQuestion_Id;
            else
                error([option_id,' has not been registered in OptionMap']);
            end
        end
        function reset(env)
            env.init();
            env.updateHeight();
        end
        function deleteOption(env,option_id)
            if env.OptionStack.isKey(option_id)
                o=env.OptionStack(option_id);
                env.OptionStack.remove({option_id});
                o.delete;
            end
        end
        function out=getQuestionObj(env,question_id)
            out=[];
            if env.QuestionStack.isKey(question_id)
                out=env.QuestionStack(question_id);
            elseif env.QuestionMap.isKey(question_id)
                out=env.QuestionMap(question_id);
            end
        end
        function out=getOptionObj(env,option_id)
            out=[];
            if env.OptionStack.isKey(option_id)
                out=env.OptionStack(option_id);
            elseif env.OptionMap.isKey(option_id)
                out=env.OptionMap(option_id);
            end
        end
        function prev_q=moveToPreviousQuestion(env)
            q=env.CurrentQuestion;
            if~isempty(q)
                if isempty(q.PreviousQuestionId)
                    env.CurrentQuestion=[];
                else
                    env.CurrentQuestion=env.QuestionMap(q.PreviousQuestionId);
                end
            end
            prev_q=env.CurrentQuestion;
        end
        function next_q=moveToNextQuestion(env)
            q=env.CurrentQuestion;
            next_q=[];
            if~isempty(q)
                next_q=q.getNextQuestion();
                if~isempty(next_q)
                    q.NextQuestionId=next_q.Id;


                    if~strcmp(next_q.Id,q.Id)
                        next_q.PreviousQuestionId=q.Id;
                    end
                    env.CurrentQuestion=next_q;
                end
            end
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
        function updateOption(env)

            questions=env.QuestionMap.keys;
            for i=1:length(questions)
                q=questions{i};
                option=env.QuestionMap(q).Options;
                for j=1:length(option)
                    option{j}.Question_Id=q;
                end
            end
        end
        function updateTopics(env)
            questions=env.QuestionMap.keys;
            for i=1:length(questions)
                q=questions{i};
                env.registerQuestion(q);
            end
        end
        function out=updateHeight(env,question_id)
            if nargin<2
                question_id=env.FirstQuestionId;
            end
            q=env.getQuestionObj(question_id);
            option=env.getOptionList(question_id);
            max_child_height=-1;
            if isempty(option)
                out=0;
            else
                for i=1:length(option)
                    nextQ=env.getNextQuestionId(option{i}.Id);
                    child_height=env.updateHeight(nextQ);
                    if max_child_height<child_height
                        max_child_height=child_height;
                    end
                end
                out=max_child_height+1;
            end
            if~q.CountInProgress

                out=out-1;
            end
            tmp=env.QuestionMap(question_id);
            tmp.Height=out;
            env.QuestionMap(question_id)=tmp;
            env.MaxHeight=max(env.MaxHeight,out);
        end
        function out=getHeight(env,question_id)
            q=env.QuestionMap(question_id);
            out=q.Height;
        end
        function onNext(env)
            q=env.CurrentQuestion;
            try
                q.onNext();
            catch e
                env.handle_error(e);
                env.Gui.back;
            end
        end
        function handle_error(env,e)
            stageName=message('RTW:wizard:GenerateCodeStage').getString;
            myStage=Simulink.output.Stage(stageName,'ModelName',env.ModelName,'UIMode',env.GuiEntry);
            Simulink.output.error(e);
            myStage.delete;
        end
        function handle_warning(env,e)
            stageName=message('RTW:wizard:GenerateCodeStage').getString;
            myStage=Simulink.output.Stage(stageName,'ModelName',env.ModelName,'UIMode',env.GuiEntry);
            Simulink.output.warning(e);
            myStage.delete;
        end

        function listOfPaths=getRequiredPaths(~)
            cacheFolder=Simulink.fileGenControl('getInternalValue','CacheFolder');
            codeGenFolder=Simulink.fileGenControl('getInternalValue','CodeGenFolder');
            listOfPaths={cacheFolder,codeGenFolder,pwd};
        end
        function addRequiredPaths(env,listOfPaths)
            for i=1:length(listOfPaths)
                currentPath=listOfPaths{i};
                pathCell=regexp(path,pathsep,'split');
                if~ismember(currentPath,pathCell)



                    wstate=warning('off');
                    warningCleanup=onCleanup(@()warning(wstate));
                    addpath(currentPath);
                    env.addedPath{end+1}=currentPath;
                end
            end
            env.addedPath{end+1}=listOfPaths{end};
        end

        function out=createTempFolder(env)
            env.tmpBuildFolder=tempname;
            mkdir(env.tmpBuildFolder);
            out=env.getRequiredPaths();




            cd(env.tmpBuildFolder);
        end
        function setupTempDir(env)
            listOfPaths=env.createTempFolder();




            env.oldFileGenCfg=Simulink.fileGenControl('getConfig');
            env.oldFileGenCfg.CacheFolder=Simulink.fileGenControl('getInternalValue','CacheFolder');
            env.oldFileGenCfg.CodeGenFolder=Simulink.fileGenControl('getInternalValue','CodeGenFolder');

            Simulink.fileGenControl('set','CacheFolder',env.tmpBuildFolder,...
            'CodeGenFolder',env.tmpBuildFolder);

            env.addRequiredPaths(listOfPaths);
        end
        function removeTempDir(env)
            cd(env.addedPath{end});
            slprivate('removeDir',env.tmpBuildFolder);


            Simulink.fileGenControl('setConfig','Config',env.oldFileGenCfg);

            if~isempty(env.addedPath)
                for i=1:length(env.addedPath)-1
                    wstate=warning('off');
                    warningCleanup=onCleanup(@()warning(wstate));
                    rmpath(env.addedPath{i});
                end
                env.addedPath={};
            end
        end
        function out=start(env)
            env.init();
            out=env.getQuestionObj(env.FirstQuestionId);
            env.CurrentQuestion=out;
        end
        function out=FirstQuestion(env)
            if env.QuestionMap.isKey(env.FirstQuestionId)
                out=env.QuestionMap(env.FirstQuestionId);
            else
                out=env.start;
            end
        end

        function[success,me]=makeChangesToAllModels(env)
            me=[];
            try

                env.CSM.applyChanges();


                env.constructAndAttachInterface();

                success='success';
            catch me
                success='applyfail';
                env.revertConfigSet(true);
            end
        end

        function runAnalysisWithoutCompile(env)


            refMdls=find_mdlrefs(env.ModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            env.SubModels=refMdls(1:end-1);
            env.CSM.SubModels=env.SubModels;
            env.HasModelReference=~isempty(env.SubModels);
        end


        function success=applyAndGenerate(env)
            if~env.IsAnalysisDoneBeforeCodegen

                env.runAnalysisWithoutCompile();
            end

            success=env.applyChanges();
            if~strcmp(success,'applyfail')
                success=env.generateCode();
            end
        end
        function success=applyChanges(env)

            warningBt=warning('off','backtrace');
            oc_warnBt=onCleanup(@()warning(warningBt));

            try
                stageName=message('RTW:wizard:GenerateCodeStage').getString;
                myStage=Simulink.output.Stage(stageName,'ModelName',env.ModelName,'UIMode',env.GuiEntry);




                [success,me]=env.makeChangesToAllModels();

                if~isempty(me)
                    throw(me);
                end
                myStage.delete;
            catch me

                success='applyfail';
                Simulink.output.error(me);

                myStage.delete;
            end
        end




        function success=generateCode(env)

            if isempty(env.SourceSubsystemHandle)
                system=env.ModelName;
            else
                system=env.SourceSubsystem;
            end
            env.BuildDir=pwd;


            warningBt=warning('off','backtrace');
            oc_warnBt=onCleanup(@()warning(warningBt));

            try
                stageName=message('RTW:wizard:GenerateCodeStage').getString;
                myStage=Simulink.output.Stage(stageName,'ModelName',env.ModelName,'UIMode',env.GuiEntry);





                env.CSM.setParamInBaseNonDirty(env.ModelName,'LaunchReport','off');
                restoreLaunchReport=onCleanup(@()env.CSM.setParamInBaseNonDirty(env.ModelName,'LaunchReport','on'));


                origGenCodeOnly=get_param(env.ModelName,'GenCodeOnly');
                env.CSM.setParamInBaseNonDirty(env.ModelName,'GenCodeOnly','on');
                restoreGenCodeOnly=onCleanup(@()env.CSM.setParamInBaseNonDirty(env.ModelName,'GenCodeOnly',origGenCodeOnly));




                sid=Simulink.ID.getSID(system);
                if env.ExportedFunctionCalls
                    slInternal('genCodeFromApp',sid,'Mode','ExportFunctionCalls');
                else
                    slInternal('genCodeFromApp',sid);
                end
                success='success';
                myStage.delete;
            catch me

                me_opt=env.translateError(me);

                Simulink.output.error(me_opt);
                success='codegenfail';


                myStage.delete;
            end
        end


        function out=translateError(~,me)
            switch(me.identifier)
            case 'Simulink:Engine:ExportFcnsMode_AbsoluteTimeNotSupported'
                msg=message('RTW:wizard:ExportFcnAbsTimeIncompatible');
                out=MException(msg);
                out.addCause(me);
            otherwise
                out=me;
            end
        end

        function setCppSubsystemInterface(env)




            openSystems=find_system('SearchDepth',0);



            ocSystems=onCleanup(@()loc_closeOpenedModels(openSystems));

            [errMsg,~]=coder.internal.configFcnProtoSSBuild(env.SourceSubsystem,[],'CreateNoUI');
            if~isempty(errMsg)
                DAStudio.error('RTW:fcnClass:ssConfigureFailed',errMsg);
            end
        end

        function out=isSubModel(env,modelName)
            out=~isempty(intersect(env.SubModels,modelName));
        end

        function setCppModelInterface(env,modelName)



            fcnClass=RTW.getClassInterfaceSpecification(modelName);
            usesCppMapping=Simulink.CodeMapping.isMappedToCppERTSwComponent(modelName);
            if isempty(fcnClass)||env.isSubModel(modelName)



                multiRate=env.isMultiRate();
                isMultiTasking=(strcmp(env.getParam('SolverMode'),'MultiTasking')||...
                strcmp(env.getParam('SolverMode'),'Auto'))&&...
                multiRate;
                if~env.HasModelReference&&isMultiTasking
                    cppDefaultClass=RTW.ModelCPPDefaultClass;
                elseif env.HasModelReference&&~isMultiTasking
                    cppDefaultClass=RTW.ModelCPPArgsClass;
                elseif env.HasModelReference&&isMultiTasking



                    DAStudio.error('RTW:wizard:CppMultiRateModelReference');
                else
                    cppDefaultClass=RTW.ModelCPPDefaultClass;
                end


                attachToModel(cppDefaultClass,modelName);


                getDefaultConf(cppDefaultClass);
                fcnClass=cppDefaultClass;
            end
            if usesCppMapping
                set_param(modelName,'RTWCppFcnClass',fcnClass);
                hModel=get_param(modelName,'Handle');
                [status,validationMessage]=coder.dictionary.internal.runCppValidation(hModel);
            else
                [status,validationMessage]=runValidation(fcnClass);
            end

            if~status
                DAStudio.error('RTW:wizard:CppValidationError',validationMessage);
            end

        end


        function multiRate=isMultiRate(env)
            if env.isSubsystemBuild
                sampleTime=env.SubsystemSampleTime;
            else
                sampleTime=env.ModelSampleTime;
            end
            if~isempty(sampleTime)
                multiRate=~sampleTime.SingleRate;
            else
                multiRate=false;
            end
        end

        function setCModelInterface(env,modelName)
            if coder.internal.isSLXFile(get_param(modelName,'Handle'))
                Simulink.CodeMapping.doMigrationFromGUI(modelName,false);
                modelH=get_param(modelName,'handle');
                if env.featureEnablePreserveData&&env.PreserveNamedSignal
                    simulinkcoder.internal.util.CanvasElementSelection.syncNamedSignals(modelH);

                    cm=coder.mapping.api.get(modelName);
                    sigNames=find(cm,'Signals','StorageClass','Auto');
                    if~isempty(sigNames)
                        setSignal(cm,sigNames,'StorageClass','Model default');
                    end
                end
                if env.featureEnablePreserveData&&env.PreserveParameter

                    cm=coder.mapping.api.get(modelName);
                    prmNames=find(cm,'ModelParameters','StorageClass','Auto');
                    prmArgNames=find(cm,'ModelParameterArguments','StorageClass','Auto');
                    prmNames=[prmNames,prmArgNames];
                    if~isempty(prmNames)
                        setModelParameter(cm,prmNames,'StorageClass','Model default');
                    end
                end
                if strcmp(get_param(modelName,'IsERTTarget'),'on')

                    mdlH=get_param(modelName,'Handle');
                    coder.internal.CoderDataStaticAPI.createFactoryFunctionClasses(mdlH);
                    coder.internal.CoderDataStaticAPI.createExampleStorageClasses(mdlH);
                end
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
                    oc=onCleanup(@()simulinkcoder.internal.wizard.Wizard.closeSystem(currentM,wasLoaded));

                    env.setCppModelInterface(currentM);

                    simulinkcoder.internal.wizard.Wizard.saveModel(currentM);
                end
            elseif strcmp(env.Flavor,'C')
                if isempty(env.SourceSubsystem)
                    env.setCModelInterface(env.ModelName);
                end
            end
        end

        function open_report(env)
            if rtwprivate('rtwinbat')
                disp('# Code Generation Report is not launched in BaT or during test execution. The report will be launched in internal browser.');
                return
            end
            rtw.report.open(env.ModelName);
        end
        function out=getSummary(env)
            out='';
            q=env.FirstQuestion;
            while~isempty(q)
                str=q.getSummary();
                if~isempty(str)
                    out=[out,q.getSummary(),'<br/>'];%#ok<AGROW>
                end


                prev_q=q;
                q=q.NextQuestion;
                if isempty(q)||strcmp(q.Id,prev_q.Id)
                    break;
                end
            end
            if~isempty(env.Deployment)
                switch(env.Deployment)
                case 'SingleRate'
                    str='Singlerate regular build';
                case 'MultiRateSingleCore'
                    str='Multirate regular build';
                case 'MultiRateMultiCore'
                    str='Multirate build with concurrent execution';
                case 'ExportedFunctionCalls'
                    str='exported-function build';
                end
                out=[out,'<br/>',message('RTW:wizard:BestDeployment').getString,str];
            end
        end
        function setParamRequired(env,name,value)
            env.CSM.setParamRequired(name,value);
        end
        function setParamOptional(env,name,value)
            env.CSM.setParamOptional(name,value);
        end
        function out=getParam(env,name)
            out=env.CSM.getParam(name);
        end


        function revertConfigSet(env,varargin)
            if nargin==2
                keepQuickStartState=varargin{1};
            else
                keepQuickStartState=false;
            end
            env.CSM.revertConfigSet(keepQuickStartState);
            if~keepQuickStartState
                env.QuestionTopics={};
                env.reset;
            end
        end
        function[comp,params,oldValue,newValue]=getConfigChange(env)
            newTarget=env.CSM.getParam('SystemTargetFile');
            oldTarget=get_param(env.CSM.getOldConfigSet(env.ModelName),'SystemTargetFile');
            oldCS=env.CSM.getOldConfigSetDeepCopy(env.ModelName);
            if strcmp(newTarget,oldTarget)
                isTargetChanged=false;
            else
                env.CSM.switchTarget(oldCS,newTarget);
                isTargetChanged=true;
            end
            [comp,params,oldValue,newValue]=simulinkcoder.internal.wizard.Wizard.getConfigSetDiff(env.CSM.getUpdatedTempCS(),oldCS);
            if isTargetChanged

                tmp=configset.getParameterInfo('','SystemTargetFile');
                staticData=configset.internal.getConfigSetStaticData;
                compName=staticData.getComponent(tmp.Component);
                cgCompName=message(compName.NameKey).getString;
                comp=[{cgCompName},comp];
                description=tmp.Description;
                if description(end)==':'
                    description=description(1:end-1);
                end
                params=[{description},params];
                oldValue=[{oldTarget},oldValue];
                newValue=[{newTarget},newValue];
            end
        end
        function nodes=getSubsystemNode(env,useTree)
            if nargin<2
                useTree=false;
            end
            model=env.ModelName;


            subsys=find_system(env.ModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
            nonEmptySubsys={};
            for i=1:length(subsys)
                [~,isQuickStartCompatible]=env.subsysIsQuickStartCompatible(env.ModelName,subsys{i});
                if isQuickStartCompatible
                    nonEmptySubsys{end+1}=subsys{i};%#ok<AGROW>
                end
            end
            if isempty(subsys)
                subsys={};
            end
            nonEmptySubsys=nonEmptySubsys';
            env.NonEmptySubsys=nonEmptySubsys;
            refBlocks={};
            env.RefBlocks=refBlocks;
            if useTree
                rootNode=struct('Name',{model},'Id',Simulink.ID.getSID(model),'BlockType','Model','Parent','','Children',[]);
                if isempty(subsys)
                    sids={};
                else
                    sids=Simulink.ID.getSID(subsys);
                end
                nodes=struct('Name',subsys,'Id',sids,'BlockType','SubSystem','Parent','','Children',[]);
                nodes=[rootNode;nodes];
                ids={nodes.Id};

                for i=2:length(nodes)
                    parent=Simulink.ID.getSID(get_param(nodes(i).Name,'Parent'));
                    nodes(i).Parent=parent;
                    nodes(i).Name=get_param(nodes(i).Name,'Name');
                    idx=ismember(ids,parent);
                    nodes(idx).Children=[nodes(idx).Children,{nodes(i).Id}];
                end
            else
                nodes=[subsys,refBlocks];
            end
        end
        function out=isSubsystemBuild(env)
            out=(env.BuildMode==simulinkcoder.internal.wizard.BuildMode.SUBSYSTEMBUILD);
        end

        function setCommonOptimization(env)
            settings={...
            {'InlineParams','on'},...
            {'OptimizeBlockIOStorage','on'},...
            {'ExpressionFolding','on'},...
            {'AccelVerboseBuild','off'},...
            {'EnableMemcpy','on'},...
            {'BlockReduction','on'},...
            {'BooleanDataType','on'},...
            {'ConditionallyExecuteInputs','on'},...
            {'EfficientFloat2IntCast','on'},...
            {'EfficientMapNaN2IntZero','on'},...
            {'InitFltsAndDblsToZero','off'},...
            {'LifeSpan','1'},...
            {'NoFixptDivByZeroProtection','on'},...
            {'SimCompilerOptimization','off'},...
            {'UseDivisionForNetSlopeComputation','on'},...
            {'UseFloatMulNetSlope','on'},...
            {'GainParamInheritBuiltInType','on'},...
            {'ZeroExternalMemoryAtStartup','off'},...
            {'ZeroInternalMemoryAtStartup','off'},...
            {'BitfieldContainerType','uint_T'},...
            {'BufferReuse','on'},...
            {'GlobalBufferReuse','on'},...
            {'InlineInvariantSignals','on'},...
            {'InlinedParameterPlacement','NonHierarchical'},...
            {'LocalBlockOutputs','on'},...
            {'MemcpyThreshold',64},...
            {'PassReuseOutputArgsAs','Individual arguments'},...
            {'RollThreshold',5},...
            {'StrengthReduction','off'},...
            {'ActiveStateOutputEnumStorageType','Native Integer'}...
            ,{'AdvancedOptControl',''}...
            };
            for i=1:length(settings)
                env.setParamOptional(settings{i}{1},settings{i}{2});
            end
        end

        function setCommonSettings(env)
            env.setParamRequired('Solver','FixedStepAuto');

            settings={...
            {'IncludeHyperlinkInReport','on'},...
            {'GenerateReport','on'},...
            {'GenerateTraceInfo','on'},...
            {'GenerateTraceReport','on'},...
            {'GenerateTraceReportSl','on'},...
            {'GenerateTraceReportSf','on'},...
            {'GenerateTraceReportEml','on'},...
            {'LaunchReport','on'},...
            {'GenerateCodeReplacementReport','off'},...
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
            {'CombineOutputUpdateFcns','on'},...
            {'CombineSignalStateStructs','on'},...
            {'PreserveExpressionOrder','off'},...
            {'CheckMdlBeforeBuild','Off'},...
            {'MatFileLogging','off'}...
            };



            if~env.HasTerminate
                settings{end+1}={'IncludeMdlTerminateFcn','off'};
            else
                settings{end+1}={'IncludeMdlTerminateFcn','on'};
            end
            settings{end+1}={'SupportComplex','on'};









            settings{end+1}={'SupportNonFinite','on'};
            settings{end+1}={'SupportNonInlinedSFcns','on'};

            if~strcmp(env.Flavor,'Cpp')&&~strcmp(env.Flavor,'CppEncap')
                settings{end+1}={'GenerateCodeMetricsReport','on'};
            else
                settings{end+1}={'GenerateCodeMetricsReport','off'};
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





            env.setParamRequired('SupportContinuousTime','on');
            env.setParamOptional('SupportAbsoluteTime','on');
            env.setParamOptional('PurelyIntegerCode','on');
            env.setParamOptional('SupportVariableSizeSignals','on');



            env.setParamOptional('SuppressErrorStatus','off');
        end

        function selectSubsystem(env,subsystem)
            try
                env.SourceSubsystemHandle=get_param(subsystem,'handle');
            catch e
                env.handle_error(e);
            end
        end

        function delete(env)
            delete(env.Gui);
        end

    end
    methods(Hidden)
        function init(env)
            env.QuestionMap=containers.Map;
            env.OptionMap=containers.Map;
            env.QuestionStack=containers.Map;
            env.OptionStack=containers.Map;

            simulinkcoder.internal.wizard.question.Start(env);
            simulinkcoder.internal.wizard.question.Flavor(env);
            simulinkcoder.internal.wizard.question.Optimization(env);
            simulinkcoder.internal.wizard.question.Finish(env);
            simulinkcoder.internal.wizard.question.ApplyFail(env);
            simulinkcoder.internal.wizard.question.CodeGenFail(env);
            simulinkcoder.internal.wizard.question.Additional(env);

            env.updateOption;

        end
        function setMultiInstance(env)

            if~isempty(env.MultiInstance)
                if env.MultiInstance

                    env.setParamRequired('CodeInterfacePackaging','Reusable function');
                    env.setParamRequired('ModelReferenceNumInstancesAllowed','Multi');
                else

                    env.setParamRequired('CodeInterfacePackaging','Nonreusable function');
                end
            end
        end
    end
    methods(Static)
        function res=isFeatureOn()
            licenses={'MATLAB_Coder','Real-Time_Workshop'};
            res=true;
            for i=1:length(licenses)
                res=res&&license('test',licenses{i});
            end
            res=res&&...
            dig.isProductInstalled('MATLAB Coder')&&...
            dig.isProductInstalled('Simulink Coder');
        end

        function out=featureEnablePreserveData(value)
            persistent featureValue

            if isempty(featureValue)

                featureValue=false;
            end
            out=featureValue;
            if nargin>0
                featureValue=value;
            end
        end

        function doGRTLicenseCheckout()
            licenses={'Matlab_Coder','Real-Time_Workshop'};
            for i=1:length(licenses)
                if(builtin('_license_checkout',licenses{i},'quiet')~=0)
                    DAStudio.error('RTW:wizard:CoderLicenseNotAvailable',licenses{i});
                end
            end
        end
        function displayMSV()
            slmsgviewer.Instance.show;
        end
        function[comp,params,oldValue,newValue]=getConfigSetDiff(cs,oldCS)

            function str=loc_getParamAsStr(value)
                if isnumeric(value)
                    value=num2str(value);
                end
                try
                    jsonencode(value);
                    str=value;
                catch
                    str=class(value);
                end
            end
            [~,b]=isequal(cs,oldCS);
            oldParamInfo={};
            newParamInfo={};
            for i=1:length(b)
                if strcmp(b{i},'Name')||...
                    strcmp(b{i},'SolverName')
                    continue;
                end

                try
                    newParamInfo{end+1}=configset.getParameterInfo(cs,b{i});%#ok<AGROW>
                catch
                    newParamInfo{end+1}=[];%#ok<AGROW>
                end
                try
                    oldParamInfo{end+1}=configset.getParameterInfo(oldCS,b{i});%#ok<AGROW>
                catch
                    oldParamInfo{end+1}=[];%#ok<AGROW>
                end


                if~isempty(oldParamInfo{end})&&~isempty(newParamInfo{end})...
                    &&isequal(newParamInfo{end}.DisplayValue,oldParamInfo{end}.DisplayValue)
                    newParamInfo(end)=[];
                    oldParamInfo(end)=[];
                end
            end
            comp=cell(size(newParamInfo));
            params=cell(size(newParamInfo));
            oldValue=cell(size(newParamInfo));
            newValue=cell(size(newParamInfo));
            staticData=configset.internal.getConfigSetStaticData;
            for i=1:length(newParamInfo)
                if isempty(newParamInfo{i})
                    newValue{i}=message('RTW:wizard:NotApplicable').getString;
                else
                    newValue{i}=loc_getParamAsStr(newParamInfo{i}.DisplayValue);
                    pInfo=newParamInfo{i};
                end
                if isempty(oldParamInfo{i})
                    oldValue{i}=message('RTW:wizard:NotApplicable').getString;
                else
                    oldValue{i}=loc_getParamAsStr(oldParamInfo{i}.DisplayValue);
                    pInfo=oldParamInfo{i};
                end
                c=pInfo.Component;
                if strcmp(c,'Target')||strcmp(c,'Code Appearance')||strcmp(c,'ERT')||strcmp(c,'CPPClassGenComp')
                    c='Code Generation';
                end
                tmp=staticData.getComponent(c);
                if~isempty(tmp)
                    try
                        comp{i}=message(tmp.NameKey).getString;
                    catch

                        comp{i}=c;
                    end
                else
                    comp{i}=c;
                end
                params{i}=simulinkcoder.internal.wizard.Wizard.stripTrailingColon(pInfo.Description);
            end

            c='Code Generation';
            tmp=staticData.getComponent(c);
            cgCompName=message(tmp.NameKey).getString;
            idx1=ismember(comp,cgCompName);
            [cgComp,cgParam,cgOldValue,cgNewValue]=sortCell(comp(idx1),params(idx1),oldValue(idx1),newValue(idx1));

            idx2=~idx1;
            [noncgComp,noncgParam,noncgOldValue,noncgNewValue]=sortCell(comp(idx2),params(idx2),oldValue(idx2),newValue(idx2));

            comp=[cgComp,noncgComp];
            params=[cgParam,noncgParam];
            oldValue=[cgOldValue,noncgOldValue];
            newValue=[cgNewValue,noncgNewValue];
            function[c,p,o,n]=sortCell(comp,param,oldValue,newValue)
                sortStr=strcat(comp,param);
                [~,idx]=sort(sortStr);
                c=comp(idx);
                p=param(idx);
                o=oldValue(idx);
                n=newValue(idx);
            end
        end
        function buildStatusUpdate(bsn,~)
            env=get_param(bsn.iMdl,'CoderWizard');
            if isempty(env)
                return;
            end
            if env.GuiEntry
                env.Gui.pushBuildStatus(bsn);
            else
                env.TestStatusList{end+1}=bsn.lvlMdlRefName;
            end
        end
        function saveModel(modelName)
            assert(bdIsLoaded(modelName),'Cannot save model that is not loaded');
            fullname=get_param(modelName,'FileName');

            try


                if~isempty(fullname)
                    fileattrib(fullname,'+w');
                end
                save_system(modelName);
            catch me
                DAStudio.error('RTW:wizard:CannotSaveModel',get_param(modelName,'FileName'),me.message);
            end
        end
        function closeSystem(currentM,wasLoaded)
            if~wasLoaded
                close_system(currentM)
            end
        end
        function[mExc,out]=subsysIsQuickStartCompatible(model,subsys)


            stateStruct.wstate=warning('backtrace');
            stateStruct.pushNags=false;

            mExc=coder.internal.ss2mdl_basic_checks(model,subsys,stateStruct,false);

            incompatWithSSBuild=~isempty(mExc);


            if incompatWithSSBuild
                out=false;
            elseif~slprivate('is_stateflow_based_block',subsys)&&...
                length(find_system(subsys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','Block'))<=1
                out=false;
                mExc=MException('RTW:wizard:emptySubsystemNotStateflow',...
                message('RTW:wizard:emptySubsystemNotStateflow',subsys).getString());
            else
                out=true;
            end
        end
        function out=checkWritableDirectory(type)


            cfg=Simulink.fileGenControl('getConfig');
            out=true;

            if strcmp(type,'SIM')
                destPath=cfg.CacheFolder;
            elseif strcmp(type,'RTW')
                destPath=cfg.CodeGenFolder;
            end

            [~,fname]=fileparts(tempname);
            tmpDir=fullfile(destPath,fname);
            try
                mkdir(tmpDir);
                rmdir(tmpDir);
            catch

                out=false;
            end
        end


        function out=stripTrailingColon(str_in)
            if length(str_in)<2
                out='';
                return;
            end
            if strcmp(str_in(end),':')
                out=str_in(1:end-1);
            else
                out=str_in;
            end
        end
        function out=getModelHandle(modelName)
            if ischar(modelName)
                out=get_param(modelName,'handle');
            else
                out=modelName;
            end
        end
    end
end


function loc_closeOpenedModels(openSystems)
    currentlyOpenSystems=find_system('SearchDepth',0);
    openedSystems=setdiff(currentlyOpenSystems,openSystems);
    for i=1:length(openedSystems)
        close_system(openedSystems{i},0);
    end
end







