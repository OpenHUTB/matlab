classdef ChartUpdateCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Stateflow chart Update check

    properties(Access = protected)
        checkName      = 'ChartUpdateCheck';
        checkGroup     = 'BlockLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = ChartUpdateCheck();
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
            machineIds = sf('find','all','machine.name',get_param(modelH,'Name'));
            if ~isempty(machineIds)
                for machine = machineIds(:)
                    chartIds = sf('get',machine,'.charts');
                    [~,linkCharts] = plccoder.modeladvisor.helpers.machineLinkedCharts(machine);
                    linkCharts = unique(linkCharts);
                    chartIds = [chartIds(:)'  linkCharts(:)'];
                    for chart = chartIds
                        updateMethod = sf('get', chart, '.updateMethod');
                        if(updateMethod == 2) % CONTINUOUS
                            chartName = sf('get',chart,'.name');
                            resultStruct = [resultStruct struct(...
                                'ErrorID', 'plccoder:plccg_ext:SfContUpdate', ...
                                'Args', {{chartName}})]; %#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
end