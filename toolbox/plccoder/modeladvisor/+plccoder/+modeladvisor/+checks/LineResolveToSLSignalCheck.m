classdef LineResolveToSLSignalCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Signal Lines should not have 'Resolve to Signal Object' marked as
    % true. g1974576

    properties(Access = protected)
        checkName      = 'LineResolveToSLSignalCheck';
        checkGroup     = 'ModelLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = LineResolveToSLSignalCheck();
            end
            obj = instance;
        end
    end

    methods(Access = protected)
        function resultStruct = runCheck(obj, system)
            % This method runs the check and returns a struct with findings

            resultStruct = [];

            opts = {'FindAll', 'on', 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'LookUnderReadProtectedSubsystems', 'on', 'type', 'port', 'PortType', 'outport'};
            subsysPath = getfullname(system);
            allOutports = plc_find_system(subsysPath, opts{:});
            resolveON=get_param(allOutports, 'MustResolveToSignalObject');
            signalIndices = find(contains(resolveON, 'on'));
            outportWithSignalResolve = allOutports(signalIndices); %#ok<FNDSB>
            for i = 1 : length(outportWithSignalResolve)
                portname = get_param(outportWithSignalResolve(i), 'name');
                parentBlk = get_param(outportWithSignalResolve(i), 'Parent');
                parentHdl = get_param(parentBlk, 'Handle');
                if strcmpi(get_param(parentHdl, 'BlockType'), 'S-Function') %plcdemo_cruise_control
                    continue;
                end
                resultStruct = [resultStruct struct(...
                    'ErrorID', 'plccoder:plccg_ext:LineResolveToSLSignal', ...
                    'Args', {{portname, parentBlk}})]; %#ok<AGROW>
            end
        end
    end
end