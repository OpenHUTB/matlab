classdef TunableParamInfCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Tunable parameters should not contain infinite value

    properties(Access = protected)
        checkName       = 'TunableParamInfCheck';
        checkGroup      = 'ModelLevelChecks';
    end

    methods(Access = protected)
        function obj = TunableParamInfCheck()
            obj.callbackContext = 'PostCompileForCodegen';
        end
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = TunableParamInfCheck();
            end
            obj = instance;
        end
    end

    methods(Access = protected)
        function resultStruct = runCheck(obj, system)
            % This method runs the check and returns a struct with findings

            resultStruct = [];

            modelH = bdroot(system);
            parameterObjects = Simulink.findVars(get_param(modelH, 'Name'), 'WorkspaceType', 'base', 'SearchMethod', 'cached');
            for i = 1 : length(parameterObjects)
                parameterName = parameterObjects(i).Name;
                parameterObject = evalin('base', parameterName);
                if isa(parameterObject, 'Simulink.Parameter')
                    [infFound, fname] = plccoder.modeladvisor.helpers.isInfAMember(parameterObject.Value);
                else
                    [infFound, fname] = plccoder.modeladvisor.helpers.isInfAMember(parameterObject);
                end

                if infFound

                    if isempty(fname)
                        resultStruct = [resultStruct struct(...
                            'ErrorID', 'plccoder:plccg_ext:TunableParamInf', ...
                            'Args', {{parameterName}})]; %#ok<AGROW>
                    else
                        resultStruct = [resultStruct struct(...
                            'ErrorID', 'plccoder:plccg_ext:TunableParamInfField', ...
                            'Args', {{fname, parameterName}})]; %#ok<AGROW>;
                    end
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