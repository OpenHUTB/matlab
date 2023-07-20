classdef JavaDefinitionAdapter<Simulink.ModelManagement.Project.BatchJob.BatchJobDefinition




    properties(GetAccess=public,SetAccess=protected)
        Files;
        Command;
        Arguments;
    end

    methods(Access=public)

        function definition=JavaDefinitionAdapter(javaDefinition)
            filesList=javaDefinition.getFiles();
            numFiles=filesList.size();
            definition.Files=cell(numFiles,1);
            for n=1:numFiles
                file=filesList.get(n-1);
                filepath=char(file.getAbsolutePath());
                definition.Files{n}=filepath;
            end

            command=char(javaDefinition.getCommand());

            if(strncmp(command,'@',1))

                definition.Command=str2func(command);
            else

                file=regexp(command,'\(','split');
                if(exist(file{1},'class'))
                    definition.Command=eval(command);
                elseif(exist(file{1},'builtin')||exist(file{1},'file'))
                    definition.Command=str2func(command);
                else
                    DAStudio.error('SimulinkProject:BatchJob:notOnPath');
                end
            end

            definition.Arguments={};
        end

    end

end
