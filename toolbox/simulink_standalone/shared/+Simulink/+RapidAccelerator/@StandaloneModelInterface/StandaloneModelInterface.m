classdef StandaloneModelInterface<handle

%#function embedded.fi
%#function numerictype



    properties(GetAccess='public',SetAccess='public')
        verbosityLevel;
        modelCallbacksLevel;
        startTime;
    end

    properties(GetAccess='protected',SetAccess='protected')
        isInitializedForDeployment_;
        modelName_;
        curDir_;
        deployedRoot_;
        buildDir_;
        parameterMap_;
        blockParameterMap_;
        featureMap_;
        hookMap_;
        rootInPortPathList_;
        rootOutPortPathList_;
        rootEnablePortPathList_;
        rootTriggerPortPathList_;
        loggingToFile_;
        rtp_;
        buildExtInputs_;
        buildInitialState_;
        simInputGlobalWorkspace_;
        modelWorkspaceStruct_;
        maskTreeFile_;
        enumInfo_;
        variableRegistryFilePath_;
    end

    methods(Access='public',Static)
        function p=getTunableModelParameters()

            p={
            'AbsTol',...
            'ConsecutiveZCsStepRelTol',...
            'DataLoggingOverride',...
            'DatasetSignalFormat',...
            'Decimation',...
            'ExternalInput',...
            'ExtrapolationOrder',...
            'FinalStateName',...
            'FixedStep',...
            'InitialState',...
            'InitialStep',...
            'LimitDataPoints',...
            'LoadExternalInput',...
            'LoadInitialState',...
            'LocalBlockOutputs',...
            'LoggingFileName',...
            'LoggingIntervals',...
            'LoggingToFile',...
            'MaxConsecutiveMinStep',...
            'MaxConsecutiveZCs',...
            'MaxConsecutiveZCsMsg',...
            'MaxDataPoints',...
            'MaxNumMinSteps',...
            'MaxOrder',...
            'MaxStep',...
            'MinStep',...
            'MinStepSizeMsg',...
            'NumberNewtonIterations',...
            'NumStatesForStiffnessChecking',...
            'ODENIntegrationMethod',...
            'OutputOption',...
            'OutputSaveName',...
            'OutputTimes',...
            'RapidAcceleratorUpToDateCheck',...
            'Refine',...
            'RelTol',...
            'ReturnWorkspaceOutputs',...
            'ReturnWorkspaceOutputsName',...
            'SaveCompleteFinalSimState',...
            'SaveFinalState',...
            'SaveOperatingPoint',...
            'SaveOutput',...
            'SaveState',...
            'SaveTime',...
            'SignalLogging',...
            'SignalLoggingName',...
            'SimscapeLogType',...
            'SimulationMode',...
            'Solver',...
            'SolverName',...
            'SolverPrmCheckMsg',...
            'SolverResetMethod',...
            'SolverType',...
            'StartTime',...
            'StateSaveName',...
            'StiffnessThreshold',...
            'StopTime',...
            'TimeOut',...
            'TimeSaveName',...
            'MaxZcBracketingIterations',...
            'MaxZcPerStep',...
            'EnablePacing',...
'PacingRate'
            };
        end

        function p=getAdditionalModelParameters()



            p={...
            'AperiodicPartitionHitTimes',...
            'SolverStatusFlags',...
            'CompiledSolverName',...
            'CompiledStepSize',...
            'DaesscMode',...
            'DataDictionary',...
            'Dirty',...
            'DisableStreamingToRepository',...
            'ExtModeParamVectName',...
            'Handle',...
            'HasSrcBlksForAutoHmaxCalc',...
            'InspectSignalLogs',...
            'MakeCommand',...
            'ModelWorkspace',...
            'MultithreadedSim',...
            'ParallelExecutionNumThreads',...
            'ParallelExecutionNodeHandles',...
            'ParallelExecutionInRapidAccelerator',...
            'ParallelExecutionProfiling',...
            'ParallelExecutionProfilingOutputFilename',...
            'ProfilingBasedParallelExecution',...
            'ResolvedLoggingFileName',...
            'SaveSolverProfileInfo',...
            'SerializedTimingAndTaskingRegistry',...
            'SimCustomHeaderCode',...
            'SimCustomSourceCode',...
            'SolverProfileInfoName',...
            'SolverProfileInfoCollectionStartTime',...
            'SolverProfileInfoMaxSize',...
            'SolverProfileInfoLevel',...
            'UseSLExecSimBridge',...
            'VisualizeLoggedSignalsWhenLoggingToFile',...
            };
        end
    end

    methods(Access='public')
        function obj=StandaloneModelInterface(modelName)
            obj.verbosityLevel=0;
            ev=getenv('RAPID_ACCELERATOR_OPTIONS_VERBOSE');
            if~isempty(ev)
                obj.verbosityLevel=eval(ev);
            end
            obj.modelCallbacksLevel=0;
            obj.isInitializedForDeployment_=false;
            obj.modelName_=convertStringsToChars(modelName);
            obj.buildDir_=[];
            obj.parameterMap_=containers.Map;
            obj.blockParameterMap_=containers.Map;
            obj.featureMap_=containers.Map;
            obj.hookMap_=containers.Map;
            obj.rootInPortPathList_=[];
            obj.rootOutPortPathList_=[];
            obj.rootEnablePortPathList_=[];
            obj.rootTriggerPortPathList_=[];
            obj.rtp_=[];
            obj.buildExtInputs_=[];
            obj.buildInitialState_=[];
            obj.simInputGlobalWorkspace_=Simulink.standalone.MatlabWorkspace;
        end

        function val=getCurDir(obj)
            val=obj.curDir_;
        end

        function val=getDeployedRoot(obj)
            val=obj.deployedRoot_;
        end

        function val=getBuildDir(obj)
            val=obj.buildDir_;
        end

        function setRtp(obj,rtp)
            obj.rtp_=rtp;
        end

        function rtp=getRtp(obj)
            rtp=obj.rtp_;
        end

        function extInputs=getBuildExtInputs(obj)
            extInputs=obj.buildExtInputs_;
        end

        function initialState=getBuildInitialState(obj)
            initialState=obj.buildInitialState_;
        end

        function modelWorkspaceStruct=getModelWorkspaceStruct(obj)
            modelWorkspaceStruct=obj.modelWorkspaceStruct_;
        end

        function maskTreeFile=getMaskTreeFile(obj)
            maskTreeFile=obj.maskTreeFile_;
        end

        function variableRegistryFilePath=getVariableRegistryFilePath(obj)
            variableRegistryFilePath=obj.variableRegistryFilePath_;
        end

        function loadEnumDefinitions(obj)
            setEnumInfo(obj);
            obj.debugLog(2,'Loading enum definitions');
            obj.debugLog(2,['Loading ',num2str(length(obj.enumInfo_)),' enum definitions']);
            for i=1:length(obj.enumInfo_)
                obj.debugLog(2,['Loading enum definition for ',obj.enumInfo_(i).enumName]);
                obj.debugLog(2,['enum class name: ',obj.enumInfo_(i).enumName]);
                obj.debugLog(2,['enum storage type: ',obj.enumInfo_(i).storageType]);
                obj.debugLog(2,['enum default value: ',obj.enumInfo_(i).defaultValue]);
                Simulink.standalone.defineIntEnumType(...
                obj.enumInfo_(i).enumName,...
                obj.enumInfo_(i).labels,...
                obj.enumInfo_(i).values,...
                obj.enumInfo_(i).defaultValue,...
                obj.enumInfo_(i).storageType);
            end
        end

        function n=name(obj)
            n=obj.modelName_;
        end




        function debugLog(obj,level,msg)
            if level<=obj.verbosityLevel
                if isempty(obj.startTime)
                    obj.startTime=clock;
                    fprintf('### %6.2fs :: Initializing startTime\n',etime(clock,obj.startTime));
                end
                str=sprintf('### %6.2fs :: ',etime(clock,obj.startTime));
                msgrep=regexprep(msg,'\\','\\\\');
                str=[str,msgrep,'\n'];
                if isa(str,'string'),str=strjoin(str);end
                fprintf(str);
            end
        end

        function setIsInitializedForDeployment(obj,val)
            obj.isInitializedForDeployment_=val;
        end

        function copyAllAddedToRapidFolder(obj,curDir,buildDir)

            evalc('fileList = dir(curDir);');
            for i=1:numel(fileList)
                fileFullPath=fullfile(curDir,fileList(i).name);
                fileName=fileList(i).name;



                if(strcmp(fileName,".")||strcmp(fileName,"..")||...
                    strcmp(fileName,"toolbox")||strcmp(fileName,"slprj"))
                    continue;
                end


                [~,~,fileExtension]=fileparts(fileList(i).name);
                fileExtension=lower(fileExtension);

                if(fileList(i).isdir)

                    obj.debugLog(2,['Inspecting FOLDER for copy into build dir: ',fileName]);
                    obj.copyAllAddedToRapidFolder(fileFullPath,buildDir);
                elseif(strcmp(fileExtension,'.dll')||...
                    strcmp(fileExtension,'.so')||...
                    strcmp(fileExtension,'.dyld')||...
                    strcmp(fileExtension,'.mat')||...
                    strcmp(fileExtension,'.xlsx')...
                    )

                    obj.debugLog(2,['Copying this FILE into build dir: ',fileName]);
                    copyfile(fileFullPath,buildDir,'f');
                end
            end
        end

        function buildDir=initializeForDeployment(obj)









            if(~obj.isInitializedForDeployment_&&...
                ~strcmpi(obj.modelName_,'simulink'))


                sFound=which('sl');
                if(isempty(sFound))
                    error(message('simulinkcompiler:runtime:SimulinkCompilerNotDetected'));
                end

                obj.modelCallbacksLevel=sl('rapid_accel_target_utils','get_opt','deployed_model_callbacks',0);

                obj.debugLog(1,['Initializing for deployment for ',obj.modelName_]);

                obj.curDir_=pwd;


                if(isdeployed)

                    obj.deployedRoot_=findDeployedRoot(ctfroot);
                else



                    obj.deployedRoot_=pwd;
                end
                obj.buildDir_=fullfile(obj.deployedRoot_,'slprj','raccel_deploy',obj.modelName_);

                obj.debugLog(1,['Current dir: ',obj.curDir_]);
                obj.debugLog(1,['Deployed root dir: ',obj.deployedRoot_]);
                obj.debugLog(1,['Deployed build dir: ',obj.buildDir_]);


                standaloneInterfaceFileName=...
                fullfile(obj.buildDir_,'standaloneModelInterface.mat');

                obj.deserializeData(standaloneInterfaceFileName);


                buildRTPFileName=...
                fullfile(obj.buildDir_,'build_rtp.mat');
                obj.debugLog(1,['Loading RTP file ',buildRTPFileName]);
                rtp=load(buildRTPFileName);
                rtp.internal.forInternalUse=true;
                obj.rtp_=rtp;

                loadEnumDefinitions(obj);
                setExternalInputs(obj);
                setInitialState(obj);
                setModelWorkspaceStruct(obj);
                setMaskTreeFile(obj);
                setVariableRegistryFilePath(obj);
            end

            obj.isInitializedForDeployment_=true;



            buildDir=obj.buildDir_;
        end



        function deserializeData(obj,filename)

            if(obj.isInitializedForDeployment_)
                return;
            end

            serializeStruct=load(filename);
            serializeStruct=serializeStruct.serializeStruct;
            parameters=serializeStruct.parameters;

            keys=fieldnames(parameters);
            for i=1:length(keys)
                key=keys{i};
                obj.parameterMap_(key)=getfield(parameters,key);%#ok<GFLD>
            end
            if(obj.verbosityLevel>2)
                obj.debugLog(3,'Displaying deserialized model parameters');
                disp(parameters);
            end

            obj.blockParameterMap_=serializeStruct.blockParameters;
            obj.modelName_=serializeStruct.modelName;
            obj.rtp_=serializeStruct.rtp;
            if(obj.verbosityLevel>2)
                obj.debugLog(3,'Displaying deserialized block parameters');
                keys=obj.blockParameterMap_.keys;
                for i=1:length(keys)

                    try
                        val=obj.blockParameterMap_(keys{i});
                        if(isstruct(val))
                            disp([keys{i},' : ']);
                            disp(val);
                        else
                            disp([keys{i},' : ',val]);
                        end
                    catch
                    end
                end
            end

            features=serializeStruct.features;
            keys=fieldnames(features);
            for i=1:length(keys)
                key=keys{i};
                obj.featureMap_(key)=getfield(features,key);%#ok<GFLD>
            end
            if(obj.verbosityLevel>2)
                obj.debugLog(3,'Displaying deserialized feature values');
                disp(features);
            end

            hooks=serializeStruct.hooks;
            keys=fieldnames(hooks);
            for i=1:length(keys)
                key=keys{i};
                obj.hookMap_(key)=getfield(hooks,key);%#ok<GFLD>
            end
            if(obj.verbosityLevel>2)
                obj.debugLog(3,'Displaying deserialized hooks values');
                disp(hooks);
            end
        end

        function val=get_block_param(obj,path,parameter)
            key=lower([path,'/',parameter]);
            val=obj.blockParameterMap_(key);
        end

        function val=set_block_param(obj,path,parameter,val)
            key=lower([path,'/',parameter]);
            obj.blockParameterMap_(key)=val;
        end

        function set_param(obj,parameter,val)
            key=lower(parameter);
            obj.parameterMap_(key)=val;
        end

        function val=get_param(obj,parameter)
            key=lower(parameter);
            val=obj.parameterMap_(key);
        end

        function val=slfeature(obj,feature,varargin)
            key=lower(feature);
            try
                val=obj.featureMap_(key);
                if~isempty(varargin)&&~isempty(varargin{1})
                    new_val=varargin{1};
                    if iscell(new_val)
                        new_val=new_val{1};
                    end
                    obj.featureMap_(key)=new_val;
                    slf_feature('services','feature',feature,new_val);
                end
            catch e






                val=0;
            end
        end

        function val=slhook(obj,hook,varargin)
            key=lower(hook);
            try
                val=obj.hookMap_(key);
                if~isempty(varargin)&&~isempty(varargin{1})
                    new_val=varargin{1};
                    if iscell(new_val)
                        new_val=new_val{1};
                    end
                    obj.hookMap_(key)=new_val;
                    slf_feature('services','hook',hook,new_val);
                end
            catch e






                val=0;
            end
        end







        function populateDesktopValues(obj)
            minimalParamsList=[obj.getTunableModelParameters(),obj.getAdditionalModelParameters()];
            populateParameters(obj,obj.modelName_,minimalParamsList,false);

            obj.parameterMap_('simulationstatus')='stopped';

            obj.parameterMap_('simulationmode')='RapidAccelerator';

            featuresDB=slf_feature('services','features');

            for i=1:length(featuresDB.names)
                if isvarname(featuresDB.names(i))
                    obj.featureMap_(lower(featuresDB.names(i)))=featuresDB.values(i);
                end
            end

            hooksDB=slf_feature('services','hooks');

            for i=1:length(hooksDB.names)
                if isvarname(hooksDB.names(i))
                    obj.hookMap_(lower(hooksDB.names(i)))=hooksDB.values(i);
                end
            end

            obj.rootInPortPathList_=...
            find_system(obj.modelName_,'SearchDepth',1,'BlockType','Inport');
            populateBlockParameters(obj,obj.rootInPortPathList_,...
            {'BlockType','OutDataTypeStr','Interpolate','OutMax','OutMin','SampleTime',...
            'OutputFunctionCall','varSizeSig','CompiledLocalCGVCE'});

            obj.rootEnablePortPathList_=...
            find_system(obj.modelName_,'SearchDepth',1,'BlockType','EnablePort');
            populateBlockParameters(obj,obj.rootEnablePortPathList_,...
            {'BlockType','OutDataTypeStr','Interpolate','OutMax','OutMin','SampleTime'});

            obj.rootTriggerPortPathList_=...
            find_system(obj.modelName_,'SearchDepth',1,'BlockType','TriggerPort');
            populateBlockParameters(obj,obj.rootTriggerPortPathList_,...
            {'BlockType','OutDataTypeStr','Interpolate','OutMax','OutMin','SampleTime'});

            obj.rootOutPortPathList_=...
            find_system(obj.modelName_,'SearchDepth',1,'BlockType','Outport');
            populateBlockParameters(obj,obj.rootOutPortPathList_,...
            {'BlockType','SampleTime'});

        end




        function serializeData(obj,filename)
            keys=obj.parameterMap_.keys;
            parameters=[];
            for i=1:length(keys)
                key=keys{i};
                parameters=setfield(parameters,key,obj.parameterMap_(key));%#ok<SFLD>
            end
            keys=obj.featureMap_.keys;
            features=[];
            for i=1:length(keys)
                key=keys{i};
                features=setfield(features,key,obj.featureMap_(key));%#ok<SFLD>
            end
            keys=obj.hookMap_.keys;
            hooks=[];
            for i=1:length(keys)
                key=keys{i};
                hooks=setfield(hooks,key,obj.hookMap_(key));
            end
            serializeStruct.modelName=obj.modelName_;
            serializeStruct.parameters=parameters;
            serializeStruct.blockParameters=obj.blockParameterMap_;
            serializeStruct.features=features;
            serializeStruct.hooks=hooks;
            serializeStruct.rtp=obj.rtp_;
            save(filename,'serializeStruct');
        end

    end

    methods(Access='private')
        function populateParameters(obj,path,additionalParameters,isBlockParameter)
            objectParameters=get_param(path,'ObjectParameters');
            objectParameters=fields(objectParameters);
            allParameters=unique([additionalParameters,objectParameters']);
            origWarningState=warning;
            suppressWarnings=onCleanup(@()warning(origWarningState));
            warning('off');
            for i=1:length(allParameters)
                parameterName=allParameters{i};
                if(isBlockParameter)
                    mapKey=lower([path,'/',parameterName]);
                else
                    mapKey=lower(parameterName);
                end
                try
                    parameterValue=get_param(path,parameterName);
                    if(~isobject(parameterValue))
                        if(isBlockParameter)
                            obj.blockParameterMap_(mapKey)=parameterValue;
                        else
                            obj.parameterMap_(mapKey)=parameterValue;
                        end
                    end
                catch
                    if(isBlockParameter)
                        obj.blockParameterMap_(mapKey)='';
                    else
                        obj.parameterMap_(mapKey)='';
                    end
                end
            end
        end

        function populateBlockParameters(obj,list,additionalParameters)
            for i=1:length(list)
                blockPath=list{i};
                populateParameters(obj,blockPath,additionalParameters,true);
            end
        end

        function setEnumInfo(obj)
            enumFile=...
            sl('rapid_accel_target_utils','get_enum_file',obj.modelName_,obj.buildDir_);

            obj.debugLog(2,['In setEnumInfo, Loading enum info file ',enumFile]);

            obj.enumInfo_=...
            load(enumFile).enumInfo;

            obj.debugLog(3,['Found ',num2str(length(obj.enumInfo_)),' enums']);
        end

        function setExternalInputs(obj)
            extInputFile=...
            sl('rapid_accel_target_utils','get_build_ext_input_file',obj.buildDir_);

            obj.debugLog(2,['Loading external input file ',extInputFile]);

            obj.buildExtInputs_=...
            load(extInputFile).extInputs;
        end

        function setInitialState(obj)
            initialStateFile=...
            sl('rapid_accel_target_utils','get_build_initial_state_file',obj.buildDir_);

            obj.debugLog(2,['Loading initial state file ',initialStateFile]);

            obj.buildInitialState_=...
            load(initialStateFile).initialState;
        end

        function setModelWorkspaceStruct(obj)
            modelWorkspaceFile=...
            sl('rapid_accel_target_utils','get_model_workspace_file',obj.buildDir_);

            obj.modelWorkspaceStruct_=load(modelWorkspaceFile);
        end

        function setMaskTreeFile(obj)
            obj.maskTreeFile_=...
            sl('rapid_accel_target_utils','get_mask_tree_file',obj.modelName_,obj.buildDir_);
        end

        function setVariableRegistryFilePath(obj)
            obj.variableRegistryFilePath_=...
            fullfile(obj.buildDir_,obj.modelName_+"_variable_registry.xml");
        end
    end
end
