classdef SignalEditorBlock<matlab.mixin.Copyable














    properties(Access='private')
        Version='1.4';
    end

    properties(Access='protected')
FileName
Scenario
        SignalCache=Simulink.signaleditorblock.model.Signal;
BlockName
EditorDlg
        PreserveSignalName='on'
        ScenarioToSignalListMap=containers.Map;
        SignalNameToPropertiesMap=containers.Map;
        CurrentFileInfo='';
        CurrentFileChecksum='';
LastUpdateTime
    end

    properties
        isUpdated=false;
    end

    methods
        function obj=SignalEditorBlock
            obj.FileName='untitled.mat';
            obj.Scenario='Scenario';
            obj.ScenarioToSignalListMap('Scenario')={'Signal 1'};
            obj.SignalNameToPropertiesMap=containers.Map;
        end

        function preserveSignalName=getPreserveSignalName(obj)
            preserveSignalName=obj.PreserveSignalName;
        end

        function updateDataModel(obj,BlockProperties)
            obj.processSignal(BlockProperties.Signal);
            obj.Scenario=BlockProperties.Scenario;
            obj.PreserveSignalName=BlockProperties.PreserveSignalName;
            try
                obj.processFile(BlockProperties.FileName);
            catch ME

                obj.ScenarioToSignalListMap=containers.Map;
                obj.CurrentFileInfo='';
                throw(ME);
            end
            obj.LastUpdateTime=datetime('now');
        end

        function updateFileIfRequired(obj,FileName)
            obj.processFile(FileName);
        end

        function scenarioList=getScenarioList(obj)
            scenarioList=obj.ScenarioToSignalListMap.keys;
        end

        function scenario=getScenario(obj)
            scenario=obj.Scenario;
        end

        function signalList=getSignalsForScenario(obj,ScenarioName)
            if obj.ScenarioToSignalListMap.isKey(ScenarioName)
                signalList=obj.ScenarioToSignalListMap(ScenarioName);
            else
                signalList={};
            end
        end

        function SignalProperties=getSignalProperties(obj,SignalName)
            if obj.SignalNameToPropertiesMap.isKey(SignalName)
                SignalProperties=obj.SignalNameToPropertiesMap(SignalName);
            else
                SignalProperties=Simulink.signaleditorblock.model.Signal;
            end
        end

        function SignalsBeingUpdated=getSignalsBeingUpdated(obj)
            SignalsBeingUpdated=obj.SignalNameToPropertiesMap.keys;
        end
    end

    methods(Static)
        function BlockProperties=createBlockProperties(BlockH)
            BlockProperties.FileName=Simulink.signaleditorblock.FileUtil.getFullFileNameForBlock(BlockH);
            BlockProperties.Scenario=get_param(BlockH,'ActiveScenario');
            BlockProperties.Signal=Simulink.signaleditorblock.model.Signal.createSignalFromBlockHandle(BlockH);
            BlockProperties.PreserveSignalName=get_param(BlockH,'PreserveSignalName');
        end
    end

    methods(Access='protected')
        function cp=copyElement(obj)

            cp=copyElement@matlab.mixin.Copyable(obj);
            keys=obj.SignalNameToPropertiesMap.keys;
            cp.SignalNameToPropertiesMap=containers.Map;
            for id=1:length(keys)
                aSignal=obj.SignalNameToPropertiesMap(keys{id});
                cp.SignalNameToPropertiesMap(keys{id})=copy(aSignal);
            end
        end

        function processFile(obj,newFileName)
            [basePath,baseFileName,ext]=fileparts(newFileName);
            if isempty(baseFileName)
                throw(MException(message('sl_sta_editor_block:message:EmptyFileName')));
            end
            if~strcmpi(ext,'.mat')
                obj.ScenarioToSignalListMap=containers.Map;
                obj.CurrentFileInfo='';
                throw(MException(message('sl_sta_editor_block:message:NotMATFile',newFileName)));
            end
            if~exist(newFileName,'file')
                obj.ScenarioToSignalListMap=containers.Map;
                obj.CurrentFileInfo='';
                if strcmp(newFileName,'untitled.mat')
                    throw(MException(message('sl_sta_editor_block:message:LaunchSignalEditorCreateNewFile',newFileName)));
                else
                    throw(MException(message('sl_sta_editor_block:message:NonExistentFile',newFileName)));
                end
            end
            if isempty(obj.CurrentFileChecksum)
                fullFileName=newFileName;
                if isempty(basePath)
                    fullFileName=which(newFileName);
                end
                obj.CurrentFileChecksum=Simulink.getFileChecksum(fullFileName);
            end
            if obj.isUpdateRequired(newFileName)
                [scenarioNames,foundDs]=obj.getScenarioNamesForFile(newFileName);
                obj.ScenarioToSignalListMap=containers.Map;
                if~foundDs
                    throw(MException(message('sl_sta_editor_block:message:NoScenarios',newFileName)));
                end
                obj.FileName=newFileName;
                fileContents=load(obj.FileName);
                for id=1:length(scenarioNames)
                    ds=fileContents.(scenarioNames{id});
                    if isscalar(ds)

                        obj.ScenarioToSignalListMap(scenarioNames{id})=cellstr(ds.getElementNames);
                    end
                end



                foundScenarios=obj.getScenarioList;
                if~isempty(foundScenarios)&&~any(strcmp(obj.Scenario,foundScenarios))
                    obj.Scenario=foundScenarios{1};
                end

                obj.isUpdated=true;
            end
        end

        function processSignal(obj,Signal)
            DefaultProperties=Simulink.signaleditorblock.model.Signal;
            SignalToUpdate=obj.getSignalProperties(Signal.Name);
            if~areSignalPropertiesEqual(Signal,DefaultProperties)||...
                ~areSignalPropertiesEqual(obj.SignalCache,Signal)
                signalProperties=properties(Signal);
                for id=1:length(signalProperties)
                    if strcmp(signalProperties{id},...
                        'Name')
                        continue;
                    else

                        if~strcmp(Signal.(signalProperties{id}),...
                            obj.SignalCache.(signalProperties{id}))
                            SignalToUpdate.(signalProperties{id})=...
                            Signal.(signalProperties{id});
                        end
                    end
                end
                SignalToUpdate.Name=Signal.Name;
                if~areSignalPropertiesEqual(SignalToUpdate,DefaultProperties)
                    obj.SignalNameToPropertiesMap(Signal.Name)=SignalToUpdate;
                    obj.isUpdated=true;
                end
            end

            obj.SignalCache=SignalToUpdate;
        end

        function bool=isUpdateRequired(obj,newFileName)
            [path,~,~]=fileparts(newFileName);
            if isempty(path)
                newFileName=which(newFileName);
            end
            newFileInfo=dir(newFileName);
            bool=~isequal(newFileInfo,obj.CurrentFileInfo);
            if bool
                obj.CurrentFileInfo=newFileInfo;
                obj.CurrentFileChecksum=Simulink.getFileChecksum(newFileName);
            else
                newFileDate=datetime(newFileInfo.datenum,'ConvertFrom','datenum');
                if abs(newFileDate-obj.LastUpdateTime)<seconds(2)





                    newChecksum=Simulink.getFileChecksum(newFileName);
                    if~isequal(newChecksum,obj.CurrentFileChecksum)
                        bool=true;
                        obj.CurrentFileChecksum=newChecksum;
                    end
                end
            end
        end

        function[scenarioNames,foundDs]=getScenarioNamesForFile(~,fileName)
            scenarioNames={'Scenario'};
            foundDs=false;
            if exist(fileName,'file')
                varNames=Simulink.SimulationData.DatasetRef.getDatasetVariableNames(fileName);
                if~isempty(varNames)
                    foundDs=true;
                    scenarioNames=varNames;
                end
            end
        end
    end
end
