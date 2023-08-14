classdef SimulinkModelFileType<Simulink.ModelManagement.Project.FileHandler.AbstractFileType




    methods(Access=private)
        function obj=SimulinkModelFileType(javaFile)
            obj=obj@Simulink.ModelManagement.Project.FileHandler.AbstractFileType(javaFile);
        end
    end

    methods(Access=protected)
        function fileName=generateFileName(obj)
            [~,fileName,~]=fileparts(obj.FilePath);
        end
    end

    methods(Access=protected,Static)
        function match=performQuery(fileName,key,value)
            match=strcmp(get_param(fileName,key),value);
        end
    end

    methods(Access=public,Static)
        function fileType=create(javaFile,parameterMapping)
            initialFileType=Simulink.ModelManagement.Project.FileHandler.SimulinkModelFileType(javaFile);
            fileType=initialFileType.setExcluded(parameterMapping);
        end
    end

end

