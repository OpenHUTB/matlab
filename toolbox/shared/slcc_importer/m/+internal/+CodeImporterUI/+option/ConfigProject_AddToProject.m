
classdef ConfigProject_AddToProject<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigProject_AddToProject(env)
            id='ConfigProject_AddToProject';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='projectfile';
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
    end
end