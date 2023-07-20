classdef Definition<Simulink.ModelManagement.Project.BatchJob.BatchJobDefinition




    properties(GetAccess=public,SetAccess=protected)
        Files;
        Command;
        Arguments;
    end

    methods(Access=public)

        function definition=Definition(command,files,varargin)
            definition.Command=command;
            definition.Files=files;
            definition.Arguments=varargin;
        end

    end

end

