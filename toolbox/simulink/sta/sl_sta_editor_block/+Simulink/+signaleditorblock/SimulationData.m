classdef SimulationData





    methods(Static)
        function addSimulationDataToHashMap(block)


            fileName=get_param(block,'FileName');
            scenarioName=get_param(block,'ActiveScenario');

            Simulink.signaleditorblock.SimulationData.addSimulationDataToHashMapUtil(fileName,scenarioName);
        end

        function addSimulationDataToHashMapUtil(fileName,scenarioName)


            fileContents=load(fileName,scenarioName);
            ds=fileContents.(scenarioName);
            listener=Simulink.signaleditorblock.ListenerMap.getInstance;
            listener.addListener([fileName,'_',scenarioName],ds);
        end

        function removeSimulationDataFromHashMap(block)

            fileName=get_param(block,'FileName');
            scenarioName=get_param(block,'ActiveScenario');

            listener=Simulink.signaleditorblock.ListenerMap.getInstance;
            listener.removeListener([fileName,'_',scenarioName]);
        end

        function data=getData(encodedBlockPath,signalID)




            listener=Simulink.signaleditorblock.ListenerMap.getInstance;
            blockPath=native2unicode(matlab.net.base64decode(encodedBlockPath));
            blockHandle=getSimulinkBlockHandle(blockPath);
            if~ishandle(blockHandle)
                data=[];
                return;
            end
            fileName=get_param(blockHandle,'FileName');
            scenarioName=get_param(blockHandle,'ActiveScenario');
            aScenario=listener.getListenerMap([fileName,'_',scenarioName]);
            if isempty(aScenario)
                Simulink.signaleditorblock.SimulationData.addSimulationDataToHashMapUtil(fileName,scenarioName);
                aScenario=listener.getListenerMap([fileName,'_',scenarioName]);
            end
            if str2double(signalID)<=aScenario.numElements
                data=aScenario.get(str2double(signalID));
            else


                outports=find_system(blockHandle,'FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all','BlockType','Outport');
                signalName=get_param(outports(str2double(signalID)),'Name');
                throw(MException(message('sl_sta_editor_block:message:NonExistentSignal',signalName,scenarioName)));
            end
        end

    end
end

