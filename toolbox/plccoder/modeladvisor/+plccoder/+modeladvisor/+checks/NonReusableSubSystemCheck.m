classdef NonReusableSubSystemCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Non Reusable subsystems not supported

    properties(Access = protected)
        checkName      = 'NonReusableSubSystemCheck';
        checkGroup     = 'BlockLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = NonReusableSubSystemCheck();
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
            % This check used to run on extracted model. However, since
            % this is not required, it will now run on the top level
            % subsystem from original model.
            modelH = system;

            nonReusableSubsystems = plc_find_system(modelH, 'FollowLinks', 'on', 'LookUnderMasks', ...
                'all', 'LookUnderReadProtectedSubsystems', 'on', 'RTWSystemCode', 'Nonreusable function');

            for i = 1 : length(nonReusableSubsystems)
                % Skip if top level subsystem
                if nonReusableSubsystems(i) == modelH
                    continue;
                end

                resultStruct = [resultStruct struct(...
                    'ErrorID', 'plccoder:plccg_ext:UnsupportedNonReusableSubsystem', ...
                    'Args', {{getfullname(nonReusableSubsystems(i))}})]; %#ok<AGROW>
            end
        end
    end
end