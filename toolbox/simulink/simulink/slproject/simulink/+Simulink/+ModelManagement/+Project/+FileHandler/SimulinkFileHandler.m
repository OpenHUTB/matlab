classdef SimulinkFileHandler<Simulink.ModelManagement.Project.FileHandler.AbstractFileHandler




    methods(Access=private)
        function obj=SimulinkFileHandler()
        end
    end

    methods(Access=protected)
        function fileTypes=createFileTypes(obj,modelFiles,parameterMapping)
            import Simulink.ModelManagement.Project.FileHandler.SimulinkModelFileType.create
            fileTypes=createFileTypes@Simulink.ModelManagement.Project.FileHandler.AbstractFileHandler(...
            obj,...
            @(x)create(x,parameterMapping),...
            modelFiles);
        end
    end

    methods(Access=public,Static)
        function modelsToNotClose=close(modelFiles)
            parameterMapping=defaultParameterMapping();
            parameterMapping('Dirty')='off';

            fileHandler=Simulink.ModelManagement.Project.FileHandler.SimulinkFileHandler;
            fileTypes=fileHandler.createFileTypes(modelFiles,parameterMapping);

            successFlags=fileHandler.callOnEachFile(...
            fileTypes,...
            @(x)includedModelFilter(x),...
            @(x,y)close_system(x)...
            );
            modelsToNotClose=cellfun(@(x)x.JavaFile,fileTypes(~successFlags),'UniformOutput',false);
        end

        function modelsToNotSave=save(modelFiles)
            parameterMapping=defaultParameterMapping();

            fileHandler=Simulink.ModelManagement.Project.FileHandler.SimulinkFileHandler;
            fileTypes=fileHandler.createFileTypes(modelFiles,parameterMapping);

            successFlags=fileHandler.bulkOperation(...
            fileTypes,...
            @(x)includedModelFilter(x),...
            @(x,y)save_system(x,y,'SaveDirtyReferencedModels','on')...
            );
            modelsToNotSave=cellfun(@(x)x.JavaFile,fileTypes(~successFlags),'UniformOutput',false);
        end

        function modelsToNotClose=discardChanges(modelFiles)
            parameterMapping=defaultParameterMapping();

            fileHandler=Simulink.ModelManagement.Project.FileHandler.SimulinkFileHandler;
            fileTypes=fileHandler.createFileTypes(modelFiles,parameterMapping);

            successFlags=fileHandler.bulkOperation(...
            fileTypes,...
            @(x)includedModelFilter(x),...
            @(x,y)close_system(x,0)...
            );
            modelsToNotClose=cellfun(@(x)x.JavaFile,fileTypes(~successFlags),'UniformOutput',false);
        end

        function modelsToNotOpen=open(modelFiles)
            parameterMapping=containers.Map('KeyType','char','ValueType','char');

            fileHandler=Simulink.ModelManagement.Project.FileHandler.SimulinkFileHandler;
            fileTypes=fileHandler.createFileTypes(modelFiles,parameterMapping);

            successFlags=fileHandler.callOnEachFile(...
            fileTypes,...
            @(x)includedModelFilter(x),...
            @(x,y)open_system(x)...
            );
            modelsToNotOpen=cellfun(@(x)x.JavaFile,fileTypes(~successFlags),'UniformOutput',false);
        end
    end

end

function parameterMapping=defaultParameterMapping()
    parameterMapping=containers.Map('KeyType','char','ValueType','char');
    parameterMapping('SimulationStatus')='stopped';
end

function fileType=includedModelFilter(fileType)
    if isempty(fileType)
        return
    end

    if fileType.Excluded
        fileType=[];
    end
end
