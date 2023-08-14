classdef CustomCodeCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
% Custom code is not supported

%   Copyright 2021 The MathWorks, Inc.

    properties(Access = protected)
        checkName      = 'CustomCodeCheck';
        checkGroup     = 'ModelLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = CustomCodeCheck();
            end
            obj = instance;
        end
    end

    methods(Access = protected)
        function resultStruct = runCheck(obj, system) %#ok<INUSL>
        % This method runs the check and returns a struct with findings

            resultStruct = [];

            if ~ishandle(system)
                system = get_param(system, 'handle');
            end
            modelH = bdroot(system);
            modelName = get_param(modelH, 'Name');
            cs = getActiveConfigSet(modelName);
            simTargetComp = cs.getComponent('Simulation Target');
            if isempty(simTargetComp)
                return;
            end
            usingCustomCode = ~isempty(simTargetComp.SimCustomSourceCode) || ...
                ~isempty(simTargetComp.SimCustomHeaderCode) || ...
                ~isempty(simTargetComp.SimCustomInitializer) || ...
                ~isempty(simTargetComp.SimCustomTerminator) || ...
                ~isempty(simTargetComp.SimUserSources) || ...
                ~isempty(simTargetComp.SimUserIncludeDirs) || ...
                ~isempty(simTargetComp.SimUserLibraries);
            if(usingCustomCode)
                resultStruct = [resultStruct struct(...
                    'ErrorID', 'plccoder:plccg_ext:UnsupportedCustomCode', ...
                    'Args', {{}})];
            end
        end
    end
end

% LocalWords:  plccg
