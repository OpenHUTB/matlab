classdef SignalEditorBlockUnique<Simulink.signaleditorblock.model.SignalEditorBlock





    properties(Access=protected)
        dataMap=containers.Map;
        Version='1.0';
    end

    methods
        function obj=SignalEditorBlockUnique
            obj.FileName='untitled.mat';
            obj.Scenario='Scenario';

            defaultSignals=containers.Map;
            defaultSignals('Signal 1')=[];
            obj.dataMap('Scenario')=defaultSignals;
        end

        function updateDataModel(obj,BlockProperties)
            try
                obj.processFile(BlockProperties.FileName);
            catch ME

                obj.ScenarioToSignalListMap=containers.Map;
                obj.CurrentFileInfo='';
                throw(ME);
            end
            obj.processScenario(BlockProperties.Scenario);
            obj.processSignal(BlockProperties.Signal);
            obj.PreserveSignalName=BlockProperties.PreserveSignalName;
            obj.LastUpdateTime=datetime('now');
        end

        function SignalProperties=getSignalProperties(obj,SignalName)
            SignalProperties=[];

            if obj.dataMap.isKey(obj.Scenario)
                signalMap=obj.dataMap(obj.Scenario);
                if signalMap.isKey(SignalName)
                    SignalProperties=signalMap(SignalName);
                end
            end

            if isempty(SignalProperties)
                SignalProperties=Simulink.signaleditorblock.model.Signal;
            end
        end

        function SignalsBeingUpdated=getSignalsBeingUpdated(obj)

            SignalsBeingUpdated={};
            if obj.dataMap.isKey(obj.Scenario)
                signalNames=obj.dataMap(obj.Scenario).keys;
                signalValues=values(obj.dataMap(obj.Scenario),signalNames);
                SignalsBeingUpdated=signalNames(~cellfun(@isempty,signalValues));
            end
        end

        function importFromSignalEditorBlock(obj,oldDataModel)
            obj.PreserveSignalName=oldDataModel.getPreserveSignalName();
            scenarioList=oldDataModel.getScenarioList();
            for i=1:length(scenarioList)
                signalList=oldDataModel.getSignalsForScenario(scenarioList{i});
                obj.ScenarioToSignalListMap(scenarioList{i})=signalList;
                tempSignalMap=containers.Map;
                for j=1:length(signalList)
                    tempSignalMap(signalList{j})=oldDataModel.getSignalProperties(signalList{j});
                end
                obj.dataMap(scenarioList{i})=tempSignalMap;
            end
        end

        function cp=exportToSignalEditorBlock(obj)
        end
    end

    methods(Access=protected)
        function cp=copyElement(obj)

            cp=copyElement@matlab.mixin.Copyable(obj);

            scenarios=obj.dataMap.keys;
            cp.dataMap=containers.Map;
            for i=1:length(scenarios)
                signalMap=obj.dataMap(scenarios{i});
                keys=signalMap.keys;
                cpMap=containers.Map;
                for j=1:length(keys)
                    aSignal=signalMap(keys{j});
                    if~isempty(aSignal)
                        cpMap(aSignal.Name)=copy(aSignal);
                    else
                        cpMap(keys{j})=[];
                    end
                end
                cp.dataMap(scenarios{i})=cpMap;
            end
        end

        function processFile(obj,newFileName)
            [basePath,baseFileName,ext]=fileparts(newFileName);
            if isempty(baseFileName)
                throw(MException(message('sl_sta_editor_block:message:EmptyFileName')));
            end
            if~strcmpi(ext,'.mat')
                obj.dataMap=containers.Map;
                obj.ScenarioToSignalListMap=containers.Map;
                obj.CurrentFileInfo='';
                throw(MException(message('sl_sta_editor_block:message:NotMATFile',newFileName)));
            end
            if~exist(newFileName,'file')
                obj.dataMap=containers.Map;
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

                obj.dataMap=containers.Map;
                obj.ScenarioToSignalListMap=containers.Map;





                if~foundDs
                    throw(MException(message('sl_sta_editor_block:message:NoScenarios',newFileName)));
                end
                obj.FileName=newFileName;
                fileContents=load(obj.FileName);
                for id=1:length(scenarioNames)
                    ds=fileContents.(scenarioNames{id});
                    if isscalar(ds)

                        signalList=cellstr(ds.getElementNames);
                        obj.ScenarioToSignalListMap(scenarioNames{id})=signalList;
                        signalMap=containers.Map;
                        for i=1:length(signalList)
                            signalMap(signalList{i})=[];
                        end
                        obj.dataMap(scenarioNames{id})=signalMap;
                    end
                end

                obj.isUpdated=true;
            end
        end

        function processScenario(obj,newScenario)
            scenarioList=obj.getScenarioList;
            if~isempty(scenarioList)&&any(strcmp(newScenario,scenarioList))
                obj.Scenario=newScenario;
            else
                if obj.isUpdated


                    obj.Scenario=scenarioList{1};
                else

                    throw(MException(message('sl_sta_editor_block:message:NonExistentScenario')));
                end
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
                    if obj.dataMap.isKey(obj.Scenario)
                        signalMap=obj.dataMap(obj.Scenario);
                    else
                        signalMap=containers.Map;
                    end
                    signalMap(Signal.Name)=SignalToUpdate;
                    obj.dataMap(obj.Scenario)=signalMap;
                    obj.isUpdated=true;
                end
            end

            obj.SignalCache=SignalToUpdate;
        end
    end
end