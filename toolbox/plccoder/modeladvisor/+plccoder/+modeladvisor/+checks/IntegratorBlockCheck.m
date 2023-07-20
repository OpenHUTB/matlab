classdef IntegratorBlockCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Check Discrete Integrator blocks

    properties(Access = protected)
        checkName      = 'IntegratorBlockCheck';
        checkGroup     = 'BlockLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = IntegratorBlockCheck();
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
            diblk_list = plc_find_system(modelH, 'FollowLinks', 'on', 'LookUnderMasks', ...
                'all', 'LookUnderReadProtectedSubsystems', 'on', 'FindAll', 'on', 'BlockType', 'DiscreteIntegrator');
            for i = 1 : length(diblk_list)
                diblk = diblk_list(i);
                if (strcmp(get_param(diblk, 'InitialConditionSource'), 'external'))
                    ph = get_param(diblk, 'PortHandles');
                    pc = get_param(diblk, 'PortConnectivity');
                    ic_blk = pc(numel(ph.Inport)).SrcBlock;
                    if strcmp(get_param(ic_blk, 'BlockType'), 'Constant')
                        resultStruct = [resultStruct struct(...
                            'ErrorID', 'plccoder:plccg_ext:UnsupportedDiscreteIntegrator', ...
                            'Args', {{getfullname(diblk_list(i))}})]; %#ok<AGROW>
                    end
                end

                % check DI algo mode, g2062037
                algo_method = get_param(diblk, 'IntegratorMethod');
                switch algo_method
                    case {'Integration: Backward Euler', 'Integration: Trapezoidal', ...
                            'Accumulation: Backward Euler', 'Accumulation: Trapezoidal'}
                        resultStruct = [resultStruct struct(...
                            'ErrorID', 'plccoder:plccg_ext:DiscreteIntegratorAlgorithmCheck', ...
                            'Args', {{getfullname(diblk), 'DiscreteIntegrator', algo_method}})]; %#ok<AGROW>
                    otherwise
                        continue;
                end
            end
        end
    end

    methods
        function errorExists = runAsConformanceCheck(obj, system, errorExists)
            % This method runs the check and throws errors

            resultStruct = obj.runCheck(system);
            resultStruct = obj.filterExternallyDefinedBlocks(resultStruct);

            if numel(resultStruct) == 1
                errorExists = true; %#ok<NASGU>
                error(message(resultStruct(1).ErrorID, resultStruct(1).Args{:}));
            elseif numel(resultStruct) > 1
                errorExists = true;
                msl = MSLDiagnostic([], 'plccoder:plccg_ext:PLCErrorGroup', message('plccoder:plccg_ext:PLCErrorGroup').getString);
                for i = 1:numel(resultStruct)
                    msl = msl.addCause(MSLDiagnostic([],...
                        resultStruct(i).ErrorID, ...
                        message(resultStruct(i).ErrorID, resultStruct(i).Args{:}).getString));
                end
                msl.reportAsError;
            end
        end
    end
end