




classdef SimModel<handle



    properties(Access=protected)

        MsgIdPref='';


        CachedAutoSaveState=[];


        SignalLoggerPrefix='';


        PortHsToLog=[];


        TcIdx=[];


        OriginalWarningStatus={};



        MdlParametersMap=[];


        MdlLoaded={};



        ModelHsNormalMode=[];


        ModelHsInMdlRefTree=[];



        SettingsCache=[];



        DirtyStatus=[];



        ExistingLoggerConfig=[];


        ModelLogger='logsout';


        UtilityName='';
    end

    methods
        function obj=SimModel
            obj.MdlParametersMap=containers.Map('KeyType','char','ValueType','any');
        end

        function delete(obj)
            delete(obj.MdlParametersMap);
        end
    end

    methods(Access=protected)
        function restoreModelBack(obj)

            obj.restoreInterpForInports;
            obj.restoreBaseWorkspaceVars;
            obj.restoreModelParameters;
            obj.restoreOriginalModelParams;
            obj.restoreWarningStatus;


            obj.restoreLoadedModels;

            obj.restoreAutoSaveState;
        end

        function simInput=configureAutoSaveState(obj,simInput)
            if isempty(obj.CachedAutoSaveState)
                old_autosave_state=get_param(0,'AutoSaveOptions');
                obj.CachedAutoSaveState=old_autosave_state;
                new_autosave_state=old_autosave_state;
                new_autosave_state.SaveOnModelUpdate=0;
                new_autosave_state.SaveBackupOnVersionUpgrade=0;

                if nargin==2

                    simInput=simInput.setVariable('AutoSaveOptions',new_autosave_state);
                else
                    simInput=[];
                    set_param(0,'AutoSaveOptions',new_autosave_state);
                end
            end
        end

        function restoreAutoSaveState(obj)
            if~isempty(obj.CachedAutoSaveState)
                old_autosave_state=obj.CachedAutoSaveState;
                set_param(0,'AutoSaveOptions',old_autosave_state);
                obj.CachedAutoSaveState=[];
            end
        end


        function resetSessionData(obj)
            obj.restoreModelBack;
        end











        function handleMsg(obj,msgOpt,varargin)
            if nargin==3
                switch msgOpt
                case 'warning'
                    sldvshareprivate('util_gen_warning_notrace',varargin{1}.Identifier,getString(varargin{1}));
                case 'error'
                    obj.resetSessionData;
                    error(varargin{1});
                otherwise
                    assert(false,getString(message('Sldv:SimModel:UnexpectedMsgValue')));
                end
            else
                switch msgOpt
                case 'warning'
                    sldvshareprivate('util_gen_warning_notrace',varargin{1},varargin{2},varargin{3:end});
                case 'error'
                    obj.resetSessionData;
                    error(varargin{1},varargin{2},varargin{3:end});
                otherwise
                    assert(false,getString(message('Sldv:SimModel:UnexpectedMsgValue')));
                end
            end
        end

        cacheExistingLoggers(obj)



        restoreLoggers(obj,modelHIncludingLoggers)


        configureLoggers(obj,modelHIncludingLoggers)


        function turnOffAndStoreWarningStatus(obj)
            warningIds=obj.listWarningsToTurnForLogging;
            warningStatus=cell(1,length(warningIds));
            for i=1:length(warningIds)
                warningStatus{i}=warning('query',char(warningIds{i}));
                warning('off',char(warningIds{i}));
            end
            obj.OriginalWarningStatus=warningStatus;
        end

        function restoreWarningStatus(obj)
            if~isempty(obj.OriginalWarningStatus)
                warningIds=obj.listWarningsToTurnForLogging;
                warningStatus=obj.OriginalWarningStatus;
                for i=1:length(warningIds)
                    warning(warningStatus{i}.state,char(warningIds{i}));
                end
                obj.OriginalWarningStatus={};
            end
        end

        function findBlocksInMdlRefTree(obj,topModelH)
            modelQueue={};
            modelQueue{end+1}=topModelH;
            startMdlIdx=1;
            while startMdlIdx<=length(modelQueue)
                startMdlH=modelQueue{startMdlIdx};
                startMdlName=get_param(startMdlH,'Name');
                mdlBlks=Sldv.utils.findModelBlocks(startMdlName);
                for i=1:length(mdlBlks)
                    blockH=get_param(mdlBlks{i},'Handle');
                    referencedModelName=get_param(blockH,'ModelName');
                    isLoaded=bdIsLoaded(referencedModelName);
                    if~isLoaded
                        Sldv.load_system(referencedModelName);
                        obj.MdlLoaded{end+1}=referencedModelName;
                    end
                    refmodelH=get_param(referencedModelName,'Handle');
                    modelQueue{end+1}=refmodelH;%#ok<AGROW>
                    obj.ModelHsInMdlRefTree(end+1)=refmodelH;
                    if strcmp(get_param(blockH,'SimulationMode'),'Normal')
                        obj.ModelHsNormalMode(end+1)=refmodelH;
                    end
                end
                startMdlIdx=startMdlIdx+1;
            end
        end

        function restoreLoadedModels(obj)
            if~isempty(obj.MdlLoaded)
                for idx=1:length(obj.MdlLoaded)
                    Sldv.close_system(obj.MdlLoaded{idx},0);
                end
                obj.MdlLoaded={};
            end
        end

        function restoreModelParameters(obj)
            entries=obj.MdlParametersMap.keys;
            if~isempty(entries)
                for idx=1:length(entries)
                    modelName=entries{idx};
                    modelH=get_param(modelName,'Handle');
                    origDirty=get_param(modelH,'Dirty');
                    buildInfo=obj.MdlParametersMap(entries{idx});
                    paramNames=fields(buildInfo);
                    for jdx=1:length(paramNames)
                        if strcmp(paramNames{jdx},'OldConfigSet')
                            assert(jdx==length(paramNames));
                            oldConfigSet=buildInfo.(paramNames{jdx});
                            Sldv.utils.restoreConfigSet(modelName,oldConfigSet);
                        elseif strcmp(paramNames{jdx},'SfDebugSettings')
                            Sldv.utils.setSFDebugSettings(modelH,buildInfo.(paramNames{jdx}));
                        else
                            set_param(modelName,paramNames{jdx},buildInfo.(paramNames{jdx}));
                        end
                    end
                    set_param(modelH,'Dirty',origDirty);
                end
            end
        end

        function restoreDirtyStatus(obj)
            modelNames=fieldnames(obj.DirtyStatus);
            for idx=1:length(modelNames)
                set_param(modelNames{idx},'Dirty',obj.DirtyStatus.(modelNames{idx}));
            end
        end

        function restoreInterpForInports(obj)%#ok<MANU>
        end

        function restoreBaseWorkspaceVars(obj)%#ok<MANU>
        end

    end

    methods(Abstract,Access=protected)
        storeOriginalModelParams(obj)



        restoreOriginalModelParams(obj)


        derivePortHandlesToLog(obj)


        initForSim(obj)



        paramNameValStruct=getBaseSimStruct(obj)



        paramNameValStruct=modifySimstruct(obj,testIndex,paramNameValStruct)



        runTests(obj)


        listWarningsToTurnForLogging(obj)

        changeModelParameters(obj)
    end

    methods(Access=protected,Static)
        function settings=updateEMLSFSettings(modelH,settings)
            sfDebugSettings=Sldv.utils.disableSFDebugSettings(modelH);
            if~isempty(sfDebugSettings)
                settings.SfDebugSettings=sfDebugSettings;
            end
        end

        function[originalParams,simInput]=changeMdlParams(modelH,paramNameValStruct,simInput)


            if nargin<3
                simInput=[];
                useSimIn=false;
            else
                useSimIn=true;
            end
            originalParams=[];
            paramNames=fieldnames(paramNameValStruct);
            for idx=1:length(paramNames)
                originalParams.(paramNames{idx})=get_param(modelH,paramNames{idx});
                if useSimIn
                    simInput=setModelParameter(simInput,paramNames{idx},paramNameValStruct.(paramNames{idx}));
                else
                    set_param(modelH,paramNames{idx},paramNameValStruct.(paramNames{idx}));
                end
            end
        end

        function out=checkSldvFeature(featureName)
            out=license('test','Simulink_Design_Verifier')&&...
            exist('slavteng','builtin')==5&&...
            logical(slavteng('feature',featureName));
        end
    end

end


