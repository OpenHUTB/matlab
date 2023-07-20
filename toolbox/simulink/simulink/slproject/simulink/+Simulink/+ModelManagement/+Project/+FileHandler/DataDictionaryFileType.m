classdef DataDictionaryFileType<Simulink.ModelManagement.Project.FileHandler.AbstractFileType




    methods(Access=private)
        function obj=DataDictionaryFileType(javaFile)
            obj=obj@Simulink.ModelManagement.Project.FileHandler.AbstractFileType(javaFile);
        end
    end

    methods(Access=protected)
        function fileName=generateFileName(obj)
            [~,fileName,extension]=fileparts(obj.FilePath);
            fileName=[fileName,extension];
        end
    end

    methods(Access=protected,Static)
        function match=performQuery(fileName,key,value)
            dictionary=Simulink.data.dictionary.open(fileName);
            match=dictionary.(key)==value;
        end
    end

    methods(Access=public,Static)
        function fileType=create(javaFile,parameterMapping)
            initialFileType=Simulink.ModelManagement.Project.FileHandler.DataDictionaryFileType(javaFile);
            fileType=initialFileType.setExcluded(parameterMapping);
        end
    end


end

