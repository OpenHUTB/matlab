classdef MachineParentedDataCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Stateflow messages are not supported

    properties(Access = protected)
        checkName      = 'MachineParentedDataCheck';
        checkGroup     = 'ModelLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = MachineParentedDataCheck();
            end
            obj = instance;
        end
    end

    methods(Access = protected)
        function resultStruct = runCheck(obj, system)
            % This method runs the check and returns a struct with findings

            resultStruct = [];

            if ~ishandle(system)
                system = get_param(system, 'handle');
            end
            modelH = bdroot(system);

            machineId = sf('find','all','machine.name',get_param(modelH,'Name'));
            if ~isempty(machineId)
                objIds = sf('DataOf', machineId);
                if ~isempty(objIds)
                    dataStr = '';
                    numData = length(objIds);
                    for i = 1:numData
                        dataStr = [dataStr '' sf('get',objIds(i),'.name') '']; %#ok<AGROW>
                        if  i<numData
                            dataStr = [dataStr ' and ']; %#ok<AGROW>
                        end
                    end
                    resultStruct = [resultStruct struct(...
                        'ErrorID', 'plccoder:plccg_ext:MachineParentedData', ...
                        'Args', {{getfullname(modelH), dataStr}})];
                end
                objIds = sf('EventsOf', machineId);
                if ~isempty(objIds)
                    dataStr = '';
                    numEvents = length(objIds);
                    for i=1:numEvents
                        dataStr = [dataStr '' sf('get',objIds(i),'.name') '']; %#ok<AGROW>
                        if i<numEvents
                            dataStr = [dataStr ' and ']; %#ok<AGROW>
                        end
                    end
                    resultStruct = [resultStruct struct(...
                        'ErrorID', 'plccoder:plccg_ext:MachineParentedDataEvent', ...
                        'Args', {{getfullname(modelH), dataStr}})];
                end
            end
        end
    end
end