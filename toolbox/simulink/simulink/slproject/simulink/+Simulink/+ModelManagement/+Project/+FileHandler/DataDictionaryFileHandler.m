classdef DataDictionaryFileHandler<Simulink.ModelManagement.Project.FileHandler.AbstractFileHandler




    methods(Access=private)
        function obj=DataDictionaryFileHandler()
        end
    end

    methods(Access=protected)
        function fileTypes=createFileTypes(obj,modelFiles,parameterMapping)
            import Simulink.ModelManagement.Project.FileHandler.DataDictionaryFileType.create
            fileTypes=createFileTypes@Simulink.ModelManagement.Project.FileHandler.AbstractFileHandler(...
            obj,...
            @(x)create(x,parameterMapping),...
            modelFiles);
        end
    end

    methods(Access=public,Static)
        function modelsToNotClose=close(modelFiles)
            parameterMapping=defaultParameterMapping();
            parameterMapping('HasUnsavedChanges')=false;

            fileHandler=Simulink.ModelManagement.Project.FileHandler.DataDictionaryFileHandler;
            fileTypes=fileHandler.createFileTypes(modelFiles,parameterMapping);

            successFlags=fileHandler.callOnEachFile(...
            fileTypes,...
            @(x)x,...
            @(x,y)discardChanges(x{:},y{:})...
            );
            modelsToNotClose=cellfun(@(x)x.JavaFile,fileTypes(~successFlags),'UniformOutput',false);
        end

        function modelsToNotSave=save(modelFiles)
            parameterMapping=defaultParameterMapping();

            fileHandler=Simulink.ModelManagement.Project.FileHandler.DataDictionaryFileHandler;
            fileTypes=fileHandler.createFileTypes(modelFiles,parameterMapping);

            successFlags=fileHandler.callOnEachFile(...
            fileTypes,...
            @(x)x,...
            @(x,y)saveChanges(y{:})...
            );
            modelsToNotSave=cellfun(@(x)x.JavaFile,fileTypes(~successFlags),'UniformOutput',false);
        end

        function modelsToNotClose=discardChanges(modelFiles)
            parameterMapping=defaultParameterMapping();

            fileHandler=Simulink.ModelManagement.Project.FileHandler.DataDictionaryFileHandler;
            fileTypes=fileHandler.createFileTypes(modelFiles,parameterMapping);

            successFlags=fileHandler.callOnEachFile(...
            fileTypes,...
            @(x)x,...
            @(x,y)discardChanges(x{:},y{:})...
            );
            modelsToNotClose=cellfun(@(x)x.JavaFile,fileTypes(~successFlags),'UniformOutput',false);
        end

        function modelsToNotOpen=open(modelFiles)
            parameterMapping=defaultParameterMapping();

            fileHandler=Simulink.ModelManagement.Project.FileHandler.DataDictionaryFileHandler;
            fileTypes=fileHandler.createFileTypes(modelFiles,parameterMapping);

            successFlags=fileHandler.callOnEachFile(...
            fileTypes,...
            @(x)x,...
            @(x,y)showDictionary(y{:})...
            );
            modelsToNotOpen=cellfun(@(x)x.JavaFile,fileTypes(~successFlags),'UniformOutput',false);
        end
    end
end

function parameterMapping=defaultParameterMapping()
    parameterMapping=containers.Map('KeyType','char','ValueType','logical');
end

function saveChanges(filepath)
    dictionary=Simulink.data.dictionary.open(filepath);
    dictionary.saveChanges();
end

function discardChanges(filename,filepath)
    dictionary=Simulink.data.dictionary.open(filepath);
    Simulink.data.dictionary.closeAll(filename,'-discard');
end

function showDictionary(filepath)
    dictionary=Simulink.data.dictionary.open(filepath);
    dictionary.show();
end
