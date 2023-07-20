classdef VariableDependencyAllBaseWorkspace<restorepoint.internal.create.VariableDependencyStrategy




    methods
        function run(~,restoreData)
            restoreData.OriginalWorkspaceVariables=evalin('base','who');
        end
    end

end